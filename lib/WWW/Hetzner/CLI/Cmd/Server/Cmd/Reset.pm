package WWW::Hetzner::CLI::Cmd::Server::Cmd::Reset;
# ABSTRACT: Reset a server (hard)

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server reset <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server reset <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Resetting server $id...\n";
    $cloud->servers->reset($id);
    print "Server reset initiated.\n";
}

1;
