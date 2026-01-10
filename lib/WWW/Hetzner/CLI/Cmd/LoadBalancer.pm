package WWW::Hetzner::CLI::Cmd::LoadBalancer;

# ABSTRACT: Hetzner Cloud Load Balancer commands

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl load-balancer <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list         List all load balancers\n";
    print "  describe     Show load balancer details\n";
    print "  create       Create a load balancer\n";
    print "  delete       Delete a load balancer\n";
    print "  add-target   Add a target to load balancer\n";
    print "  add-service  Add a service to load balancer\n";
}

1;
