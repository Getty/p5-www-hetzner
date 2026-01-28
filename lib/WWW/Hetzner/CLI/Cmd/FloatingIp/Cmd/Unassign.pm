package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Unassign;
# ABSTRACT: Unassign a floating IP from its server

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip unassign <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl floating-ip unassign <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Unassigning floating IP $id...\n";
    $cloud->floating_ips->unassign($id);
    print "Floating IP unassigned.\n";
}

1;
