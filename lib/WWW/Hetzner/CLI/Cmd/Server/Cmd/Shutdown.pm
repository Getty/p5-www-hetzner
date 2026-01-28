package WWW::Hetzner::CLI::Cmd::Server::Cmd::Shutdown;
# ABSTRACT: Shutdown a server (graceful)

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server shutdown <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server shutdown <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Shutting down server $id...\n";
    $cloud->servers->shutdown($id);
    print "Server shutdown initiated.\n";
}

1;
