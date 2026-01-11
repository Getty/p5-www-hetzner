package WWW::Hetzner::CLI::Cmd::PrimaryIp;
# ABSTRACT: Hetzner Cloud Primary IP commands

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl primary-ip <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list       List all primary IPs\n";
    print "  describe   Show primary IP details\n";
    print "  create     Create a primary IP\n";
    print "  delete     Delete a primary IP\n";
    print "  assign     Assign to a server\n";
    print "  unassign   Unassign from server\n";
}

1;
