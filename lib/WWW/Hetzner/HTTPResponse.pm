package WWW::Hetzner::HTTPResponse;

# ABSTRACT: HTTP response object for Hetzner API

use Moo;

our $VERSION = '0.004';

=head1 SYNOPSIS

    use WWW::Hetzner::HTTPResponse;

    my $res = WWW::Hetzner::HTTPResponse->new(
        status  => 200,
        content => '{"servers":[]}',
    );

=head1 DESCRIPTION

Transport-independent HTTP response object. Returned by L<WWW::Hetzner::Role::IO>
backends and processed by L<WWW::Hetzner::Role::HTTP>.

=cut

has status => (is => 'ro', required => 1);

=attr status

The HTTP status code (e.g., 200, 404, 500).

=cut

has content => (is => 'ro', default => '');

=attr content

The response body content.

=cut

=head1 SEE ALSO

L<WWW::Hetzner::HTTPRequest>, L<WWW::Hetzner::Role::IO>

=cut

1;
