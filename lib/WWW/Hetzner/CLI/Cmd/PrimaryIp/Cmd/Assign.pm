package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Assign;
# ABSTRACT: Assign a primary IP to a server

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip assign <id> --server <server-id>';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to assign to',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl primary-ip assign <id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Assigning primary IP $id to server ", $self->server, "...\n";
    $cloud->primary_ips->assign($id, $self->server, 'server');
    print "Primary IP assigned.\n";
}

1;
