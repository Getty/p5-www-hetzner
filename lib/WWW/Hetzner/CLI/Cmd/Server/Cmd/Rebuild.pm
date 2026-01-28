package WWW::Hetzner::CLI::Cmd::Server::Cmd::Rebuild;
# ABSTRACT: Rebuild a server with a new image

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server rebuild <id> --image <image>';

option image => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Image to rebuild with (e.g., debian-12, ubuntu-24.04)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl server rebuild <id> --image <image>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Rebuilding server $id with image ", $self->image, "...\n";
    $cloud->servers->rebuild($id, $self->image);
    print "Server rebuild initiated. Data on the server will be lost.\n";
}

1;
