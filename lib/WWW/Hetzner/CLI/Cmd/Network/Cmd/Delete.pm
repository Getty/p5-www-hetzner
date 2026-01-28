package WWW::Hetzner::CLI::Cmd::Network::Cmd::Delete;
# ABSTRACT: Delete a network

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl network delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting network $id...\n";
    $cloud->networks->delete($id);
    print "Network deleted.\n";
}

1;
