package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Delete;
# ABSTRACT: Delete a floating IP

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl floating-ip delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting floating IP $id...\n";
    $cloud->floating_ips->delete($id);
    print "Floating IP deleted.\n";
}

1;
