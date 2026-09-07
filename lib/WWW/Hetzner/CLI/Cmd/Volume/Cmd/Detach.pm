package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Detach;
# ABSTRACT: Detach a volume from a server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume detach <id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume detach <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Detaching volume $id...\n";
    my $action = $cloud->volumes->detach($id);
    $self->handle_action($action);
    print $self->no_wait ? "Volume detach requested.\n" : "Volume detached.\n";
}

1;
