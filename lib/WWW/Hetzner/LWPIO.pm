package WWW::Hetzner::LWPIO;

# ABSTRACT: Synchronous HTTP backend using LWP::UserAgent

use Moo;
use LWP::UserAgent;
use HTTP::Request;
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::HTTPResponse;

with 'WWW::Hetzner::Role::IO';

our $VERSION = '0.103';

=head1 SYNOPSIS

    use WWW::Hetzner::LWPIO;

    my $io = WWW::Hetzner::LWPIO->new(timeout => 60);

=head1 DESCRIPTION

Default synchronous HTTP backend using L<LWP::UserAgent>. Implements
L<WWW::Hetzner::Role::IO>.

=cut

has timeout => (is => 'ro', default => 30);

=attr timeout

Timeout in seconds for HTTP requests. Defaults to 30.

=cut

has ua => (
    is      => 'lazy',
    builder => sub {
        my $self = shift;
        LWP::UserAgent->new(
            agent   => 'WWW-Hetzner/' . $VERSION,
            timeout => $self->timeout,
        );
    },
);

=attr ua

L<LWP::UserAgent> instance. Built lazily.

=cut

sub call {
    my ($self, $req) = @_;

    my $http_req = HTTP::Request->new($req->method => $req->url);

    my $headers = $req->headers;
    for my $header (keys %$headers) {
        $http_req->header($header => $headers->{$header});
    }

    $http_req->content($req->content) if $req->has_content;

    my $response = $self->ua->request($http_req);

    my $content = $response->decoded_content // '';

    # LWP synthesises a 5xx response when the request never reached the
    # server (connection refused, DNS, TLS, timeout). Report its reason in
    # the API error shape instead of a bare status code. LWP's content
    # repeats the reason below its first line and adds a Perl source
    # position, so only the first line is kept.
    if (($response->header('Client-Warning') // '') eq 'Internal response') {
        my ($reason) = $content =~ /^\s*(\S[^\n]*)/;
        $reason =~ s/\s+$// if defined $reason;
        $content = encode_json({
            error => { code => 'transport_error', message => $reason || $response->message },
        });
    }

    return WWW::Hetzner::HTTPResponse->new(
        status  => $response->code,
        content => $content,
    );
}

=method call($req)

Execute an L<WWW::Hetzner::HTTPRequest> via LWP and return a
L<WWW::Hetzner::HTTPResponse>. If LWP reports an internal failure (the
request never reached the server), the response has status 500 and a JSON
error body with code C<transport_error>. Its message is the first line of
LWP's content, falling back to LWP's status message, so the reason appears
once and without LWP's Perl source position. The caller's
L<WWW::Hetzner::Role::HTTP> turns it into a L<WWW::Hetzner::Error>, for
example C<Hetzner API error: Can't connect to 127.0.0.1:1 (Connection
refused) (500 transport_error)>.

=cut

=head1 HTTP DEBUGGING

Load L<LWP::ConsoleLogger::Everywhere> to see full HTTP traffic (headers,
bodies, status codes) without changing your code:

    perl -MLWP::ConsoleLogger::Everywhere your_script.pl

=head1 SEE ALSO

L<WWW::Hetzner::Role::IO>, L<WWW::Hetzner::Role::HTTP>,
L<LWP::ConsoleLogger::Everywhere>

=cut

1;
