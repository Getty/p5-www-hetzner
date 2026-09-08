package WWW::Hetzner::CLI::Cmd::Server::Cmd::Delete;
# ABSTRACT: Delete a server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server delete <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;

    my $id = $args->[0] or die "Usage: hcloud server delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting server $id...\n";
    my $action = $cloud->servers->delete($id);
    $self->handle_action($action);
    print $self->no_wait ? "Delete requested.\n" : "Server deleted.\n";
}

1;
