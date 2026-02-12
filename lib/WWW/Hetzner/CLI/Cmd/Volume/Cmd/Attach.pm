package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Attach;
# ABSTRACT: Attach a volume to a server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume attach <volume-id> --server <server-id>';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to attach to',
);

option automount => (
    is      => 'ro',
    doc     => 'Automount volume after attach',
    default => 0,
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume attach <volume-id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Attaching volume $id to server ", $self->server, "...\n";
    $cloud->volumes->attach($id, $self->server, automount => $self->automount);
    print "Volume attached.\n";
}

1;
