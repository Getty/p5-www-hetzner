package WWW::Hetzner::CLI::Cmd::Certificate;

# ABSTRACT: Hetzner Cloud Certificate commands

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate <subcommand>';

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl certificate <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list       List all certificates\n";
    print "  describe   Show certificate details\n";
    print "  create     Create a certificate\n";
    print "  delete     Delete a certificate\n";
}

1;
