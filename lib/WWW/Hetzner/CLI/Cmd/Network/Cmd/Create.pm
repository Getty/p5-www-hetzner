package WWW::Hetzner::CLI::Cmd::Network::Cmd::Create;
# ABSTRACT: Create a network

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network create --name <name> --ip-range <cidr>';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Network name',
);

option 'ip_range' => (
    is       => 'ro',
    format   => 's',
    required => 1,
    long_doc => 'ip-range',
    doc      => 'IP range in CIDR notation (e.g. 10.0.0.0/8)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating network '", $self->name, "'...\n";
    my $network = $cloud->networks->create(
        name     => $self->name,
        ip_range => $self->ip_range,
    );
    print "Network created with ID ", $network->id, "\n";
}

1;
