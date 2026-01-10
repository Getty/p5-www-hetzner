package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Detach;

# ABSTRACT: Detach a volume from a server

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume detach <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume detach <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Detaching volume $id...\n";
    $cloud->volumes->detach($id);
    print "Volume detached.\n";
}

1;
