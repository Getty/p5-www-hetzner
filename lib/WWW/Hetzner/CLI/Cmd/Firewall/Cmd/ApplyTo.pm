package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::ApplyTo;
# ABSTRACT: Apply a firewall to a server

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall apply-to <firewall-id> --server <server-id>';

option server => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Server ID to apply firewall to',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl firewall apply-to <firewall-id> --server <server-id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Applying firewall $id to server ", $self->server, "...\n";
    $cloud->firewalls->apply_to_resources($id,
        { type => 'server', server => { id => $self->server } },
    );
    print "Firewall applied.\n";
}

1;
