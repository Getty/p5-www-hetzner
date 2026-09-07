package WWW::Hetzner::CLI::Cmd::Server::Cmd::Reboot;
# ABSTRACT: Reboot a server (soft)

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server reboot <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server reboot <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Rebooting server $id...\n";
    my $action = $cloud->servers->reboot($id);
    $self->handle_action($action);
    print $self->no_wait ? "Server reboot requested.\n" : "Server rebooted.\n";
}

1;
