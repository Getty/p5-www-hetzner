package WWW::Hetzner::CLI::Cmd::Network::Cmd::AddRoute;

# ABSTRACT: Add a route to a network

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network add-route <id> --destination <cidr> --gateway <ip>';

option destination => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Route destination (e.g. 10.100.0.0/16)',
);

option gateway => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Gateway IP address',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl network add-route <id> --destination <cidr> --gateway <ip>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Adding route ", $self->destination, " via ", $self->gateway, " to network $id...\n";
    $cloud->networks->add_route($id,
        destination => $self->destination,
        gateway     => $self->gateway,
    );
    print "Route added.\n";
}

1;
