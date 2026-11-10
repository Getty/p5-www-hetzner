package WWW::Hetzner::Cloud::Image;
# ABSTRACT: Hetzner Cloud Image object

our $VERSION = '0.103';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $image = $cloud->images->get_by_name('debian-13');

    print $image->name, "\n";        # debian-13
    print $image->description, "\n"; # Debian 13
    print $image->type, "\n";        # system
    print $image->os_flavor, "\n";   # debian
    print $image->os_version, "\n";  # 13

=head1 DESCRIPTION

This class represents a Hetzner Cloud image. Objects are returned by
L<WWW::Hetzner::Cloud::API::Images> methods.

Images are read-only resources (snapshots and backups can be deleted via the API).

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Image ID.

=cut

has name => ( is => 'ro' );

=attr name

Image name, e.g. "debian-13".

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has type => ( is => 'ro' );

=attr type

Image type: system, snapshot, or backup.

=cut

has status => ( is => 'ro' );

=attr status

Image status: available or creating.

=cut

has os_flavor => ( is => 'ro' );

=attr os_flavor

OS flavor: debian, ubuntu, centos, fedora, etc.

=cut

has os_version => ( is => 'ro' );

=attr os_version

OS version string.

=cut

has architecture => ( is => 'ro' );

=attr architecture

CPU architecture: x86 or arm.

=cut

has disk_size => ( is => 'ro' );

=attr disk_size

Minimum disk size in GB.

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp.

=cut

has deprecated => ( is => 'lazy' );

=attr deprecated

Deprecation timestamp if deprecated, undef otherwise.

If the API sends a C<deprecated> field, its value is returned unchanged.
Otherwise the value is the C<announced> timestamp from L</deprecation>.

=cut

# A deprecated sent by the API is kept as is; without it, the announced
# timestamp of the deprecation stands in.
sub _build_deprecated {
    my ($self) = @_;
    my $deprecation = $self->deprecation;
    return $deprecation ? $deprecation->{announced} : undef;
}

has deprecation => ( is => 'ro' );

=attr deprecation

Deprecation hashref with C<announced> and C<unavailable_after> timestamps,
undef unless the image is deprecated.

=cut

has image_size => ( is => 'ro' );

=attr image_size

Size of the image file in the storage in GB, undef if the API does not
report one. For snapshots this is the value that costs are calculated from.

=cut

has protection => ( is => 'ro' );

=attr protection

Protection hashref with a C<delete> key: true if the image is protected
against deletion.

=cut

has bound_to => ( is => 'ro' );

=attr bound_to

ID of the server the image is bound to. Only set for images of type
C<backup>, undef otherwise.

=cut

has created_from => ( is => 'ro' );

=attr created_from

Hashref with C<id> and C<name> of the server the image was created from
(the name as it was when the image was created), undef for images that were
not created from a server.

=cut

has deleted => ( is => 'ro' );

=attr deleted

Timestamp of the deletion of the image, undef if it was not deleted.

=cut

has rapid_deploy => ( is => 'ro' );

=attr rapid_deploy

Whether rapid deploy is available for the image.

=cut

has labels => ( is => 'ro', default => sub { {} } );

=attr labels

Labels hash.

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        description  => $self->description,
        type         => $self->type,
        status       => $self->status,
        os_flavor    => $self->os_flavor,
        os_version   => $self->os_version,
        architecture => $self->architecture,
        disk_size    => $self->disk_size,
        created      => $self->created,
        deprecated   => $self->deprecated,
        deprecation  => $self->deprecation,
        image_size   => $self->image_size,
        protection   => $self->protection,
        bound_to     => $self->bound_to,
        created_from => $self->created_from,
        deleted      => $self->deleted,
        rapid_deploy => $self->rapid_deploy,
        labels       => $self->labels,
    };
}

=method data

    my $hashref = $image->data;

Returns all image data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Images> - Images API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Server> - Server entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
