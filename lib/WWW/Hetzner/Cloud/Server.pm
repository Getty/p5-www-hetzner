package WWW::Hetzner::Cloud::Server;
# ABSTRACT: Hetzner Cloud Server object

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $server = $cloud->servers->get($id);

    # Read attributes
    print $server->id, "\n";
    print $server->name, "\n";
    print $server->status, "\n";
    print $server->ipv4, "\n";

    # Check status
    if ($server->is_running) { ... }
    if ($server->is_off) { ... }

    # Update
    $server->name('new-name');
    $server->labels({ env => 'prod' });
    $server->update;

    # Power actions
    $server->shutdown;
    $server->power_on;
    $server->power_off;
    $server->reboot;

    # Rebuild with new image
    $server->rebuild('debian-13');

    # Delete
    $server->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud server. Objects are returned by
L<WWW::Hetzner::Cloud::API::Servers> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Server ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Server name (read-write).

=cut

has status => ( is => 'rwp' );

=attr status

Server status: running, off, starting, stopping, etc. (read-only).

=cut

has locked => ( is => 'ro' );

=attr locked

Whether the server is locked (read-only).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

# Nested data stored as-is
has public_net => ( is => 'ro', default => sub { {} } );
has private_net => ( is => 'ro', default => sub { [] } );
has server_type_data => ( is => 'ro', init_arg => 'server_type', default => sub { {} } );
has datacenter_data => ( is => 'ro', init_arg => 'datacenter', default => sub { {} } );
has image_data => ( is => 'ro', init_arg => 'image', default => sub { {} } );

# Convenience accessors

sub ipv4 { shift->public_net->{ipv4}{ip} }

=method ipv4

Public IPv4 address.

=cut

sub ipv6 { shift->public_net->{ipv6}{ip} }

=method ipv6

Public IPv6 network.

=cut

sub server_type { shift->server_type_data->{name} }

=method server_type

Server type name, e.g. "cx22".

=cut

sub datacenter { shift->datacenter_data->{name} }

=method datacenter

Datacenter name.

=cut

sub location { shift->datacenter_data->{location}{name} }

=method location

Location name.

=cut

sub image { my $i = shift->image_data; $i ? $i->{name} : undef }

=method image

Image name.

=cut

sub is_running { shift->status eq 'running' }

=method is_running

    if ($server->is_running) { ... }

Returns true if server status is "running".

=cut

sub is_off { shift->status eq 'off' }

=method is_off

    if ($server->is_off) { ... }

Returns true if server status is "off".

=cut

# Actions

sub update {
    my ($self) = @_;
    croak "Cannot update server without ID" unless $self->id;

    my $result = $self->_client->put("/servers/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $server->name('new-name');
    $server->update;

Saves changes to name and labels back to the API.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete server without ID" unless $self->id;

    $self->_client->delete("/servers/" . $self->id);
    return 1;
}

=method delete

    $server->delete;

Deletes the server.

=cut

sub power_on {
    my ($self) = @_;
    croak "Cannot power on server without ID" unless $self->id;

    $self->_client->post("/servers/" . $self->id . "/actions/poweron", {});
    return $self;
}

=method power_on

    $server->power_on;

Powers on the server.

=cut

sub power_off {
    my ($self) = @_;
    croak "Cannot power off server without ID" unless $self->id;

    $self->_client->post("/servers/" . $self->id . "/actions/poweroff", {});
    return $self;
}

=method power_off

    $server->power_off;

Hard power off (like pulling the power cord).

=cut

sub reboot {
    my ($self) = @_;
    croak "Cannot reboot server without ID" unless $self->id;

    $self->_client->post("/servers/" . $self->id . "/actions/reboot", {});
    return $self;
}

=method reboot

    $server->reboot;

Hard reboot.

=cut

sub shutdown {
    my ($self) = @_;
    croak "Cannot shutdown server without ID" unless $self->id;

    $self->_client->post("/servers/" . $self->id . "/actions/shutdown", {});
    return $self;
}

=method shutdown

    $server->shutdown;

Graceful shutdown via ACPI.

=cut

sub rebuild {
    my ($self, $image) = @_;
    croak "Cannot rebuild server without ID" unless $self->id;
    croak "Image required" unless $image;

    $self->_client->post("/servers/" . $self->id . "/actions/rebuild", { image => $image });
    return $self;
}

=method rebuild

    $server->rebuild('debian-13');

Rebuilds the server with a new image. Data will be lost.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh server without ID" unless $self->id;

    my $result = $self->_client->get("/servers/" . $self->id);
    my $data = $result->{server};

    $self->_set_status($data->{status});
    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $server->refresh;

Reloads server data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id          => $self->id,
        name        => $self->name,
        status      => $self->status,
        locked      => $self->locked,
        created     => $self->created,
        labels      => $self->labels,
        public_net  => $self->public_net,
        private_net => $self->private_net,
        server_type => $self->server_type_data,
        datacenter  => $self->datacenter_data,
        image       => $self->image_data,
    };
}

=method data

    my $hashref = $server->data;

Returns all server data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Servers> - Servers API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::ServerType> - Server type entity

=item * L<WWW::Hetzner::Cloud::Image> - Image entity

=item * L<WWW::Hetzner::Cloud::Datacenter> - Datacenter entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
