package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Create;
# ABSTRACT: Create a floating IP

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip create --type <ipv4|ipv6> --home-location <location>';

option type => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'IP type: ipv4 or ipv6',
);

option 'home_location' => (
    is       => 'ro',
    format   => 's',
    required => 1,
    long_doc => 'home-location',
    doc      => 'Home location (e.g. fsn1, nbg1)',
);

option name => (
    is     => 'ro',
    format => 's',
    doc    => 'Floating IP name',
);

option description => (
    is     => 'ro',
    format => 's',
    doc    => 'Description',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating floating IP...\n";
    my $fip = $cloud->floating_ips->create(
        type          => $self->type,
        home_location => $self->home_location,
        ($self->name        ? (name        => $self->name)        : ()),
        ($self->description ? (description => $self->description) : ()),
    );
    print "Floating IP created with ID ", $fip->id, " (", $fip->ip, ")\n";
}

1;
