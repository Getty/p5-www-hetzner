package WWW::Hetzner::CLI::Cmd::PrimaryIp;
# ABSTRACT: Hetzner Cloud Primary IP commands

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::List> - List primary IPs

=item * L<describe|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Describe> - Describe a primary IP

=item * L<create|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Create> - Create a primary IP

=item * L<delete|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Delete> - Delete a primary IP

=item * L<assign|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Assign> - Assign a primary IP to a server

=item * L<unassign|WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Unassign> - Unassign a primary IP from its server

=back

=cut

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
