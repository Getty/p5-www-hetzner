package WWW::Hetzner::Cloud::ServerType;

# ABSTRACT: Hetzner Cloud ServerType object

use Moo;
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'ro' );
has description => ( is => 'ro' );
has cores => ( is => 'ro' );
has memory => ( is => 'ro' );
has disk => ( is => 'ro' );
has cpu_type => ( is => 'ro' );
has architecture => ( is => 'ro' );
has deprecated => ( is => 'ro' );

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::ServerType - Hetzner Cloud Server Type object

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

=head1 ATTRIBUTES

=head2 id

Server type ID.

=head2 name

Server type name, e.g. "cx22", "cpx31".

=head2 description

Human-readable description.

=head2 cores

Number of CPU cores.

=head2 memory

Memory in GB.

=head2 disk

Disk size in GB.

=head2 cpu_type

CPU type: shared or dedicated.

=head2 architecture

CPU architecture: x86 or arm.

=head2 deprecated

Deprecation timestamp if deprecated, undef otherwise.

=head1 METHODS

=head2 data

    my $hashref = $type->data;

Returns all server type data as a hashref (for JSON serialization).

=cut
