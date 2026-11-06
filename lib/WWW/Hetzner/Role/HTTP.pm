package WWW::Hetzner::Role::HTTP;

# ABSTRACT: HTTP client role for Hetzner API clients

use Moo::Role;
use WWW::Hetzner::HTTPRequest;
use WWW::Hetzner::HTTPResponse;
use WWW::Hetzner::LWPIO;
use WWW::Hetzner::Error;
use JSON::MaybeXS qw(decode_json encode_json);
use URI::Escape ();
use Carp qw(croak);
use Log::Any qw($log);

our $VERSION = '0.103';

=head1 SYNOPSIS

    package WWW::Hetzner::Cloud;
    use Moo;

    has token => ( is => 'ro' );
    has base_url => ( is => 'ro', default => 'https://api.hetzner.cloud/v1' );

    with 'WWW::Hetzner::Role::HTTP';

=head1 DESCRIPTION

This role provides HTTP methods (GET, POST, PUT, DELETE) for Hetzner API
clients. It handles client-specific request-body encoding, JSON response
decoding, authentication, and error handling. Request bodies use JSON by
default; L<WWW::Hetzner::Robot> uses
C<application/x-www-form-urlencoded> instead.

A client with a different body format overrides L</_content_type> and
L</_encode_body>.

HTTP transport is delegated to a pluggable L<WWW::Hetzner::Role::IO> backend
(default: L<WWW::Hetzner::LWPIO>), making it possible to use async HTTP
clients.

Uses L<Log::Any> for logging HTTP requests and responses. The debug log of a
request body masks the top-level keys C<password>, C<private_key> and
C<user_data>; the request itself is sent unchanged.

A non-2xx response throws a L<WWW::Hetzner::Error>, which stringifies to one
line:

=over 4

=item * With an API message: C<Hetzner API error: MESSAGE (STATUS CODE)>, or
C<(STATUS)> when the body carries no code, for example
C<Hetzner API error: unable to authenticate (401 unauthorized)>.

=item * Without one: C<Hetzner API error: STATUS CODE>, otherwise STATUS
followed by the (tag-stripped, truncated) body text, or STATUS alone for an
empty body.

=back

The text quotes nothing from the request: no method, path, body or headers.
Where the response body repeats the client's credential (the token; for Robot
the password and the Base64 block of the C<Authorization> header), it reads
C<********>. A caller reads the HTTP status, the API's error code and the API's
message from the object's C<status>, C<code> and C<api_message> methods.

=head1 REQUIRED ATTRIBUTES

Classes consuming this role must provide:

=over 4

=item * C<token> - API authentication token

=item * C<base_url> - Base URL for the API

=back

=cut

requires 'token';
requires 'base_url';

has io => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::LWPIO->new },
);

=attr io

Pluggable HTTP backend implementing L<WWW::Hetzner::Role::IO>.
Defaults to L<WWW::Hetzner::LWPIO>.

    # Use a custom IO backend
    my $cloud = WWW::Hetzner::Cloud->new(
        token => $token,
        io    => My::AsyncIO->new,
    );

=cut

has sleeper => (
    is      => 'rw',
    default => sub { sub { sleep $_[0] } },
);

=attr sleeper

Injectable sleep function, C<sub ($seconds) { ... }>, called with the poll
interval. Defaults to C<sleep>. Declared C<rw> so a test can swap in a
non-blocking counting closure after construction, without rebuilding the
client. Used by L<WWW::Hetzner::Action/wait> between polls, via the
client the action holds a reference to.

=cut

sub get {
    my ($self, $path, %params) = @_;
    return $self->_request('GET', $path, %params);
}

=method get

    my $data = $self->get('/path', params => { key => 'value' });

Perform a GET request.

=cut

sub post {
    my ($self, $path, $data) = @_;
    return $self->_request('POST', $path, body => $data);
}

=method post

    my $data = $self->post('/path', { key => 'value' });

Perform a POST request whose body is encoded by L</_encode_body> with the
media type from L</_content_type>. JSON is the default; the Robot client uses
form encoding.

=cut

sub put {
    my ($self, $path, $data) = @_;
    return $self->_request('PUT', $path, body => $data);
}

=method put

    my $data = $self->put('/path', { key => 'value' });

Perform a PUT request whose body is encoded by L</_encode_body> with the
media type from L</_content_type>. JSON is the default; the Robot client uses
form encoding.

=cut

sub delete {
    my ($self, $path) = @_;
    return $self->_request('DELETE', $path);
}

=method delete

    my $data = $self->delete('/path');

Perform a DELETE request.

=cut

sub _set_auth {
    my ($self, $headers) = @_;
    $headers->{Authorization} = 'Bearer ' . $self->token;
}

=method _set_auth

Sets authentication headers. Override for different auth mechanisms:

    # Default: Bearer token
    sub _set_auth {
        my ($self, $headers) = @_;
        $headers->{Authorization} = 'Bearer ' . $self->token;
    }

    # Basic Auth (e.g. Robot API)
    sub _set_auth {
        my ($self, $headers) = @_;
        require MIME::Base64;
        $headers->{Authorization} = 'Basic ' .
            MIME::Base64::encode_base64($self->user . ':' . $self->password, '');
    }

=cut

sub _content_type { 'application/json' }

=method _content_type

Content type for request bodies. The default is C<application/json>.
L<WWW::Hetzner::Robot> overrides this to
C<application/x-www-form-urlencoded>; clients with a different body format
must also override L</_encode_body>.

=cut

sub _encode_body {
    my ($self, $body) = @_;
    return encode_json($body);
}

=method _encode_body

Encodes a request body. The default encoder produces JSON. A client that
overrides L</_content_type> for another body format must override this hook to
produce matching content; L<WWW::Hetzner::Robot> uses form encoding.

=cut

sub _build_request {
    my ($self, $method, $path, %opts) = @_;

    my $url = $self->base_url . $path;

    # Add query params for GET
    if ($method eq 'GET' && $opts{params}) {
        my @pairs;
        for my $key (keys %{$opts{params}}) {
            my $value = $opts{params}{$key};
            my @values = ref $value eq 'ARRAY' ? @$value : ($value);
            for my $value (@values) {
                next unless defined $value;
                push @pairs, URI::Escape::uri_escape_utf8($key) . '=' .
                    URI::Escape::uri_escape_utf8($value);
            }
        }
        $url .= '?' . join('&', @pairs) if @pairs;
    }

    $log->debug("$method $url");

    my %headers;
    $self->_set_auth(\%headers);
    $headers{'Content-Type'} = $self->_content_type;

    my %req_args = (
        method  => $method,
        url     => $url,
        headers => \%headers,
    );

    if ($opts{body}) {
        $req_args{content} = $self->_encode_body($opts{body});
        $log->debugf("Body: %s", $self->_encode_body($self->_mask_body($opts{body})));
    }

    return WWW::Hetzner::HTTPRequest->new(%req_args);
}

=method _build_request

    my $req = $self->_build_request('GET', '/servers', params => { page => 1 });

Builds a L<WWW::Hetzner::HTTPRequest> without executing it. Useful for
async workflows where request creation and execution are separate steps.

=cut

my @SECRET_KEYS = qw(password private_key user_data);

sub _mask_body {
    my ($self, $body) = @_;
    return $body unless ref $body eq 'HASH';
    my %copy = %$body;
    for my $key (@SECRET_KEYS) {
        $copy{$key} = '********' if defined $copy{$key};
    }
    return \%copy;
}

# The client's secrets as the server could echo them: the token (for Robot
# its password) and the credential after the scheme in the Authorization
# header (for Robot base64 of user:password).
sub _credentials {
    my ($self) = @_;
    my $token = $self->token;
    return () unless defined $token && length $token;
    my %headers;
    $self->_set_auth(\%headers);
    my ($credential) = ($headers{Authorization} // '') =~ /^\S+\s+(\S+)/;
    return grep { defined && length } $token, $credential;
}

sub _mask_credentials {
    my ($self, $text) = @_;
    for my $secret (sort { length $b <=> length $a } $self->_credentials) {
        $text =~ s/\Q$secret\E/********/g;
    }
    return $text;
}

sub _parse_response {
    my ($self, $response, $method, $path) = @_;

    $log->debugf("Response: %s", $response->status);

    my $data;
    if ($response->content && $response->content =~ /^\s*[\{\[]/) {
        $data = decode_json($response->content);
    }

    unless ($response->status >= 200 && $response->status < 300) {
        my $status = $response->status;
        my $api = ref $data eq 'HASH' && ref $data->{error} eq 'HASH' ? $data->{error} : {};
        my ($code, $message) = map {
            defined $_ && !ref $_ && length $_ ? $self->_mask_credentials($_) : undef
        } @{$api}{qw(code message)};

        my $error;
        if (defined $message) {
            $error = "$message (" . join(' ', grep { defined } $status, $code) . ')';
        }
        elsif (defined $code) {
            $error = "$status $code";
        }
        else {
            $error = $status;
            my $text = $self->_mask_credentials($response->content // '');
            $text =~ s/<[^>]*>/ /g;
            $text =~ s/\s+/ /g;
            $text =~ s/^ //; $text =~ s/ $//;
            $text = substr($text, 0, 200) . '...' if length $text > 200;
            $error .= " $text" if length $text;
        }
        $log->errorf("API error: %s", $error);
        WWW::Hetzner::Error->throw(
            message     => "Hetzner API error: $error",
            status      => $status,
            code        => $code,
            api_message => $message,
        );
    }

    $log->infof("%s %s -> %s", $method, $path, $response->status);
    return $data;
}

=method _parse_response

    my $data = $self->_parse_response($response, 'GET', '/servers');

Parses a L<WWW::Hetzner::HTTPResponse>: decodes JSON, checks for errors. A
non-2xx response throws a L<WWW::Hetzner::Error>; otherwise the decoded data
is returned.
Useful for async workflows where response parsing happens after transport.

=cut

sub _request {
    my ($self, $method, $path, %opts) = @_;

    croak "No API token configured" unless $self->token;

    my $req = $self->_build_request($method, $path, %opts);
    my $response = $self->io->call($req);
    return $self->_parse_response($response, $method, $path);
}

=head1 SEE ALSO

L<WWW::Hetzner::Cloud>, L<WWW::Hetzner::Role::IO>, L<WWW::Hetzner::LWPIO>,
L<WWW::Hetzner::Action>, L<WWW::Hetzner::Error>, L<Log::Any>

=cut

1;
