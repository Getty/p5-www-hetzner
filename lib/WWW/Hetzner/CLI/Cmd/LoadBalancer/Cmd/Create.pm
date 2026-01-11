package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Create;
# ABSTRACT: Create a load balancer

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer create --name <name> --type <type> --location <loc>';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Load balancer name',
);

option type => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Load balancer type (e.g. lb11)',
);

option location => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Location (e.g. fsn1)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating load balancer '", $self->name, "'...\n";
    my $lb = $cloud->load_balancers->create(
        name               => $self->name,
        load_balancer_type => $self->type,
        location           => $self->location,
    );
    print "Load balancer created with ID ", $lb->id, "\n";
}

1;
