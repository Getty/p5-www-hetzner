package WWW::Hetzner::Cloud::Volume;

# ABSTRACT: Hetzner Cloud Volume object

use Moo;
use Carp qw(croak);
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'rw' );
has status => ( is => 'rwp' );
has size => ( is => 'ro' );
has server => ( is => 'ro' );
has created => ( is => 'ro' );
has labels => ( is => 'rw', default => sub { {} } );
has linux_device => ( is => 'ro' );
has format => ( is => 'ro' );
has protection => ( is => 'ro', default => sub { {} } );

# Nested data
has location_data => ( is => 'ro', init_arg => 'location', default => sub { {} } );

# Convenience accessors
sub location { shift->location_data->{name} }
sub is_attached { defined shift->server }

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

sub delete {
    my ($self) = @_;
    croak "Cannot delete volume without ID" unless $self->id;

    $self->_client->delete("/volumes/" . $self->id);
    return 1;
}

sub attach {
    my ($self, $server_id, %opts) = @_;
    croak "Cannot attach volume without ID" unless $self->id;
    croak "Server ID required" unless $server_id;

    my $body = { server => $server_id };
    $body->{automount} = $opts{automount} ? \1 : \0 if exists $opts{automount};

    $self->_client->post("/volumes/" . $self->id . "/actions/attach", $body);
    return $self;
}

sub detach {
    my ($self) = @_;
    croak "Cannot detach volume without ID" unless $self->id;

    $self->_client->post("/volumes/" . $self->id . "/actions/detach", {});
    return $self;
}

sub resize {
    my ($self, $size) = @_;
    croak "Cannot resize volume without ID" unless $self->id;
    croak "Size required" unless $size;

    $self->_client->post("/volumes/" . $self->id . "/actions/resize", { size => $size });
    return $self;
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Volume - Hetzner Cloud Volume object

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

=head1 ATTRIBUTES

=head2 id, name, status, size, server, created, labels, linux_device, format, location

Standard volume attributes.

=head1 METHODS

=head2 is_attached

Returns true if volume is attached to a server.

=head2 attach($server_id, %opts)

Attaches volume to a server. Options: automount => 1.

=head2 detach

Detaches volume from server.

=head2 resize($size)

Resizes volume to new size in GB. Can only increase size.

=head2 update

Saves changes to name and labels.

=head2 delete

Deletes the volume.

=cut
