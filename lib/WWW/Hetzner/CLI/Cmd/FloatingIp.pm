package WWW::Hetzner::CLI::Cmd::FloatingIp;
# ABSTRACT: Hetzner Cloud Floating IP commands

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl floating-ip <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list       List all floating IPs\n";
    print "  describe   Show floating IP details\n";
    print "  create     Create a floating IP\n";
    print "  delete     Delete a floating IP\n";
    print "  assign     Assign to a server\n";
    print "  unassign   Unassign from server\n";
}

1;
