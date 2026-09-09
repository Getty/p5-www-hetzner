package WWW::Hetzner::CLI::Cmd::FloatingIp;
# ABSTRACT: Hetzner Cloud Floating IP commands

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::List> - List floating IPs

=item * L<describe|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Describe> - Describe a floating IP

=item * L<create|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Create> - Create a floating IP

=item * L<delete|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Delete> - Delete a floating IP

=item * L<assign|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Assign> - Assign a floating IP to a server

=item * L<unassign|WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Unassign> - Unassign a floating IP from its server

=back

=cut

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
