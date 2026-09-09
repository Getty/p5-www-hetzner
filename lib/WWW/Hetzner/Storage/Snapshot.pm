package WWW::Hetzner::Storage::Snapshot;
# ABSTRACT: Hetzner Storage Box Snapshot object

our $VERSION = '0.101';

use Moo;
with 'WWW::Hetzner::Role::HasAction';
use Carp qw(croak);
use WWW::Hetzner::Storage::API::Snapshots;
use namespace::clean;

=head1 SYNOPSIS

    my $snapshot = $box->snapshots->get($id);
    $snapshot->description('before upgrade');
    my $updated = $snapshot->update;

=head1 DESCRIPTION

Represents a Storage Box snapshot returned by
L<WWW::Hetzner::Storage::API::Snapshots>.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has _storage_box_id => (
    is       => 'ro',
    required => 1,
    init_arg => 'storage_box_id',
);

has id           => ( is => 'ro' );
has storage_box  => ( is => 'ro' );
has name         => ( is => 'ro' );
has description  => ( is => 'rw' );
has labels       => ( is => 'rw' );
has stats        => ( is => 'ro' );
has is_automatic => ( is => 'ro' );
has created      => ( is => 'ro' );

=attr id

Snapshot ID (read-only).

=cut

=attr storage_box

ID of the parent Storage Box (read-only).

=cut

=attr name

Snapshot name (read-only).

=cut

=attr description

Snapshot description (read-write).

=cut

=attr labels

Labels hashref (read-write).

=cut

=attr stats

Snapshot statistics data (read-only).

=cut

=attr is_automatic

True when the snapshot was created by a snapshot plan (read-only).

=cut

=attr created

Creation timestamp (read-only).

=cut

sub _require_id {
    my ($self) = @_;
    croak 'Cannot use snapshot without ID' unless $self->id;
}

sub _controller {
    my ($self) = @_;
    return WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $self->_client,
        storage_box_id => $self->_storage_box_id,
    );
}

=method update

    my $updated = $snapshot->update;

Saves the object's current description and labels. Returns the updated
Snapshot.

=cut

sub update {
    my ($self) = @_;
    $self->_require_id;

    return $self->_controller->update(
        $self->id,
        description => $self->description,
        labels      => $self->labels,
    );
}

=method delete

    my $action = $snapshot->delete;

Deletes this snapshot and returns its action.

=cut

sub delete {
    my ($self) = @_;
    $self->_require_id;
    return $self->_controller->delete($self->id);
}

=method data

    my $hashref = $snapshot->data;

Returns the complete Snapshot representation returned by the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        storage_box  => $self->storage_box,
        name         => $self->name,
        description  => $self->description,
        labels       => $self->labels,
        stats        => $self->stats,
        is_automatic => $self->is_automatic,
        created      => $self->created,
    };
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage::API::Snapshots> - Snapshot controller

=item * L<WWW::Hetzner::Storage::StorageBox> - Parent Storage Box entity

=back

=cut

1;
