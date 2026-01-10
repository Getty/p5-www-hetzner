package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Delete;

# ABSTRACT: Delete a load balancer

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl load-balancer delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting load balancer $id...\n";
    $cloud->load_balancers->delete($id);
    print "Load balancer deleted.\n";
}

1;
