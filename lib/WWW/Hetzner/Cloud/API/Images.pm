package WWW::Hetzner::Cloud::API::Images;
# ABSTRACT: Hetzner Cloud Images API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Image;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all images
    my $images = $cloud->images->list;

    # Filter by type
    my $snapshots = $cloud->images->list(type => 'snapshot');

    # Get by name
    my $debian = $cloud->images->get_by_name('debian-13');
    printf "Image: %s (%s)\n", $debian->name, $debian->description;

=head1 DESCRIPTION

This module provides access to Hetzner Cloud images. Images can be system
images (provided by Hetzner), snapshots (user-created), or backups.
All methods return L<WWW::Hetzner::Cloud::Image> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Image->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $images = $cloud->images->list;
    my $images = $cloud->images->list(type => 'system');

Returns an arrayref of L<WWW::Hetzner::Cloud::Image> objects. Optional parameters:

=over 4

=item * type - Filter by type: system, snapshot, backup

=item * status - Filter by status: available, creating

=item * name - Filter by name

=back

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/images', params => \%params);
    return $self->_wrap_list($result->{images} // []);
}

=method get

    my $image = $cloud->images->get($id);

Returns a L<WWW::Hetzner::Cloud::Image> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Image ID required" unless $id;

    my $result = $self->client->get("/images/$id");
    return $self->_wrap($result->{image});
}

=method get_by_name

    my $image = $cloud->images->get_by_name('debian-13');

Returns a L<WWW::Hetzner::Cloud::Image> object. Returns undef if not found.

=cut

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $images = $self->list;
    for my $image (@$images) {
        return $image if $image->name eq $name;
    }
    return;
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Image> - Image entity class

=item * L<WWW::Hetzner::CLI::Cmd::Image> - Image CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
