package WWW::Hetzner::CLI::Cmd::Server::Cmd::Poweron;

# ABSTRACT: Power on a server

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server poweron <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server poweron <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Powering on server $id...\n";
    $cloud->servers->power_on($id);
    print "Server powered on.\n";
}

1;
