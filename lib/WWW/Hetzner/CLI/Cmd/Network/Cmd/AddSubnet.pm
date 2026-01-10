package WWW::Hetzner::CLI::Cmd::Network::Cmd::AddSubnet;

# ABSTRACT: Add a subnet to a network

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network add-subnet <id> --ip-range <cidr> --type <type> --network-zone <zone>';

option 'ip_range' => (
    is       => 'ro',
    format   => 's',
    required => 1,
    long_doc => 'ip-range',
    doc      => 'Subnet IP range (e.g. 10.0.1.0/24)',
);

option type => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Subnet type: cloud, server, vswitch',
);

option 'network_zone' => (
    is       => 'ro',
    format   => 's',
    required => 1,
    long_doc => 'network-zone',
    doc      => 'Network zone (e.g. eu-central)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl network add-subnet <id> --ip-range <cidr> --type <type> --network-zone <zone>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Adding subnet ", $self->ip_range, " to network $id...\n";
    $cloud->networks->add_subnet($id,
        ip_range     => $self->ip_range,
        type         => $self->type,
        network_zone => $self->network_zone,
    );
    print "Subnet added.\n";
}

1;
