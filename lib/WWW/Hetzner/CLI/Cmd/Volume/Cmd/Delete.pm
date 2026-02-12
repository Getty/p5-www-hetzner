package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Delete;
# ABSTRACT: Delete a volume

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting volume $id...\n";
    $cloud->volumes->delete($id);
    print "Volume deleted.\n";
}

1;
