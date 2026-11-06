package WWW::Hetzner::Cloud::ServerType;
# ABSTRACT: Hetzner Cloud ServerType object

our $VERSION = '0.103';

use Moo;
use JSON::MaybeXS qw(JSON);
use namespace::clean;

=head1 SYNOPSIS

    my $type = $cloud->server_types->get_by_name('cx22');

    print $type->name, "\n";         # cx22
    print $type->cores, "\n";        # 2
    print $type->memory, "\n";       # 4
    print $type->disk, "\n";         # 40
    print $type->architecture, "\n"; # x86

=head1 DESCRIPTION

This class represents a Hetzner Cloud server type (CPU/memory/disk configuration).
Objects are returned by L<WWW::Hetzner::Cloud::API::ServerTypes> methods.

Server types are read-only resources.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Server type ID.

=cut

has name => ( is => 'ro' );

=attr name

Server type name, e.g. "cx22", "cpx31".

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has cores => ( is => 'ro' );

=attr cores

Number of CPU cores.

=cut

has memory => ( is => 'ro' );

=attr memory

Memory in GB.

=cut

has disk => ( is => 'ro' );

=attr disk

Disk size in GB.

=cut

has cpu_type => ( is => 'ro' );

=attr cpu_type

CPU type: shared or dedicated.

=cut

has architecture => ( is => 'ro' );

=attr architecture

CPU architecture: x86 or arm.

=cut

has deprecated => ( is => 'lazy' );

=attr deprecated

Whether the server type is deprecated.

The API dropped this top-level field on 2026-11-02. If a response still
carries it, the value is returned unchanged. Otherwise it is derived from
L</locations>: true when the server type is deprecated (has a C<deprecation>)
in every location it is offered in, false when at least one location has none
or the server type is offered nowhere.

A server type that is deprecated in only some locations therefore counts as
not deprecated here. To find out whether it can be used in a given location,
check the C<deprecation> of that location's entry in L</locations>.

=cut

# A deprecated sent by the API is kept as is. Without it, the type counts as
# deprecated when it is deprecated in every location it is offered in.
sub _build_deprecated {
    my ($self) = @_;
    my @locations = @{ $self->locations };
    return JSON()->false unless @locations;
    return ( grep { !defined $_->{deprecation} } @locations )
        ? JSON()->false
        : JSON()->true;
}

has locations => ( is => 'ro', default => sub { [] } );

=attr locations

Arrayref of location data hashrefs (read-only), one entry per location the
server type is offered in. Each entry has these keys:

=over 4

=item C<id>

ID of the location.

=item C<name>

Location name, e.g. "fsn1".

=item C<deprecation>

Hashref with C<announced> and C<unavailable_after> timestamps, undef if the
server type is not deprecated in this location.

=item C<recommended>

Whether Hetzner recommends the server type in this location.

=item C<available>

False if the server type is temporarily not orderable in this location.

=back

A server type can be ordered in location L when the entry for L has a true
C<available> and either no C<deprecation> or a C<deprecation> whose
C<unavailable_after> still lies in the future. An entry with a C<deprecation>
marks the server type as being phased out in that location.

C<available> replaces the availability the datacenter used to deliver in
C<server_types.available>; the datacenter endpoints are gone.

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        description  => $self->description,
        cores        => $self->cores,
        memory       => $self->memory,
        disk         => $self->disk,
        cpu_type     => $self->cpu_type,
        architecture => $self->architecture,
        deprecated   => $self->deprecated,
        locations    => $self->locations,
    };
}

=method data

    my $hashref = $type->data;

Returns all server type data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::ServerTypes> - Server Types API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Server> - Server entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
