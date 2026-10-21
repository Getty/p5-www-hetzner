package WWW::Hetzner::Storage::StorageBox;
# ABSTRACT: Hetzner Storage Box object

our $VERSION = '0.103';

use Moo;
with 'WWW::Hetzner::Role::HasAction';
use Carp qw(croak);
use WWW::Hetzner::Storage::API::Actions;
use WWW::Hetzner::Storage::API::Snapshots;
use WWW::Hetzner::Storage::API::Subaccounts;
use namespace::clean;

=head1 SYNOPSIS

    my $box = $storage->storage_boxes->get($id);
    $box->name('renamed-box');
    my $updated = $box->update;

    my $subaccounts = $box->subaccounts;
    my $snapshots = $box->snapshots;

=head1 DESCRIPTION

Represents a Hetzner Storage Box returned by
L<WWW::Hetzner::Storage::API::StorageBoxes>.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id                => ( is => 'ro' );
has name              => ( is => 'rw' );
has storage_box_type  => ( is => 'ro' );
has location          => ( is => 'ro' );
has access_settings   => ( is => 'ro' );
has snapshot_plan     => ( is => 'ro' );
has protection        => ( is => 'ro' );
has labels            => ( is => 'rw' );
has status            => ( is => 'ro' );
has username          => ( is => 'ro' );
has server            => ( is => 'ro' );
has system            => ( is => 'ro' );
has stats             => ( is => 'ro' );
has created           => ( is => 'ro' );

=attr id

Storage Box ID (read-only).

=cut

=attr name

Storage Box name (read-write).

=cut

=attr storage_box_type

Storage Box Type data (read-only).

=cut

=attr location

Location data (read-only).

=cut

=attr access_settings

Access settings data (read-only).

=cut

=attr snapshot_plan

Snapshot-plan data, or undef when no plan is configured (read-only).

=cut

=attr protection

Protection settings data (read-only).

=cut

=attr labels

Labels hashref (read-write).

=cut

=attr status

Storage Box status (read-only).

=cut

=attr username

Storage Box username, or undef (read-only).

=cut

=attr server

Storage Box server data, or undef (read-only).

=cut

=attr system

Storage Box system data, or undef (read-only).

=cut

=attr stats

Storage Box statistics data (read-only).

=cut

=attr created

Creation timestamp (read-only).

=cut

sub _require_id {
    my ($self) = @_;
    croak 'Cannot use Storage Box without ID' unless $self->id;
}

=method update

    my $updated = $box->update;

Saves the object's current name and labels. Returns the updated Storage Box.

=cut

sub update {
    my ($self) = @_;
    $self->_require_id;

    return $self->_client->storage_boxes->update(
        $self->id,
        name   => $self->name,
        labels => $self->labels,
    );
}

=method delete

    my $action = $box->delete;

Deletes this Storage Box and returns its action.

=cut

sub delete {
    my ($self) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->delete($self->id);
}

=method folders

    my $folders = $box->folders(path => '/');

Returns an arrayref of folder-name strings.

=cut

sub folders {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->folders($self->id, %params);
}

=method actions

    my $actions = $box->actions->list;

Returns an L<WWW::Hetzner::Storage::API::Actions> controller bound to this
Storage Box.

=cut

sub actions {
    my ($self) = @_;
    $self->_require_id;

    return WWW::Hetzner::Storage::API::Actions->new(
        client         => $self->_client,
        storage_box_id => $self->id,
    );
}

=method subaccounts

    my $subaccounts = $box->subaccounts;

Returns an L<WWW::Hetzner::Storage::API::Subaccounts> controller bound to this
Storage Box.

=cut

sub subaccounts {
    my ($self) = @_;
    $self->_require_id;

    return WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $self->_client,
        storage_box_id => $self->id,
    );
}

=method snapshots

    my $snapshots = $box->snapshots;

Returns an L<WWW::Hetzner::Storage::API::Snapshots> controller bound to this
Storage Box.

=cut

sub snapshots {
    my ($self) = @_;
    $self->_require_id;

    return WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $self->_client,
        storage_box_id => $self->id,
    );
}

=method change_protection

    my $action = $box->change_protection(delete => 1);

Changes delete protection and returns its action.

=cut

sub change_protection {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->change_protection($self->id, %params);
}

=method change_type

    my $action = $box->change_type(storage_box_type => 'bx11');

Changes the Storage Box type and returns its action.

=cut

sub change_type {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->change_type($self->id, %params);
}

=method reset_password

    my $action = $box->reset_password(password => 'secret');

Resets a Storage Box password and returns its action.

=cut

sub reset_password {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->reset_password($self->id, %params);
}

=method update_access_settings

    my $action = $box->update_access_settings(%settings);

Updates access settings and returns its action.

=cut

sub update_access_settings {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->update_access_settings($self->id, %params);
}

=method rollback_snapshot

    my $action = $box->rollback_snapshot(snapshot => $snapshot_id);

Rolls a Storage Box back to a snapshot and returns its action.

=cut

sub rollback_snapshot {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->rollback_snapshot($self->id, %params);
}

=method enable_snapshot_plan

    my $action = $box->enable_snapshot_plan(%schedule);

Enables a snapshot plan and returns its action. C<max_snapshots>, C<minute>,
and C<hour> are required.

=cut

sub enable_snapshot_plan {
    my ($self, %params) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->enable_snapshot_plan($self->id, %params);
}

=method disable_snapshot_plan

    my $action = $box->disable_snapshot_plan;

Disables a snapshot plan and returns its action.

=cut

sub disable_snapshot_plan {
    my ($self) = @_;
    $self->_require_id;
    return $self->_client->storage_boxes->disable_snapshot_plan($self->id);
}

=method data

    my $hashref = $box->data;

Returns the complete Storage Box representation returned by the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id               => $self->id,
        name             => $self->name,
        storage_box_type => $self->storage_box_type,
        location         => $self->location,
        access_settings  => $self->access_settings,
        snapshot_plan    => $self->snapshot_plan,
        protection       => $self->protection,
        labels           => $self->labels,
        status           => $self->status,
        username         => $self->username,
        server           => $self->server,
        system           => $self->system,
        stats            => $self->stats,
        created          => $self->created,
    };
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage::API::StorageBoxes> - Storage Box controller

=item * L<WWW::Hetzner::Storage> - Storage client

=back

=cut

1;
