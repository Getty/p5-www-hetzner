package WWW::Hetzner::Cloud::PlacementGroup;
# ABSTRACT: Hetzner Cloud Placement Group object

our $VERSION = '0.002';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $pg = $cloud->placement_groups->get($id);

    print $pg->name, "\n";
    print $pg->type, "\n";  # spread
    print scalar(@{$pg->servers}), " servers\n";

    # Update
    $pg->name('new-name');
    $pg->update;

    # Delete
    $pg->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud placement group. Objects are returned by
L<WWW::Hetzner::Cloud::API::PlacementGroups> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Placement group ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Placement group name (read-write).

=cut

has type => ( is => 'ro' );

=attr type

Placement group type, e.g. "spread" (read-only).

=cut

has servers => ( is => 'ro', default => sub { [] } );

=attr servers

Arrayref of server IDs in this placement group (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update placement group without ID" unless $self->id;

    $self->_client->put("/placement_groups/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $pg->name('new-name');
    $pg->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete placement group without ID" unless $self->id;

    $self->_client->delete("/placement_groups/" . $self->id);
    return 1;
}

=method delete

    $pg->delete;

Deletes the placement group.

=cut

sub data {
    my ($self) = @_;
    return {
        id      => $self->id,
        name    => $self->name,
        type    => $self->type,
        servers => $self->servers,
        labels  => $self->labels,
        created => $self->created,
    };
}

=method data

    my $hashref = $pg->data;

Returns all placement group data as a hashref (for JSON serialization).

=cut

1;
