package WWW::Hetzner::CLI::Cmd::Record::Cmd::Delete;
# ABSTRACT: Delete a DNS record

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl record delete --zone <zone-id> --name <name> --type <type>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option zone => (
    is       => 'ro',
    format   => 's',
    short    => 'z',
    required => 1,
    doc      => 'Zone ID',
);

option name => (
    is       => 'ro',
    format   => 's',
    short    => 'n',
    required => 1,
    doc      => 'Record name',
);

option type => (
    is       => 'ro',
    format   => 's',
    short    => 't',
    required => 1,
    doc      => 'Record type (A, AAAA, CNAME, MX, TXT, etc.)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $rrsets = $cloud->zones->rrsets($self->zone);
    my $action = $rrsets->delete($self->name, uc($self->type));
    $self->handle_action($action);

    print "Record ", $self->name, "/", uc($self->type),
        $self->no_wait ? " delete requested.\n" : " deleted.\n";
}

1;
