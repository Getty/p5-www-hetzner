package WWW::Hetzner::Cloud::API::Networks;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Networks API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Network;
use namespace::clean;

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

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/networks', params => \%params);
    return $self->_wrap_list($result->{networks} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Network ID required" unless $id;

    my $result = $self->client->get("/networks/$id");
    return $self->_wrap($result->{network});
}

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

sub update {
    my ($self, $id, %params) = @_;
    croak "Network ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/networks/$id", $body);
    return $self->_wrap($result->{network});
}

sub delete {
    my ($self, $id) = @_;
    croak "Network ID required" unless $id;

    return $self->client->delete("/networks/$id");
}

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

sub delete_subnet {
    my ($self, $id, $ip_range) = @_;
    croak "Network ID required" unless $id;
    croak "ip_range required" unless $ip_range;

    return $self->client->post("/networks/$id/actions/delete_subnet", {
        ip_range => $ip_range,
    });
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::Networks - Hetzner Cloud Networks API

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

=head1 METHODS

=head2 list(%params)

Returns arrayref of Network objects.

=head2 get($id)

Returns Network object.

=head2 create(%params)

Creates network. Required: name, ip_range. Optional: labels, subnets, routes.

=head2 update($id, %params)

Updates network. Params: name, labels.

=head2 delete($id)

Deletes network.

=head2 add_subnet($id, %opts)

Add a subnet. Required: ip_range, network_zone, type.

=head2 delete_subnet($id, $ip_range)

Delete a subnet.

=head2 add_route($id, %opts)

Add a route. Required: destination, gateway.

=head2 delete_route($id, %opts)

Delete a route. Required: destination, gateway.

=cut
