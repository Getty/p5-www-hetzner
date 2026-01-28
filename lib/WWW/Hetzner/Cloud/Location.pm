package WWW::Hetzner::Cloud::Location;
# ABSTRACT: Hetzner Cloud Location object

our $VERSION = '0.004';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $loc = $cloud->locations->get_by_name('fsn1');

    print $loc->name, "\n";         # fsn1
    print $loc->city, "\n";         # Falkenstein
    print $loc->country, "\n";      # DE
    print $loc->network_zone, "\n"; # eu-central

=head1 DESCRIPTION

This class represents a Hetzner Cloud location (physical data center site).
Objects are returned by L<WWW::Hetzner::Cloud::API::Locations> methods.

Locations are read-only resources.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Location ID.

=cut

has name => ( is => 'ro' );

=attr name

Location name, e.g. "fsn1", "nbg1", "hel1".

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has city => ( is => 'ro' );

=attr city

City name, e.g. "Falkenstein".

=cut

has country => ( is => 'ro' );

=attr country

Country code, e.g. "DE".

=cut

has network_zone => ( is => 'ro' );

=attr network_zone

Network zone, e.g. "eu-central".

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        description  => $self->description,
        city         => $self->city,
        country      => $self->country,
        network_zone => $self->network_zone,
    };
}

=method data

    my $hashref = $loc->data;

Returns all location data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Locations> - Locations API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Server> - Server entity

=item * L<WWW::Hetzner::Cloud::Datacenter> - Datacenter entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
