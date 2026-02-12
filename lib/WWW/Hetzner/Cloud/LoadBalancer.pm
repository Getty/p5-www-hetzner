package WWW::Hetzner::Cloud::LoadBalancer;
# ABSTRACT: Hetzner Cloud Load Balancer object

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $lb = $cloud->load_balancers->get($id);

    # Read attributes
    print $lb->name, "\n";
    print $lb->ipv4, "\n";

    # Add target
    $lb->add_target(type => 'server', server => { id => 123 });

    # Add service
    $lb->add_service(
        protocol         => 'http',
        listen_port      => 80,
        destination_port => 8080,
    );

    # Delete
    $lb->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud load balancer. Objects are returned by
L<WWW::Hetzner::Cloud::API::LoadBalancers> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Load balancer ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Load balancer name (read-write).

=cut

has public_net => ( is => 'ro', default => sub { {} } );

=attr public_net

Public network configuration hash (read-only).

=cut

has private_net => ( is => 'ro', default => sub { [] } );

=attr private_net

Arrayref of private network attachments (read-only).

=cut

has location => ( is => 'ro', default => sub { {} } );

=attr location

Location data hash (read-only).

=cut

has load_balancer_type => ( is => 'ro', default => sub { {} } );

=attr load_balancer_type

Load balancer type data hash (read-only).

=cut

has protection => ( is => 'ro', default => sub { {} } );

=attr protection

Protection settings hash (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has targets => ( is => 'ro', default => sub { [] } );

=attr targets

Arrayref of targets (read-only).

=cut

has services => ( is => 'ro', default => sub { [] } );

=attr services

Arrayref of services (read-only).

=cut

has algorithm => ( is => 'ro', default => sub { {} } );

=attr algorithm

Algorithm configuration hash (read-only).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has outgoing_traffic => ( is => 'ro' );

=attr outgoing_traffic

Outgoing traffic in bytes (read-only).

=cut

has ingoing_traffic => ( is => 'ro' );

=attr ingoing_traffic

Ingoing traffic in bytes (read-only).

=cut

has included_traffic => ( is => 'ro' );

=attr included_traffic

Included traffic in bytes (read-only).

=cut

# Convenience
sub location_name { shift->location->{name} }

=method location_name

Returns location name.

=cut

sub type_name { shift->load_balancer_type->{name} }

=method type_name

Returns load balancer type name.

=cut

sub ipv4 { shift->public_net->{ipv4}{ip} }

=method ipv4

Returns public IPv4 address.

=cut

sub ipv6 { shift->public_net->{ipv6}{ip} }

=method ipv6

Returns public IPv6 address.

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update load balancer without ID" unless $self->id;

    my $result = $self->_client->put("/load_balancers/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $lb->name('new-name');
    $lb->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete load balancer without ID" unless $self->id;

    $self->_client->delete("/load_balancers/" . $self->id);
    return 1;
}

=method delete

    $lb->delete;

Deletes the load balancer.

=cut

sub add_target {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "type required" unless $opts{type};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/add_target", \%opts);
    return $self;
}

=method add_target

    $lb->add_target(type => 'server', server => { id => 123 });

Add a target to the load balancer.

=cut

sub remove_target {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "type required" unless $opts{type};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/remove_target", \%opts);
    return $self;
}

=method remove_target

    $lb->remove_target(type => 'server', server => { id => 123 });

Remove a target from the load balancer.

=cut

sub add_service {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "protocol required" unless $opts{protocol};
    croak "listen_port required" unless $opts{listen_port};
    croak "destination_port required" unless $opts{destination_port};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/add_service", \%opts);
    return $self;
}

=method add_service

    $lb->add_service(
        protocol         => 'http',
        listen_port      => 80,
        destination_port => 8080,
    );

Add a service to the load balancer.

=cut

sub delete_service {
    my ($self, $listen_port) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "listen_port required" unless $listen_port;

    $self->_client->post("/load_balancers/" . $self->id . "/actions/delete_service", {
        listen_port => $listen_port,
    });
    return $self;
}

=method delete_service

    $lb->delete_service(80);

Delete a service by listen port.

=cut

sub attach_to_network {
    my ($self, $network_id, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "network required" unless $network_id;

    my $body = { network => $network_id };
    $body->{ip} = $opts{ip} if $opts{ip};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/attach_to_network", $body);
    return $self;
}

=method attach_to_network

    $lb->attach_to_network($network_id);
    $lb->attach_to_network($network_id, ip => '10.0.0.5');

Attach load balancer to a network.

=cut

sub detach_from_network {
    my ($self, $network_id) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "network required" unless $network_id;

    $self->_client->post("/load_balancers/" . $self->id . "/actions/detach_from_network", {
        network => $network_id,
    });
    return $self;
}

=method detach_from_network

    $lb->detach_from_network($network_id);

Detach load balancer from a network.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh load balancer without ID" unless $self->id;

    my $result = $self->_client->get("/load_balancers/" . $self->id);
    my $data = $result->{load_balancer};

    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $lb->refresh;

Reloads load balancer data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id                 => $self->id,
        name               => $self->name,
        public_net         => $self->public_net,
        private_net        => $self->private_net,
        location           => $self->location,
        load_balancer_type => $self->load_balancer_type,
        protection         => $self->protection,
        labels             => $self->labels,
        targets            => $self->targets,
        services           => $self->services,
        algorithm          => $self->algorithm,
        created            => $self->created,
    };
}

=method data

    my $hashref = $lb->data;

Returns all load balancer data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::LoadBalancers> - Load Balancers API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Server> - Server entity

=item * L<WWW::Hetzner::Cloud::Network> - Network entity

=item * L<WWW::Hetzner::Cloud::Location> - Location entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
