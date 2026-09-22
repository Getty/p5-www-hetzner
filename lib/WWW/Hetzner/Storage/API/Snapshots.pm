package WWW::Hetzner::Storage::API::Snapshots;
# ABSTRACT: Hetzner Storage Box Snapshots API

our $VERSION = '0.102';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Storage::Snapshot;
use namespace::clean;

=head1 SYNOPSIS

    my $snapshots = $box->snapshots;
    my $snapshot = $snapshots->create(description => 'before upgrade');

=head1 DESCRIPTION

Manages snapshots within one Storage Box.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has storage_box_id => (
    is       => 'ro',
    required => 1,
);

with 'WWW::Hetzner::Role::HasActions';

has '+action_poll_path' => (
    default => sub { '/storage_boxes/actions' },
);

sub _base_path {
    my ($self) = @_;
    return '/storage_boxes/' . $self->storage_box_id . '/snapshots';
}

sub _wrap {
    my ($self, $data, %extra) = @_;
    return WWW::Hetzner::Storage::Snapshot->new(
        client         => $self->client,
        storage_box_id => $self->storage_box_id,
        %$data,
        %extra,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @{ $list // [] } ];
}

=method list

    my $snapshots = $box->snapshots->list(%query);

Returns an arrayref of L<WWW::Hetzner::Storage::Snapshot> objects. The API
accepts C<name>, C<label_selector>, C<sort>, and C<is_automatic> filters.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get($self->_base_path, params => \%params);
    return $self->_wrap_list($result->{snapshots} // []);
}

=method get

    my $snapshot = $box->snapshots->get($id);

Returns a L<WWW::Hetzner::Storage::Snapshot>.

=cut

sub get {
    my ($self, $id) = @_;
    croak 'Snapshot ID required' unless $id;

    my $result = $self->client->get($self->_base_path . "/$id");
    return $self->_wrap($result->{snapshot});
}

=method create

    my $snapshot = $box->snapshots->create(%params);

Creates a snapshot. C<description> and C<labels> are optional. Returns a
Snapshot with its creation action.

=cut

sub create {
    my ($self, %params) = @_;

    my $body = {};
    for my $field (qw(description labels)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }

    my $result = $self->client->post($self->_base_path, $body);
    return $self->_wrap(
        $result->{snapshot},
        action => $self->_wrap_action($result->{action}),
    );
}

=method update

    my $snapshot = $box->snapshots->update($id, %params);

Updates a snapshot's C<description> and/or C<labels>. Returns the updated
Snapshot without an action.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak 'Snapshot ID required' unless $id;

    my $body = {};
    for my $field (qw(description labels)) {
        $body->{$field} = $params{$field} if exists $params{$field};
    }

    my $result = $self->client->put($self->_base_path . "/$id", $body);
    return $self->_wrap($result->{snapshot});
}

=method delete

    my $action = $box->snapshots->delete($id);

Deletes a snapshot and returns its action.

=cut

sub delete {
    my ($self, $id) = @_;
    croak 'Snapshot ID required' unless $id;

    my $result = $self->client->delete($self->_base_path . "/$id");
    return $self->_wrap_action($result->{action});
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage::StorageBox> - Parent Storage Box entity

=item * L<WWW::Hetzner::Storage::Snapshot> - Snapshot entity

=back

=cut

1;
