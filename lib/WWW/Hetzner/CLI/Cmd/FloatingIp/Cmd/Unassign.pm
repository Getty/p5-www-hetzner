package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Unassign;
# ABSTRACT: Unassign a floating IP from its server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip unassign <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl floating-ip unassign <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Unassigning floating IP $id...\n";
    my $action = $cloud->floating_ips->unassign($id);
    $self->handle_action($action);
    print $self->no_wait ? "Floating IP unassignment requested.\n" : "Floating IP unassigned.\n";
}

1;
