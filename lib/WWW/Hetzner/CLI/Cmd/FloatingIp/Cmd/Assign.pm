package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Assign;
# ABSTRACT: Assign a floating IP to a server

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip assign <id> --server <server-id>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to assign to',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl floating-ip assign <id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Assigning floating IP $id to server ", $self->server, "...\n";
    my $action = $cloud->floating_ips->assign($id, $self->server);
    $self->handle_action($action);
    print $self->no_wait ? "Floating IP assignment requested.\n" : "Floating IP assigned.\n";
}

1;
