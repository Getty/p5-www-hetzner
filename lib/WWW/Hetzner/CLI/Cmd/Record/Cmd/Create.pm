package WWW::Hetzner::CLI::Cmd::Record::Cmd::Create;
# ABSTRACT: Create a DNS record

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl record create --zone <zone-id> --name <name> --type <type> --value <value>';
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
    doc      => 'Record name (e.g., www, @, mail)',
);

option type => (
    is       => 'ro',
    format   => 's',
    short    => 't',
    required => 1,
    doc      => 'Record type (A, AAAA, CNAME, MX, TXT, etc.)',
);

option value => (
    is       => 'ro',
    format   => 's@',
    short    => 'v',
    required => 1,
    autosplit => ',',
    doc      => 'Record value(s), comma-separated for multiple',
);

option ttl => (
    is     => 'ro',
    format => 'i',
    doc    => 'TTL in seconds',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my @records = map { { value => $_ } } @{$self->value};

    my %params = (
        name    => $self->name,
        type    => uc($self->type),
        records => \@records,
    );
    $params{ttl} = $self->ttl if $self->ttl;

    my $rrsets = $cloud->zones->rrsets($self->zone);
    my $record = $rrsets->create(%params);

    if ($main->output eq 'json') {
        print encode_json($record->data), "\n";
        return;
    }

    print "Record created:\n";
    printf "  Name: %s\n", $record->name;
    printf "  Type: %s\n", $record->type;
    printf "  TTL:  %s\n", $record->ttl // '-';
    print "  Values:\n";
    for my $v (@{$record->records}) {
        print "    - $v->{value}\n";
    }
}

1;
