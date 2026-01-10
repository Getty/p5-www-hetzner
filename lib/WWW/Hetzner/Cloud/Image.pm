package WWW::Hetzner::Cloud::Image;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Image object

use Moo;
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'ro' );
has description => ( is => 'ro' );
has type => ( is => 'ro' );
has status => ( is => 'ro' );
has os_flavor => ( is => 'ro' );
has os_version => ( is => 'ro' );
has architecture => ( is => 'ro' );
has disk_size => ( is => 'ro' );
has created => ( is => 'ro' );
has deprecated => ( is => 'ro' );
has labels => ( is => 'ro', default => sub { {} } );

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Image - Hetzner Cloud Image object

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

=head1 ATTRIBUTES

=head2 id

Image ID.

=head2 name

Image name, e.g. "debian-13".

=head2 description

Human-readable description.

=head2 type

Image type: system, snapshot, or backup.

=head2 status

Image status: available or creating.

=head2 os_flavor

OS flavor: debian, ubuntu, centos, fedora, etc.

=head2 os_version

OS version string.

=head2 architecture

CPU architecture: x86 or arm.

=head2 disk_size

Minimum disk size in GB.

=head2 created

Creation timestamp.

=head2 deprecated

Deprecation timestamp if deprecated, undef otherwise.

=head2 labels

Labels hash.

=head1 METHODS

=head2 data

    my $hashref = $image->data;

Returns all image data as a hashref (for JSON serialization).

=cut
