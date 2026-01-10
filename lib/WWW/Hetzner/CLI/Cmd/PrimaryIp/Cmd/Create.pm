package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Create;

# ABSTRACT: Create a primary IP

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip create --name <name> --type <ipv4|ipv6> --datacenter <dc>';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Primary IP name',
);

option type => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'IP type: ipv4 or ipv6',
);

option datacenter => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Datacenter (e.g. fsn1-dc14)',
);

option 'auto_delete' => (
    is       => 'ro',
    long_doc => 'auto-delete',
    doc      => 'Auto delete when server is deleted',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating primary IP...\n";
    my $pip = $cloud->primary_ips->create(
        name          => $self->name,
        type          => $self->type,
        assignee_type => 'server',
        datacenter    => $self->datacenter,
        ($self->auto_delete ? (auto_delete => 1) : ()),
    );
    print "Primary IP created with ID ", $pip->id, " (", $pip->ip, ")\n";
}

1;
