package WWW::Hetzner::CLI::Cmd::Server::Cmd::Poweroff;

# ABSTRACT: Power off a server (hard)

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server poweroff <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server poweroff <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Powering off server $id...\n";
    $cloud->servers->power_off($id);
    print "Server powered off.\n";
}

1;
