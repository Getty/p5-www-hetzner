package WWW::Hetzner::Cloud::Network;
# ABSTRACT: Hetzner Cloud Network object

our $VERSION = '0.004';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $network = $cloud->networks->get($id);

    # Read attributes
    print $network->name, "\n";
    print $network->ip_range, "\n";

    # Subnets
    $network->add_subnet(
        ip_range     => '10.0.1.0/24',
        network_zone => 'eu-central',
        type         => 'cloud',
    );
    $network->delete_subnet('10.0.1.0/24');

    # Routes
    $network->add_route(destination => '10.100.1.0/24', gateway => '10.0.0.1');
    $network->delete_route(destination => '10.100.1.0/24', gateway => '10.0.0.1');

    # Update
    $network->name('new-name');
    $network->update;

    # Delete
    $network->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud network. Objects are returned by
L<WWW::Hetzner::Cloud::API::Networks> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Network ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Network name (read-write).

=cut

has ip_range => ( is => 'ro' );

=attr ip_range

Network IP range in CIDR notation (read-only).

=cut

has subnets => ( is => 'ro', default => sub { [] } );

=attr subnets

Arrayref of subnet definitions (read-only).

=cut

has routes => ( is => 'ro', default => sub { [] } );

=attr routes

Arrayref of route definitions (read-only).

=cut

has servers => ( is => 'ro', default => sub { [] } );

=attr servers

Arrayref of attached server IDs (read-only).

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

has load_balancers => ( is => 'ro', default => sub { [] } );

=attr load_balancers

Arrayref of attached load balancer IDs (read-only).

=cut

has expose_routes_to_vswitch => ( is => 'ro', default => 0 );

=attr expose_routes_to_vswitch

Whether routes are exposed to vSwitch (read-only).

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update network without ID" unless $self->id;

    my $result = $self->_client->put("/networks/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $network->name('new-name');
    $network->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete network without ID" unless $self->id;

    $self->_client->delete("/networks/" . $self->id);
    return 1;
}

=method delete

    $network->delete;

Deletes the network.

=cut

sub add_subnet {
    my ($self, %opts) = @_;
    croak "Cannot modify network without ID" unless $self->id;
    croak "ip_range required" unless $opts{ip_range};
    croak "network_zone required" unless $opts{network_zone};
    croak "type required" unless $opts{type};

    my $body = {
        ip_range     => $opts{ip_range},
        network_zone => $opts{network_zone},
        type         => $opts{type},
    };
    $body->{vswitch_id} = $opts{vswitch_id} if $opts{vswitch_id};

    $self->_client->post("/networks/" . $self->id . "/actions/add_subnet", $body);
    return $self;
}

=method add_subnet

    $network->add_subnet(
        ip_range     => '10.0.1.0/24',
        network_zone => 'eu-central',
        type         => 'cloud',
    );

Add a subnet. Required: ip_range, network_zone, type.

=cut

sub delete_subnet {
    my ($self, $ip_range) = @_;
    croak "Cannot modify network without ID" unless $self->id;
    croak "ip_range required" unless $ip_range;

    $self->_client->post("/networks/" . $self->id . "/actions/delete_subnet", {
        ip_range => $ip_range,
    });
    return $self;
}

=method delete_subnet

    $network->delete_subnet('10.0.1.0/24');

Delete a subnet by IP range.

=cut

sub add_route {
    my ($self, %opts) = @_;
    croak "Cannot modify network without ID" unless $self->id;
    croak "destination required" unless $opts{destination};
    croak "gateway required" unless $opts{gateway};

    $self->_client->post("/networks/" . $self->id . "/actions/add_route", {
        destination => $opts{destination},
        gateway     => $opts{gateway},
    });
    return $self;
}

=method add_route

    $network->add_route(destination => '10.100.1.0/24', gateway => '10.0.0.1');

Add a route. Required: destination, gateway.

=cut

sub delete_route {
    my ($self, %opts) = @_;
    croak "Cannot modify network without ID" unless $self->id;
    croak "destination required" unless $opts{destination};
    croak "gateway required" unless $opts{gateway};

    $self->_client->post("/networks/" . $self->id . "/actions/delete_route", {
        destination => $opts{destination},
        gateway     => $opts{gateway},
    });
    return $self;
}

=method delete_route

    $network->delete_route(destination => '10.100.1.0/24', gateway => '10.0.0.1');

Delete a route. Required: destination, gateway.

=cut

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh network without ID" unless $self->id;

    my $result = $self->_client->get("/networks/" . $self->id);
    my $data = $result->{network};

    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

=method refresh

    $network->refresh;

Reloads network data from the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id         => $self->id,
        name       => $self->name,
        ip_range   => $self->ip_range,
        subnets    => $self->subnets,
        routes     => $self->routes,
        servers    => $self->servers,
        labels     => $self->labels,
        protection => $self->protection,
        created    => $self->created,
    };
}

=method data

    my $hashref = $network->data;

Returns all network data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Networks> - Networks API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
