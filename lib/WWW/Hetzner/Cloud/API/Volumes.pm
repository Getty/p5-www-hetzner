package WWW::Hetzner::Cloud::API::Volumes;
# ABSTRACT: Hetzner Cloud Volumes API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Volume;
use namespace::clean;

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List volumes
    my $volumes = $cloud->volumes->list;

    # Create volume
    my $volume = $cloud->volumes->create(
        name     => 'my-volume',
        size     => 50,           # GB
        location => 'fsn1',
        format   => 'ext4',       # optional
    );

    # Attach to server
    $cloud->volumes->attach($volume->id, $server_id);

    # Resize
    $cloud->volumes->resize($volume->id, 100);

    # Delete
    $cloud->volumes->delete($volume->id);

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud volumes.
All methods return L<WWW::Hetzner::Cloud::Volume> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Volume->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $volumes = $cloud->volumes->list;
    my $volumes = $cloud->volumes->list(label_selector => 'env=prod');

Returns arrayref of L<WWW::Hetzner::Cloud::Volume> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/volumes', params => \%params);
    return $self->_wrap_list($result->{volumes} // []);
}

=method get

    my $volume = $cloud->volumes->get($id);

Returns L<WWW::Hetzner::Cloud::Volume> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Volume ID required" unless $id;

    my $result = $self->client->get("/volumes/$id");
    return $self->_wrap($result->{volume});
}

=method create

    my $volume = $cloud->volumes->create(
        name     => 'my-volume',  # required
        size     => 50,           # required (GB)
        location => 'fsn1',       # required
        format   => 'ext4',       # optional
        labels   => { ... },      # optional
        automount => 1,           # optional
        server   => $server_id,   # optional
    );

Creates volume. Returns L<WWW::Hetzner::Cloud::Volume> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "size required" unless $params{size};
    croak "location required" unless $params{location};

    my $body = {
        name     => $params{name},
        size     => $params{size},
        location => $params{location},
    };

    $body->{format}    = $params{format}    if $params{format};
    $body->{labels}    = $params{labels}    if $params{labels};
    $body->{automount} = $params{automount} if exists $params{automount};
    $body->{server}    = $params{server}    if $params{server};

    my $result = $self->client->post('/volumes', $body);
    return $self->_wrap($result->{volume});
}

=method delete

    $cloud->volumes->delete($id);

Deletes volume.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "Volume ID required" unless $id;

    return $self->client->delete("/volumes/$id");
}

=method attach

    $cloud->volumes->attach($volume_id, $server_id, automount => 1);

Attaches volume to server.

=cut

sub attach {
    my ($self, $id, $server_id, %opts) = @_;
    croak "Volume ID required" unless $id;
    croak "Server ID required" unless $server_id;

    my $body = { server => $server_id };
    $body->{automount} = $opts{automount} ? \1 : \0 if exists $opts{automount};

    return $self->client->post("/volumes/$id/actions/attach", $body);
}

=method detach

    $cloud->volumes->detach($volume_id);

Detaches volume.

=cut

sub detach {
    my ($self, $id) = @_;
    croak "Volume ID required" unless $id;

    return $self->client->post("/volumes/$id/actions/detach", {});
}

=method resize

    $cloud->volumes->resize($volume_id, $size);

Resizes volume to the specified size in GB.

=cut

sub resize {
    my ($self, $id, $size) = @_;
    croak "Volume ID required" unless $id;
    croak "Size required" unless $size;

    return $self->client->post("/volumes/$id/actions/resize", { size => $size });
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Volume> - Volume entity class

=item * L<WWW::Hetzner::CLI::Cmd::Volume> - Volume CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
