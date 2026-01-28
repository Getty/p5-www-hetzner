package WWW::Hetzner::CLI::Cmd::Firewall;
# ABSTRACT: Hetzner Cloud Firewall commands

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl firewall <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list           List all firewalls\n";
    print "  describe       Show firewall details\n";
    print "  create         Create a firewall\n";
    print "  delete         Delete a firewall\n";
    print "  add-rule       Add a rule to firewall\n";
    print "  apply-to       Apply firewall to server\n";
    print "  remove-from    Remove firewall from server\n";
}

1;
