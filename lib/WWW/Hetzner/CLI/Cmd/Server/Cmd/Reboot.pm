package WWW::Hetzner::CLI::Cmd::Server::Cmd::Reboot;
our $VERSION = '0.002';
# ABSTRACT: Reboot a server (soft)

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server reboot <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server reboot <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Rebooting server $id...\n";
    $cloud->servers->reboot($id);
    print "Server reboot initiated.\n";
}

1;
