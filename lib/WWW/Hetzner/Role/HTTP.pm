package WWW::Hetzner::Role::HTTP;

# ABSTRACT: HTTP client role for Hetzner API clients

use Moo::Role;
use LWP::UserAgent;
use JSON::MaybeXS qw(decode_json encode_json);
use Carp qw(croak);
use Log::Any qw($log);

our $VERSION = '0.001';

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

sub get {
    my ($self, $path, %params) = @_;
    return $self->_request('GET', $path, %params);
}

sub post {
    my ($self, $path, $data) = @_;
    return $self->_request('POST', $path, body => $data);
}

sub put {
    my ($self, $path, $data) = @_;
    return $self->_request('PUT', $path, body => $data);
}

sub delete {
    my ($self, $path) = @_;
    return $self->_request('DELETE', $path);
}

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
    $request->header('Authorization' => 'Bearer ' . $self->token);
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

1;

__END__

=head1 NAME

WWW::Hetzner::Role::HTTP - HTTP client role for Hetzner API clients

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

=head1 PROVIDED METHODS

=head2 get

    my $data = $self->get('/path', params => { key => 'value' });

=head2 post

    my $data = $self->post('/path', { key => 'value' });

=head2 put

    my $data = $self->put('/path', { key => 'value' });

=head2 delete

    my $data = $self->delete('/path');

=head1 SEE ALSO

L<WWW::Hetzner::Cloud>, L<Log::Any>

=cut
