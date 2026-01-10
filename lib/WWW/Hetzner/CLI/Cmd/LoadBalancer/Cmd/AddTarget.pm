package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::AddTarget;
our $VERSION = '0.002';
# ABSTRACT: Add a target to a load balancer

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer add-target <id> --server <server-id>';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to add as target',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl load-balancer add-target <id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Adding server ", $self->server, " as target to load balancer $id...\n";
    $cloud->load_balancers->add_target($id,
        type   => 'server',
        server => { id => $self->server },
    );
    print "Target added.\n";
}

1;
