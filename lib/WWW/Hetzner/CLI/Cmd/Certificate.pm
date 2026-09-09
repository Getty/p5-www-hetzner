package WWW::Hetzner::CLI::Cmd::Certificate;
# ABSTRACT: Hetzner Cloud Certificate commands

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::Certificate::Cmd::List> - List certificates

=item * L<describe|WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Describe> - Describe a certificate

=item * L<create|WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Create> - Create a managed certificate

=item * L<delete|WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Delete> - Delete a certificate

=back

=cut

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
