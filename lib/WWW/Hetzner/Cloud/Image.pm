package WWW::Hetzner::Cloud::Image;
# ABSTRACT: Hetzner Cloud Image object

our $VERSION = '0.003';

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

has deprecated => ( is => 'ro' );

=attr deprecated

Deprecation timestamp if deprecated, undef otherwise.

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
