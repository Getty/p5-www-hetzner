package WWW::Hetzner::CLI::Cmd::Server::Cmd::Shutdown;
# ABSTRACT: Shutdown a server (graceful)

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server shutdown <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server shutdown <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Shutting down server $id...\n";
    my $action = $cloud->servers->shutdown($id);
    $self->handle_action($action);
    print $self->no_wait ? "Server shutdown requested.\n" : "Server shut down.\n";
}

1;
