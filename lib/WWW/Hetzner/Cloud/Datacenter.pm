package WWW::Hetzner::Cloud::Datacenter;
# ABSTRACT: Hetzner Cloud Datacenter object

our $VERSION = '0.002';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $dc = $cloud->datacenters->get_by_name('fsn1-dc14');

    print $dc->name, "\n";        # fsn1-dc14
    print $dc->description, "\n"; # Falkenstein 1 DC14
    print $dc->location, "\n";    # fsn1

=head1 DESCRIPTION

This class represents a Hetzner Cloud datacenter (virtual subdivision of a location).
Objects are returned by L<WWW::Hetzner::Cloud::API::Datacenters> methods.

Datacenters are read-only resources.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Datacenter ID.

=cut

has name => ( is => 'ro' );

=attr name

Datacenter name, e.g. "fsn1-dc14".

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has location_data => ( is => 'ro', init_arg => 'location', default => sub { {} } );

sub location { shift->location_data->{name} }

=method location

Location name (convenience accessor).

=cut

sub data {
    my ($self) = @_;
    return {
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        location    => $self->location_data,
    };
}

=method data

    my $hashref = $dc->data;

Returns all datacenter data as a hashref (for JSON serialization).

=cut

1;
