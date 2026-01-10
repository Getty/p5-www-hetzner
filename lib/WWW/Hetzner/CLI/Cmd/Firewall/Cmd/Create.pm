package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Create;
our $VERSION = '0.002';
# ABSTRACT: Create a firewall

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall create --name <name>';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Firewall name',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating firewall '", $self->name, "'...\n";
    my $fw = $cloud->firewalls->create(
        name => $self->name,
    );
    print "Firewall created with ID ", $fw->id, "\n";
}

1;
