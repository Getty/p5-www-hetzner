package WWW::Hetzner::CLI::Cmd::Server::Cmd::Poweron;
# ABSTRACT: Power on a server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server poweron <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server poweron <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Powering on server $id...\n";
    my $action = $cloud->servers->power_on($id);
    $self->handle_action($action);
    print $self->no_wait ? "Power-on requested.\n" : "Server powered on.\n";
}

1;
