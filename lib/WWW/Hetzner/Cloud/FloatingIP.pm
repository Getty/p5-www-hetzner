package WWW::Hetzner::Cloud::FloatingIP;
# ABSTRACT: Hetzner Cloud Floating IP object

our $VERSION = '0.002';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $fip = $cloud->floating_ips->get($id);

    # Read attributes
    print $fip->ip, "\n";
    print $fip->type, "\n";  # ipv4 or ipv6

    # Assign to server
    $fip->assign($server_id);
    $fip->unassign;

    # Change reverse DNS
    $fip->change_dns_ptr($fip->ip, 'server.example.com');

    # Update
    $fip->name('new-name');
    $fip->update;

    # Delete
    $fip->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud floating IP. Objects are returned by
L<WWW::Hetzner::Cloud::API::FloatingIPs> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Floating IP ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Floating IP name (read-write).

=cut

has description => ( is => 'rw' );

=attr description

Floating IP description (read-write).

=cut

has ip => ( is => 'ro' );

=attr ip

The IP address (read-only).

=cut

has type => ( is => 'ro' );

=attr type

IP type: ipv4 or ipv6 (read-only).

=cut

has server => ( is => 'ro' );

=attr server

Assigned server ID, or undef if not assigned (read-only).

=cut

has dns_ptr => ( is => 'ro', default => sub { [] } );

=attr dns_ptr

Arrayref of reverse DNS entries (read-only).

=cut

has home_location => ( is => 'ro', default => sub { {} } );

=attr home_location

Home location data hash (read-only).

=cut

has blocked => ( is => 'ro' );

=attr blocked

Whether the IP is blocked (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has protection => ( is => 'ro', default => sub { {} } );

=attr protection

Protection settings hash (read-only).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

# Convenience
sub is_assigned { defined shift->server }

=method is_assigned

Returns true if assigned to a server.

=cut

sub location { shift->home_location->{name} }

=method location

Returns home location name.

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update floating IP without ID" unless $self->id;

    my $result = $self->_client->put("/floating_ips/" . $self->id, {
        name        => $self->name,
        description => $self->description,
        labels      => $self->labels,
    });
    return $self;
}

=method update

    $fip->name('new-name');
    $fip->update;

Saves changes to name, description, and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete floating IP without ID" unless $self->id;

    $self->_client->delete("/floating_ips/" . $self->id);
    return 1;
}

=method delete

    $fip->delete;

Deletes the floating IP.

=cut

sub assign {
    my ($self, $server_id) = @_;
    croak "Cannot assign floating IP without ID" unless $self->id;
    croak "Server ID required" unless $server_id;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/assign", {
        server => $server_id,
    });
    return $self;
}

=method assign

    $fip->assign($server_id);

Assign to a server.

=cut

sub unassign {
    my ($self) = @_;
    croak "Cannot unassign floating IP without ID" unless $self->id;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/unassign", {});
    return $self;
}

=method unassign

    $fip->unassign;

Unassign from current server.

=cut

sub change_dns_ptr {
    my ($self, $ip, $dns_ptr) = @_;
    croak "Cannot modify floating IP without ID" unless $self->id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    $self->_client->post("/floating_ips/" . $self->id . "/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
    return $self;
}

=method change_dns_ptr

    $fip->change_dns_ptr($fip->ip, 'server.example.com');

Change reverse DNS pointer.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh floating IP without ID" unless $self->id;

    my $result = $self->_client->get("/floating_ips/" . $self->id);
    my $data = $result->{floating_ip};

    $self->name($data->{name});
    $self->description($data->{description});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $fip->refresh;

Reloads floating IP data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id            => $self->id,
        name          => $self->name,
        description   => $self->description,
        ip            => $self->ip,
        type          => $self->type,
        server        => $self->server,
        dns_ptr       => $self->dns_ptr,
        home_location => $self->home_location,
        blocked       => $self->blocked,
        labels        => $self->labels,
        protection    => $self->protection,
        created       => $self->created,
    };
}

=method data

    my $hashref = $fip->data;

Returns all floating IP data as a hashref (for JSON serialization).

=cut

1;
