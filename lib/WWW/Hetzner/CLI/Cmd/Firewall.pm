package WWW::Hetzner::CLI::Cmd::Firewall;
# ABSTRACT: Hetzner Cloud Firewall commands

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::List> - List firewalls

=item * L<describe|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Describe> - Describe a firewall

=item * L<create|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Create> - Create a firewall

=item * L<delete|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Delete> - Delete a firewall

=item * L<add-rule|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::AddRule> - Add a rule to a firewall

=item * L<apply-to|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::ApplyTo> - Apply a firewall to a server

=item * L<remove-from|WWW::Hetzner::CLI::Cmd::Firewall::Cmd::RemoveFrom> - Remove a firewall from a server

=back

=cut

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
