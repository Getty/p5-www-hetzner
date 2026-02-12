package WWW::Hetzner::LWPIO;

# ABSTRACT: Synchronous HTTP backend using LWP::UserAgent

use Moo;
use LWP::UserAgent;
use HTTP::Request;
use WWW::Hetzner::HTTPResponse;

with 'WWW::Hetzner::Role::IO';

our $VERSION = '0.101';

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

    return WWW::Hetzner::HTTPResponse->new(
        status  => $response->code,
        content => $response->decoded_content // '',
    );
}

=method call($req)

Execute an L<WWW::Hetzner::HTTPRequest> via LWP and return a
L<WWW::Hetzner::HTTPResponse>.

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
