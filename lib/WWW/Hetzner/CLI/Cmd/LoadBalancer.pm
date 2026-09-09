package WWW::Hetzner::CLI::Cmd::LoadBalancer;
# ABSTRACT: Hetzner Cloud Load Balancer commands

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer <subcommand>';

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::List> - List load balancers

=item * L<describe|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Describe> - Describe a load balancer

=item * L<create|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Create> - Create a load balancer

=item * L<delete|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Delete> - Delete a load balancer

=item * L<add-target|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::AddTarget> - Add a target to a load balancer

=item * L<add-service|WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::AddService> - Add a service to a load balancer

=back

=cut

sub execute {
    my ($self) = @_;
    print "Usage: hcloud.pl load-balancer <subcommand>\n\n";
    print "Subcommands:\n";
    print "  list         List all load balancers\n";
    print "  describe     Show load balancer details\n";
    print "  create       Create a load balancer\n";
    print "  delete       Delete a load balancer\n";
    print "  add-target   Add a target to load balancer\n";
    print "  add-service  Add a service to load balancer\n";
}

1;
