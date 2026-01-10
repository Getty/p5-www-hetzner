package WWW::Hetzner::CLI::Cmd::PlacementGroup;

# ABSTRACT: Hetzner Cloud Placement Group commands

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl placement-group <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list       List all placement groups\n";
    print "  describe   Show placement group details\n";
    print "  create     Create a placement group\n";
    print "  delete     Delete a placement group\n";
}

1;
