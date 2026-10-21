package WWW::Hetzner::Storage::API::Actions;
# ABSTRACT: Hetzner Storage Box Actions API

our $VERSION = '0.103';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $actions = $storage->actions->list_all(status => 'running');
    my $action = $storage->actions->get($id);

=head1 DESCRIPTION

Reads Storage Box actions. A controller bound to a Storage Box lists only
that box's actions, while action lookup and action polling always use the
global Storage Box action endpoint.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has storage_box_id => ( is => 'ro' );

with 'WWW::Hetzner::Role::HasActions';
with 'WWW::Hetzner::Role::Pagination';

has '+action_poll_path' => (
    default => sub { '/storage_boxes/actions' },
);

sub _base_path {
    my ($self) = @_;
    return defined $self->storage_box_id
        ? '/storage_boxes/' . $self->storage_box_id . '/actions'
        : '/storage_boxes/actions';
}

sub _list_page {
    my ($self, %params) = @_;

    my $result = $self->client->get($self->_base_path, params => \%params);
    return ($self->_wrap_actions($result->{actions} // []), $result->{meta});
}

=method list

    my $actions = $storage->actions->list(%query);
    my $box_actions = $box->actions->list(%query);

Returns one page of L<WWW::Hetzner::Action> objects. A box-bound controller
uses C</storage_boxes/{id}/actions>; the root controller uses
C</storage_boxes/actions>.

=cut

sub list {
    my ($self, %params) = @_;

    my ($entities) = $self->_list_page(%params);
    return $entities;
}

=method get

    my $action = $storage->actions->get($id);
    my $same_action = $box->actions->get($id);

Returns an action loaded from the global C</storage_boxes/actions/{id}>
endpoint, including from a box-bound controller.

=cut

sub get {
    my ($self, $id) = @_;
    croak 'Action ID required' unless $id;

    my $result = $self->client->get("/storage_boxes/actions/$id");
    return $self->_wrap_action($result->{action});
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage> - Storage client

=item * L<WWW::Hetzner::Action> - Action entity

=back

=cut

1;
