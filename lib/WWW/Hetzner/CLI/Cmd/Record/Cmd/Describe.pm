package WWW::Hetzner::CLI::Cmd::Record::Cmd::Describe;
# ABSTRACT: Describe a DNS record

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl record describe --zone <zone-id> --name <name> --type <type>';
use JSON::MaybeXS qw(encode_json);

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
    my $record = $rrsets->get($self->name, uc($self->type));

    if ($main->output eq 'json') {
        print encode_json($record->data), "\n";
        return;
    }

    print "Record:\n";
    printf "  Name: %s\n", $record->name;
    printf "  Type: %s\n", $record->type;
    printf "  TTL:  %s\n", $record->ttl // '-';
    print "  Values:\n";
    for my $v (@{$record->records}) {
        print "    - $v->{value}\n";
    }
}

1;
