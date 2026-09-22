package WWW::Hetzner::CLI::Cmd::PlacementGroup;
# ABSTRACT: Hetzner Cloud Placement Group commands

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::List> - List placement groups

=item * L<describe|WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Describe> - Describe a placement group

=item * L<create|WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Create> - Create a placement group

=item * L<delete|WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Delete> - Delete a placement group

=back

=cut

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
