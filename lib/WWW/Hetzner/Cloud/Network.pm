package WWW::Hetzner::Cloud::Network;

# ABSTRACT: Hetzner Cloud Network object

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
has ip_range => ( is => 'ro' );
has subnets => ( is => 'ro', default => sub { [] } );
has routes => ( is => 'ro', default => sub { [] } );
has servers => ( is => 'ro', default => sub { [] } );
has labels => ( is => 'rw', default => sub { {} } );
has protection => ( is => 'ro', default => sub { {} } );
has created => ( is => 'ro' );
has load_balancers => ( is => 'ro', default => sub { [] } );
has expose_routes_to_vswitch => ( is => 'ro', default => 0 );

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

sub delete {
    my ($self) = @_;
    croak "Cannot delete network without ID" unless $self->id;

    $self->_client->delete("/networks/" . $self->id);
    return 1;
}

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

sub delete_subnet {
    my ($self, $ip_range) = @_;
    croak "Cannot modify network without ID" unless $self->id;
    croak "ip_range required" unless $ip_range;

    $self->_client->post("/networks/" . $self->id . "/actions/delete_subnet", {
        ip_range => $ip_range,
    });
    return $self;
}

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

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh network without ID" unless $self->id;

    my $result = $self->_client->get("/networks/" . $self->id);
    my $data = $result->{network};

    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Network - Hetzner Cloud Network object

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

=head1 ATTRIBUTES

=head2 id, name, ip_range, subnets, routes, servers, labels, protection, created

Standard network attributes.

=head1 METHODS

=head2 add_subnet(%opts)

Add a subnet. Required: ip_range, network_zone, type.

=head2 delete_subnet($ip_range)

Delete a subnet by IP range.

=head2 add_route(%opts)

Add a route. Required: destination, gateway.

=head2 delete_route(%opts)

Delete a route. Required: destination, gateway.

=head2 update

Saves changes to name and labels.

=head2 delete

Deletes the network.

=cut
