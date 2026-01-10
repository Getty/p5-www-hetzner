package WWW::Hetzner::Cloud::LoadBalancer;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Load Balancer object

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
has public_net => ( is => 'ro', default => sub { {} } );
has private_net => ( is => 'ro', default => sub { [] } );
has location => ( is => 'ro', default => sub { {} } );
has load_balancer_type => ( is => 'ro', default => sub { {} } );
has protection => ( is => 'ro', default => sub { {} } );
has labels => ( is => 'rw', default => sub { {} } );
has targets => ( is => 'ro', default => sub { [] } );
has services => ( is => 'ro', default => sub { [] } );
has algorithm => ( is => 'ro', default => sub { {} } );
has created => ( is => 'ro' );
has outgoing_traffic => ( is => 'ro' );
has ingoing_traffic => ( is => 'ro' );
has included_traffic => ( is => 'ro' );

# Convenience
sub location_name { shift->location->{name} }
sub type_name { shift->load_balancer_type->{name} }
sub ipv4 { shift->public_net->{ipv4}{ip} }
sub ipv6 { shift->public_net->{ipv6}{ip} }

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

sub delete {
    my ($self) = @_;
    croak "Cannot delete load balancer without ID" unless $self->id;

    $self->_client->delete("/load_balancers/" . $self->id);
    return 1;
}

sub add_target {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "type required" unless $opts{type};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/add_target", \%opts);
    return $self;
}

sub remove_target {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "type required" unless $opts{type};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/remove_target", \%opts);
    return $self;
}

sub add_service {
    my ($self, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "protocol required" unless $opts{protocol};
    croak "listen_port required" unless $opts{listen_port};
    croak "destination_port required" unless $opts{destination_port};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/add_service", \%opts);
    return $self;
}

sub delete_service {
    my ($self, $listen_port) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "listen_port required" unless $listen_port;

    $self->_client->post("/load_balancers/" . $self->id . "/actions/delete_service", {
        listen_port => $listen_port,
    });
    return $self;
}

sub attach_to_network {
    my ($self, $network_id, %opts) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "network required" unless $network_id;

    my $body = { network => $network_id };
    $body->{ip} = $opts{ip} if $opts{ip};

    $self->_client->post("/load_balancers/" . $self->id . "/actions/attach_to_network", $body);
    return $self;
}

sub detach_from_network {
    my ($self, $network_id) = @_;
    croak "Cannot modify load balancer without ID" unless $self->id;
    croak "network required" unless $network_id;

    $self->_client->post("/load_balancers/" . $self->id . "/actions/detach_from_network", {
        network => $network_id,
    });
    return $self;
}

sub refresh {
    my ($self) = @_;
    croak "Cannot refresh load balancer without ID" unless $self->id;

    my $result = $self->_client->get("/load_balancers/" . $self->id);
    my $data = $result->{load_balancer};

    $self->name($data->{name});
    $self->labels($data->{labels} // {});

    return $self;
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::LoadBalancer - Hetzner Cloud Load Balancer object

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

=cut
