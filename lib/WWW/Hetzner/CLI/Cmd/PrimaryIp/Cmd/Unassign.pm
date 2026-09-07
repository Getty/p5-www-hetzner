package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Unassign;
# ABSTRACT: Unassign a primary IP from its server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip unassign <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl primary-ip unassign <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Unassigning primary IP $id...\n";
    my $action = $cloud->primary_ips->unassign($id);
    $self->handle_action($action);
    print $self->no_wait ? "Primary IP unassignment requested.\n" : "Primary IP unassigned.\n";
}

1;
