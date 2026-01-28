package WWW::Hetzner::CLI::Cmd::Network;
# ABSTRACT: Hetzner Cloud Network commands

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl network <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list         List all networks\n";
    print "  describe     Show network details\n";
    print "  create       Create a network\n";
    print "  delete       Delete a network\n";
    print "  add-subnet   Add a subnet to network\n";
    print "  add-route    Add a route to network\n";
}

1;
