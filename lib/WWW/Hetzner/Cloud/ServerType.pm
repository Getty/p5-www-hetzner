package WWW::Hetzner::Cloud::ServerType;
# ABSTRACT: Hetzner Cloud ServerType object

our $VERSION = '0.004';

use Moo;
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

has deprecated => ( is => 'ro' );

=attr deprecated

Deprecation timestamp if deprecated, undef otherwise.

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
