package WWW::Hetzner::CLI::Cmd::Server::Cmd::Reset;
# ABSTRACT: Reset a server (hard)

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server reset <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server reset <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Resetting server $id...\n";
    my $action = $cloud->servers->reset($id);
    $self->handle_action($action);
    print $self->no_wait ? "Server reset requested.\n" : "Server reset.\n";
}

1;
