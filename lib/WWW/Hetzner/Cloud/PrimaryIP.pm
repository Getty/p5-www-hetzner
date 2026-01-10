package WWW::Hetzner::Cloud::PrimaryIP;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Primary IP object

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $pip = $cloud->primary_ips->get($id);

    # Read attributes
    print $pip->ip, "\n";
    print $pip->type, "\n";  # ipv4 or ipv6

    # Assign to server
    $pip->assign($server_id, 'server');
    $pip->unassign;

    # Update
    $pip->name('new-name');
    $pip->auto_delete(1);
    $pip->update;

    # Delete
    $pip->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud primary IP. Objects are returned by
L<WWW::Hetzner::Cloud::API::PrimaryIPs> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Primary IP ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Primary IP name (read-write).

=cut

has ip => ( is => 'ro' );

=attr ip

The IP address (read-only).

=cut

has type => ( is => 'ro' );

=attr type

IP type: ipv4 or ipv6 (read-only).

=cut

has assignee_id => ( is => 'ro' );

=attr assignee_id

Assigned resource ID, or undef if not assigned (read-only).

=cut

has assignee_type => ( is => 'ro' );

=attr assignee_type

Type of assigned resource, e.g. "server" (read-only).

=cut

has datacenter => ( is => 'ro', default => sub { {} } );

=attr datacenter

Datacenter data hash (read-only).

=cut

has dns_ptr => ( is => 'ro', default => sub { [] } );

=attr dns_ptr

Arrayref of reverse DNS entries (read-only).

=cut

has auto_delete => ( is => 'rw' );

=attr auto_delete

Whether to auto-delete when resource is deleted (read-write).

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
sub is_assigned { defined shift->assignee_id }

=method is_assigned

Returns true if assigned to a resource.

=cut

sub datacenter_name { shift->datacenter->{name} }

=method datacenter_name

Returns datacenter name.

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update primary IP without ID" unless $self->id;

    my $result = $self->_client->put("/primary_ips/" . $self->id, {
        name        => $self->name,
        auto_delete => $self->auto_delete,
        labels      => $self->labels,
    });
    return $self;
}

=method update

    $pip->name('new-name');
    $pip->auto_delete(1);
    $pip->update;

Saves changes to name, auto_delete, and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete primary IP without ID" unless $self->id;

    $self->_client->delete("/primary_ips/" . $self->id);
    return 1;
}

=method delete

    $pip->delete;

Deletes the primary IP.

=cut

sub assign {
    my ($self, $assignee_id, $assignee_type) = @_;
    croak "Cannot assign primary IP without ID" unless $self->id;
    croak "Assignee ID required" unless $assignee_id;
    $assignee_type //= 'server';

    $self->_client->post("/primary_ips/" . $self->id . "/actions/assign", {
        assignee_id   => $assignee_id,
        assignee_type => $assignee_type,
    });
    return $self;
}

=method assign

    $pip->assign($server_id);
    $pip->assign($server_id, 'server');

Assign to a resource.

=cut

sub unassign {
    my ($self) = @_;
    croak "Cannot unassign primary IP without ID" unless $self->id;

    $self->_client->post("/primary_ips/" . $self->id . "/actions/unassign", {});
    return $self;
}

=method unassign

    $pip->unassign;

Unassign from current resource.

=cut

sub change_dns_ptr {
    my ($self, $ip, $dns_ptr) = @_;
    croak "Cannot modify primary IP without ID" unless $self->id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    $self->_client->post("/primary_ips/" . $self->id . "/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
    return $self;
}

=method change_dns_ptr

    $pip->change_dns_ptr($pip->ip, 'server.example.com');

Change reverse DNS pointer.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh primary IP without ID" unless $self->id;

    my $result = $self->_client->get("/primary_ips/" . $self->id);
    my $data = $result->{primary_ip};

    $self->name($data->{name});
    $self->auto_delete($data->{auto_delete});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $pip->refresh;

Reloads primary IP data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id            => $self->id,
        name          => $self->name,
        ip            => $self->ip,
        type          => $self->type,
        assignee_id   => $self->assignee_id,
        assignee_type => $self->assignee_type,
        datacenter    => $self->datacenter,
        dns_ptr       => $self->dns_ptr,
        auto_delete   => $self->auto_delete,
        blocked       => $self->blocked,
        labels        => $self->labels,
        protection    => $self->protection,
        created       => $self->created,
    };
}

=method data

    my $hashref = $pip->data;

Returns all primary IP data as a hashref (for JSON serialization).

=cut

1;
