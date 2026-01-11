package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Delete;
# ABSTRACT: Delete a firewall

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl firewall delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting firewall $id...\n";
    $cloud->firewalls->delete($id);
    print "Firewall deleted.\n";
}

1;
