package WWW::Hetzner::Cloud::API::Networks;
# ABSTRACT: Hetzner Cloud Networks API

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Network;
use namespace::clean;

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List networks
    my $networks = $cloud->networks->list;

    # Create network
    my $network = $cloud->networks->create(
        name     => 'my-network',
        ip_range => '10.0.0.0/8',
    );

    # Add subnet
    $cloud->networks->add_subnet($network->id,
        ip_range     => '10.0.1.0/24',
        network_zone => 'eu-central',
        type         => 'cloud',
    );

    # Add route
    $cloud->networks->add_route($network->id,
        destination => '10.100.1.0/24',
        gateway     => '10.0.0.1',
    );

    # Delete
    $cloud->networks->delete($network->id);

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud networks.
All methods return L<WWW::Hetzner::Cloud::Network> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Network->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $networks = $cloud->networks->list;
    my $networks = $cloud->networks->list(label_selector => 'env=prod');

Returns arrayref of L<WWW::Hetzner::Cloud::Network> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/networks', params => \%params);
    return $self->_wrap_list($result->{networks} // []);
}

=method get

    my $network = $cloud->networks->get($id);

Returns L<WWW::Hetzner::Cloud::Network> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Network ID required" unless $id;

    my $result = $self->client->get("/networks/$id");
    return $self->_wrap($result->{network});
}

=method create

    my $network = $cloud->networks->create(
        name     => 'my-network',  # required
        ip_range => '10.0.0.0/8',  # required
        labels   => { ... },       # optional
        subnets  => [ ... ],       # optional
        routes   => [ ... ],       # optional
    );

Creates network. Returns L<WWW::Hetzner::Cloud::Network> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "ip_range required" unless $params{ip_range};

    my $body = {
        name     => $params{name},
        ip_range => $params{ip_range},
    };

    $body->{labels}  = $params{labels}  if $params{labels};
    $body->{subnets} = $params{subnets} if $params{subnets};
    $body->{routes}  = $params{routes}  if $params{routes};
    $body->{expose_routes_to_vswitch} = $params{expose_routes_to_vswitch}
        if exists $params{expose_routes_to_vswitch};

    my $result = $self->client->post('/networks', $body);
    return $self->_wrap($result->{network});
}

=method update

    $cloud->networks->update($id, name => 'new-name', labels => { ... });

Updates network. Returns L<WWW::Hetzner::Cloud::Network> object.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak "Network ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/networks/$id", $body);
    return $self->_wrap($result->{network});
}

=method delete

    $cloud->networks->delete($id);

Deletes network.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "Network ID required" unless $id;

    return $self->client->delete("/networks/$id");
}

=method add_subnet

    $cloud->networks->add_subnet($id,
        ip_range     => '10.0.1.0/24',
        network_zone => 'eu-central',
        type         => 'cloud',
        vswitch_id   => $id,  # optional, for vswitch type
    );

Add a subnet to the network.

=cut

sub add_subnet {
    my ($self, $id, %opts) = @_;
    croak "Network ID required" unless $id;
    croak "ip_range required" unless $opts{ip_range};
    croak "network_zone required" unless $opts{network_zone};
    croak "type required" unless $opts{type};

    my $body = {
        ip_range     => $opts{ip_range},
        network_zone => $opts{network_zone},
        type         => $opts{type},
    };
    $body->{vswitch_id} = $opts{vswitch_id} if $opts{vswitch_id};

    return $self->client->post("/networks/$id/actions/add_subnet", $body);
}

=method delete_subnet

    $cloud->networks->delete_subnet($id, $ip_range);

Delete a subnet from the network.

=cut

sub delete_subnet {
    my ($self, $id, $ip_range) = @_;
    croak "Network ID required" unless $id;
    croak "ip_range required" unless $ip_range;

    return $self->client->post("/networks/$id/actions/delete_subnet", {
        ip_range => $ip_range,
    });
}

=method add_route

    $cloud->networks->add_route($id,
        destination => '10.100.1.0/24',
        gateway     => '10.0.0.1',
    );

Add a route to the network.

=cut

sub add_route {
    my ($self, $id, %opts) = @_;
    croak "Network ID required" unless $id;
    croak "destination required" unless $opts{destination};
    croak "gateway required" unless $opts{gateway};

    return $self->client->post("/networks/$id/actions/add_route", {
        destination => $opts{destination},
        gateway     => $opts{gateway},
    });
}

=method delete_route

    $cloud->networks->delete_route($id,
        destination => '10.100.1.0/24',
        gateway     => '10.0.0.1',
    );

Delete a route from the network.

=cut

sub delete_route {
    my ($self, $id, %opts) = @_;
    croak "Network ID required" unless $id;
    croak "destination required" unless $opts{destination};
    croak "gateway required" unless $opts{gateway};

    return $self->client->post("/networks/$id/actions/delete_route", {
        destination => $opts{destination},
        gateway     => $opts{gateway},
    });
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Network> - Network entity class

=item * L<WWW::Hetzner::CLI::Cmd::Network> - Network CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
