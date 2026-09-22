package WWW::Hetzner::CLI::Cmd::Network;
# ABSTRACT: Hetzner Cloud Network commands

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::Network::Cmd::List> - List networks

=item * L<describe|WWW::Hetzner::CLI::Cmd::Network::Cmd::Describe> - Describe a network

=item * L<create|WWW::Hetzner::CLI::Cmd::Network::Cmd::Create> - Create a network

=item * L<delete|WWW::Hetzner::CLI::Cmd::Network::Cmd::Delete> - Delete a network

=item * L<add-subnet|WWW::Hetzner::CLI::Cmd::Network::Cmd::AddSubnet> - Add a subnet to a network

=item * L<add-route|WWW::Hetzner::CLI::Cmd::Network::Cmd::AddRoute> - Add a route to a network

=back

=cut

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
