package WWW::Hetzner::CLI::Cmd::Certificate::Cmd::Create;
# ABSTRACT: Create a managed certificate

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl certificate create --name <name> --domain <domain> [--domain <domain>...]';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Certificate name',
);

option domain => (
    is       => 'ro',
    format   => 's@',
    required => 1,
    doc      => 'Domain name (can specify multiple)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating managed certificate '", $self->name, "'...\n";
    my $cert = $cloud->certificates->create(
        name         => $self->name,
        type         => 'managed',
        domain_names => $self->domain,
    );
    print "Certificate created with ID ", $cert->id, "\n";
}

1;
