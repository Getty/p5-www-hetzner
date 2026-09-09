package WWW::Hetzner::Storage::API::StorageBoxes;
# ABSTRACT: Hetzner Storage Boxes API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Storage::StorageBox;
use namespace::clean;

=head1 SYNOPSIS

    my $boxes = $storage->storage_boxes;
    my $box = $boxes->create(
        name             => 'my-box',
        location         => 'fsn1',
        storage_box_type => 'bx20',
        password         => 'secret',
    );

=head1 DESCRIPTION

Manages Hetzner Storage Boxes and the actions performed on them.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

with 'WWW::Hetzner::Role::HasActions';
with 'WWW::Hetzner::Role::Pagination';

has '+action_poll_path' => (
    default => sub { '/storage_boxes/actions' },
);

sub _wrap {
    my ($self, $data, %extra) = @_;
    return WWW::Hetzner::Storage::StorageBox->new(
        client => $self->client,
        %$data,
        %extra,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @{ $list // [] } ];
}

sub _list_page {
    my ($self, %params) = @_;

    my $result = $self->client->get('/storage_boxes', params => \%params);
    return ($self->_wrap_list($result->{storage_boxes} // []), $result->{meta});
}

=method list

    my $boxes = $storage->storage_boxes->list(%query);

Returns one page of L<WWW::Hetzner::Storage::StorageBox> objects. The API
accepts C<name>, C<label_selector>, C<sort>, C<page>, and C<per_page>.

=cut

sub list {
    my ($self, %params) = @_;

    my ($entities) = $self->_list_page(%params);
    return $entities;
}

=method get

    my $box = $storage->storage_boxes->get($id);

Returns a L<WWW::Hetzner::Storage::StorageBox>.

=cut

sub get {
    my ($self, $id) = @_;
    croak 'Storage Box ID required' unless $id;

    my $result = $self->client->get("/storage_boxes/$id");
    return $self->_wrap($result->{storage_box});
}

=method get_by_name

    my $box = $storage->storage_boxes->get_by_name('my-box');

Returns the Storage Box of the supplied name, or undef when none exists.

=cut

sub get_by_name {
    my ($self, $name) = @_;
    croak 'Name required' unless $name;

    my $boxes = $self->list_all(name => $name);
    for my $box (@$boxes) {
        return $box if $box->name eq $name;
    }
    return;
}

=method create

    my $box = $storage->storage_boxes->create(%params);

Creates a Storage Box. C<name>, C<location>, C<storage_box_type>, and
C<password> are required. Returns a Storage Box with its creation C<action>.

=cut

sub create {
    my ($self, %params) = @_;

    for my $field (qw(name location storage_box_type password)) {
        croak "$field required" unless defined $params{$field} && length $params{$field};
    }

    my $body = {
        name             => $params{name},
        location         => $params{location},
        storage_box_type => $params{storage_box_type},
        password         => $params{password},
    };
    for my $field (qw(labels ssh_keys access_settings)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }

    my $result = $self->client->post('/storage_boxes', $body);
    return $self->_wrap(
        $result->{storage_box},
        action => $self->_wrap_action($result->{action}),
    );
}

=method update

    my $box = $storage->storage_boxes->update($id, %params);

Updates a Storage Box's C<name> and/or C<labels>. Returns the updated
L<WWW::Hetzner::Storage::StorageBox>, without an action.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak 'Storage Box ID required' unless $id;

    my $body = {};
    for my $field (qw(name labels)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }

    my $result = $self->client->put("/storage_boxes/$id", $body);
    return $self->_wrap($result->{storage_box});
}

=method delete

    my $action = $storage->storage_boxes->delete($id);

Deletes a Storage Box and returns its L<WWW::Hetzner::Action>.

=cut

sub delete {
    my ($self, $id) = @_;
    croak 'Storage Box ID required' unless $id;

    my $result = $self->client->delete("/storage_boxes/$id");
    return $self->_wrap_action($result->{action});
}

=method folders

    my $folders = $storage->storage_boxes->folders($id, path => '/');

Returns an arrayref of folder-name strings.

=cut

sub folders {
    my ($self, $id, %params) = @_;
    croak 'Storage Box ID required' unless $id;

    my $result = $self->client->get("/storage_boxes/$id/folders", params => \%params);
    return $result->{folders} // [];
}

sub _action {
    my ($self, $id, $name, $body) = @_;
    croak 'Storage Box ID required' unless $id;

    my $result = $self->client->post("/storage_boxes/$id/actions/$name", $body);
    return $self->_wrap_action($result->{action});
}

=method change_protection

    my $action = $storage->storage_boxes->change_protection($id, delete => 1);

Changes delete protection and returns its action.

=cut

sub change_protection {
    my ($self, $id, %params) = @_;
    my $body = {};
    $body->{delete} = $params{delete} if exists $params{delete};
    return $self->_action($id, 'change_protection', $body);
}

=method change_type

    my $action = $storage->storage_boxes->change_type(
        $id, storage_box_type => 'bx11',
    );

Changes the Storage Box type and returns its action.

=cut

sub change_type {
    my ($self, $id, %params) = @_;
    croak 'storage_box_type required' unless $params{storage_box_type};
    return $self->_action($id, 'change_type', {
        storage_box_type => $params{storage_box_type},
    });
}

=method reset_password

    my $action = $storage->storage_boxes->reset_password($id, password => 'secret');

Resets a Storage Box password and returns its action.

=cut

sub reset_password {
    my ($self, $id, %params) = @_;
    croak 'password required' unless $params{password};
    return $self->_action($id, 'reset_password', { password => $params{password} });
}

=method update_access_settings

    my $action = $storage->storage_boxes->update_access_settings($id, %settings);

Updates access settings and returns its action.

=cut

sub update_access_settings {
    my ($self, $id, %params) = @_;
    my $body = {};
    for my $field (qw(reachable_externally samba_enabled ssh_enabled webdav_enabled zfs_enabled)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }
    return $self->_action($id, 'update_access_settings', $body);
}

=method rollback_snapshot

    my $action = $storage->storage_boxes->rollback_snapshot($id, snapshot => $snapshot_id);

Rolls a Storage Box back to a snapshot and returns its action.

=cut

sub rollback_snapshot {
    my ($self, $id, %params) = @_;
    croak 'snapshot required' unless $params{snapshot};
    return $self->_action($id, 'rollback_snapshot', { snapshot => $params{snapshot} });
}

=method enable_snapshot_plan

    my $action = $storage->storage_boxes->enable_snapshot_plan($id, %schedule);

Enables a snapshot plan and returns its action. C<max_snapshots>, C<minute>,
and C<hour> are required.

=cut

sub enable_snapshot_plan {
    my ($self, $id, %params) = @_;
    for my $field (qw(max_snapshots minute hour)) {
        croak "$field required" unless exists $params{$field};
    }

    my $body = {
        max_snapshots => $params{max_snapshots},
        minute        => $params{minute},
        hour          => $params{hour},
    };
    for my $field (qw(day_of_week day_of_month)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }
    return $self->_action($id, 'enable_snapshot_plan', $body);
}

=method disable_snapshot_plan

    my $action = $storage->storage_boxes->disable_snapshot_plan($id);

Disables a snapshot plan and returns its action.

=cut

sub disable_snapshot_plan {
    my ($self, $id) = @_;
    return $self->_action($id, 'disable_snapshot_plan', {});
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage> - Storage client

=item * L<WWW::Hetzner::Storage::StorageBox> - Storage Box entity

=back

=cut

1;
