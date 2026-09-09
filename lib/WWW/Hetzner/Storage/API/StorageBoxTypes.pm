package WWW::Hetzner::Storage::API::StorageBoxTypes;
# ABSTRACT: Hetzner Storage Box Types API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Storage::StorageBoxType;
use namespace::clean;

=head1 SYNOPSIS

    my $types = $storage->storage_box_types->list_all;
    my $type = $storage->storage_box_types->get_by_name('bx20');

=head1 DESCRIPTION

Reads the available Hetzner Storage Box types.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

with 'WWW::Hetzner::Role::Pagination';

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Storage::StorageBoxType->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @{ $list // [] } ];
}

sub _list_page {
    my ($self, %params) = @_;

    my $result = $self->client->get('/storage_box_types', params => \%params);
    return ($self->_wrap_list($result->{storage_box_types} // []), $result->{meta});
}

=method list

    my $types = $storage->storage_box_types->list(%query);

Returns one page of L<WWW::Hetzner::Storage::StorageBoxType> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my ($entities) = $self->_list_page(%params);
    return $entities;
}

=method get

    my $type = $storage->storage_box_types->get($id);

Returns a L<WWW::Hetzner::Storage::StorageBoxType>.

=cut

sub get {
    my ($self, $id) = @_;
    croak 'Storage Box Type ID required' unless $id;

    my $result = $self->client->get("/storage_box_types/$id");
    return $self->_wrap($result->{storage_box_type});
}

=method get_by_name

    my $type = $storage->storage_box_types->get_by_name('bx20');

Returns the type of the supplied name, or undef when none exists.

=cut

sub get_by_name {
    my ($self, $name) = @_;
    croak 'Name required' unless $name;

    my $types = $self->list_all(name => $name);
    for my $type (@$types) {
        return $type if $type->name eq $name;
    }
    return;
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage> - Storage client

=item * L<WWW::Hetzner::Storage::StorageBoxType> - Storage Box Type entity

=back

=cut

1;
