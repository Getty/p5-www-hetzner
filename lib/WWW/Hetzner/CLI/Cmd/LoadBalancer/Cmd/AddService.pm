package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::AddService;

# ABSTRACT: Add a service to a load balancer

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer add-service <id> --protocol <proto> --listen-port <port> --destination-port <port>';

option protocol => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Protocol: tcp, http, https',
);

option 'listen_port' => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    long_doc => 'listen-port',
    doc      => 'Listen port',
);

option 'destination_port' => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    long_doc => 'destination-port',
    doc      => 'Destination port',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl load-balancer add-service <id> --protocol <proto> --listen-port <port> --destination-port <port>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Adding ", $self->protocol, " service to load balancer $id...\n";
    $cloud->load_balancers->add_service($id,
        protocol         => $self->protocol,
        listen_port      => $self->listen_port,
        destination_port => $self->destination_port,
    );
    print "Service added.\n";
}

1;
