package WWW::Hetzner::HTTPRequest;

# ABSTRACT: HTTP request object for Hetzner API

use Moo;

our $VERSION = '0.101';

=head1 SYNOPSIS

    use WWW::Hetzner::HTTPRequest;

    my $req = WWW::Hetzner::HTTPRequest->new(
        method  => 'GET',
        url     => 'https://api.hetzner.cloud/v1/servers',
        headers => { Authorization => 'Bearer token' },
    );

=head1 DESCRIPTION

Transport-independent HTTP request object. Used by L<WWW::Hetzner::Role::HTTP>
to build requests that are then executed by an L<WWW::Hetzner::Role::IO>
backend.

=cut

has method => (is => 'ro', required => 1);

=attr method

The HTTP method (GET, POST, PUT, DELETE).

=cut

has url => (is => 'ro', required => 1);

=attr url

The complete request URL.

=cut

has headers => (is => 'ro', default => sub { {} });

=attr headers

Hashref of HTTP headers.

=cut

has content => (is => 'ro', predicate => 1);

=attr content

The request body content (JSON string). Use C<has_content> to check presence.

=cut

=head1 SEE ALSO

L<WWW::Hetzner::HTTPResponse>, L<WWW::Hetzner::Role::IO>

=cut

1;
