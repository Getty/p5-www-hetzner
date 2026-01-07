package WWW::Hetzner::CLI::Cmd::Record::Cmd::List;

# ABSTRACT: List DNS records

use Moo;
use MooX::Cmd;
use MooX::Options;
use JSON::MaybeXS qw(encode_json);

option zone => (
    is       => 'ro',
    format   => 's',
    short    => 'z',
    required => 1,
    doc      => 'Zone ID',
);

option type => (
    is     => 'ro',
    format => 's',
    short  => 't',
    doc    => 'Filter by record type (A, AAAA, CNAME, MX, TXT, etc.)',
);

option name => (
    is     => 'ro',
    format => 's',
    short  => 'n',
    doc    => 'Filter by record name',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{type} = $self->type if $self->type;
    $params{name} = $self->name if $self->name;

    my $rrsets = $cloud->zones->rrsets($self->zone);
    my $records = $rrsets->list(%params);

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$records]), "\n";
        return;
    }

    if (!@$records) {
        print "No records found.\n";
        return;
    }

    printf "%-25s %-8s %-8s %s\n",
        'NAME', 'TYPE', 'TTL', 'VALUES';
    print "-" x 80, "\n";

    for my $r (@$records) {
        my $values = join(', ', map { $_->{value} } @{$r->records});
        printf "%-25s %-8s %-8s %s\n",
            $r->name,
            $r->type,
            $r->ttl // '-',
            $values;
    }
}

1;
