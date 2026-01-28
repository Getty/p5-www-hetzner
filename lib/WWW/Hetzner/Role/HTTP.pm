package WWW::Hetzner::Role::HTTP;

# ABSTRACT: HTTP client role for Hetzner API clients

use Moo::Role;
use LWP::UserAgent;
use JSON::MaybeXS qw(decode_json encode_json);
use Carp qw(croak);
use Log::Any qw($log);

our $VERSION = '0.004';

=head1 SYNOPSIS

    package WWW::Hetzner::Cloud;
    use Moo;

    has token => ( is => 'ro' );
    has base_url => ( is => 'ro', default => 'https://api.hetzner.cloud/v1' );

    with 'WWW::Hetzner::Role::HTTP';

=head1 DESCRIPTION

This role provides HTTP methods (GET, POST, PUT, DELETE) for Hetzner API
clients. It handles JSON encoding/decoding, authentication, and error handling.

Uses L<Log::Any> for logging HTTP requests and responses.

=head1 REQUIRED ATTRIBUTES

Classes consuming this role must provide:

=over 4

=item * C<token> - API authentication token

=item * C<base_url> - Base URL for the API

=back

=cut

requires 'token';
requires 'base_url';

has ua => (
    is      => 'lazy',
    builder => sub {
        my $self = shift;
        LWP::UserAgent->new(
            agent   => 'WWW-Hetzner/' . $VERSION,
            timeout => 30,
        );
    },
);

=attr ua

L<LWP::UserAgent> instance for making HTTP requests.

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

Perform a POST request with JSON body.

=cut

sub put {
    my ($self, $path, $data) = @_;
    return $self->_request('PUT', $path, body => $data);
}

=method put

    my $data = $self->put('/path', { key => 'value' });

Perform a PUT request with JSON body.

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
    my ($self, $request) = @_;
    $request->header('Authorization' => 'Bearer ' . $self->token);
}

=method _set_auth

Override this method to change authentication. Default is Bearer token:

    sub _set_auth {
        my ($self, $request) = @_;
        $request->header('Authorization' => 'Bearer ' . $self->token);
    }

For Basic Auth (e.g. Robot API):

    sub _set_auth {
        my ($self, $request) = @_;
        $request->authorization_basic($self->user, $self->password);
    }

=cut

sub _request {
    my ($self, $method, $path, %opts) = @_;

    croak "No API token configured" unless $self->token;

    my $url = $self->base_url . $path;

    # Add query params for GET
    if ($method eq 'GET' && $opts{params}) {
        my @pairs;
        for my $k (keys %{$opts{params}}) {
            my $v = $opts{params}{$k};
            next unless defined $v;
            push @pairs, "$k=$v";
        }
        $url .= '?' . join('&', @pairs) if @pairs;
    }

    $log->debug("$method $url");

    my $request = HTTP::Request->new($method => $url);
    $self->_set_auth($request);
    $request->header('Content-Type' => 'application/json');

    if ($opts{body}) {
        my $json = encode_json($opts{body});
        $request->content($json);
        $log->debugf("Body: %s", $json);
    }

    my $response = $self->ua->request($request);

    $log->debugf("Response: %s", $response->status_line);

    my $data;
    if ($response->content && $response->content =~ /^\s*[\{\[]/) {
        $data = decode_json($response->content);
    }

    unless ($response->is_success) {
        my $error = $data->{error}{message} // $response->status_line;
        $log->errorf("API error: %s", $error);
        croak "Hetzner API error: $error";
    }

    $log->infof("%s %s -> %s", $method, $path, $response->status_line);
    return $data;
}

=head1 SEE ALSO

L<WWW::Hetzner::Cloud>, L<Log::Any>

=cut

1;
