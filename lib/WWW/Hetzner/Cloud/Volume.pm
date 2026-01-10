package WWW::Hetzner::Cloud::Volume;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Volume object

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $volume = $cloud->volumes->get($id);

    # Read attributes
    print $volume->id, "\n";
    print $volume->name, "\n";
    print $volume->size, " GB\n";
    print $volume->linux_device, "\n";

    # Attach to server
    $volume->attach($server_id);
    $volume->detach;

    # Resize
    $volume->resize(100);  # 100 GB

    # Update
    $volume->name('new-name');
    $volume->update;

    # Delete
    $volume->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud volume. Objects are returned by
L<WWW::Hetzner::Cloud::API::Volumes> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Volume ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Volume name (read-write).

=cut

has status => ( is => 'rwp' );

=attr status

Volume status (read-only).

=cut

has size => ( is => 'ro' );

=attr size

Volume size in GB (read-only).

=cut

has server => ( is => 'ro' );

=attr server

Attached server ID, or undef if not attached (read-only).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has linux_device => ( is => 'ro' );

=attr linux_device

Linux device path, e.g. "/dev/disk/by-id/scsi-0HC_Volume_123" (read-only).

=cut

has format => ( is => 'ro' );

=attr format

Filesystem format, e.g. "ext4" (read-only).

=cut

has protection => ( is => 'ro', default => sub { {} } );

=attr protection

Protection settings hash (read-only).

=cut

# Nested data
has location_data => ( is => 'ro', init_arg => 'location', default => sub { {} } );

# Convenience accessors
sub location { shift->location_data->{name} }

=method location

Location name (convenience accessor).

=cut

sub is_attached { defined shift->server }

=method is_attached

Returns true if volume is attached to a server.

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update volume without ID" unless $self->id;

    my $result = $self->_client->put("/volumes/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $volume->name('new-name');
    $volume->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete volume without ID" unless $self->id;

    $self->_client->delete("/volumes/" . $self->id);
    return 1;
}

=method delete

    $volume->delete;

Deletes the volume.

=cut

sub attach {
    my ($self, $server_id, %opts) = @_;
    croak "Cannot attach volume without ID" unless $self->id;
    croak "Server ID required" unless $server_id;

    my $body = { server => $server_id };
    $body->{automount} = $opts{automount} ? \1 : \0 if exists $opts{automount};

    $self->_client->post("/volumes/" . $self->id . "/actions/attach", $body);
    return $self;
}

=method attach

    $volume->attach($server_id);
    $volume->attach($server_id, automount => 1);

Attaches volume to a server. Options: automount => 1.

=cut

sub detach {
    my ($self) = @_;
    croak "Cannot detach volume without ID" unless $self->id;

    $self->_client->post("/volumes/" . $self->id . "/actions/detach", {});
    return $self;
}

=method detach

    $volume->detach;

Detaches volume from server.

=cut

sub resize {
    my ($self, $size) = @_;
    croak "Cannot resize volume without ID" unless $self->id;
    croak "Size required" unless $size;

    $self->_client->post("/volumes/" . $self->id . "/actions/resize", { size => $size });
    return $self;
}

=method resize

    $volume->resize(100);  # 100 GB

Resizes volume to new size in GB. Can only increase size.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh volume without ID" unless $self->id;

    my $result = $self->_client->get("/volumes/" . $self->id);
    my $data = $result->{volume};

    $self->_set_status($data->{status});
    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $volume->refresh;

Reloads volume data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        status       => $self->status,
        size         => $self->size,
        server       => $self->server,
        created      => $self->created,
        labels       => $self->labels,
        linux_device => $self->linux_device,
        format       => $self->format,
        protection   => $self->protection,
        location     => $self->location_data,
    };
}

=method data

    my $hashref = $volume->data;

Returns all volume data as a hashref (for JSON serialization).

=cut

1;
