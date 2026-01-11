package WWW::Hetzner::CLI::Cmd::Zone::Cmd::Create;
# ABSTRACT: Create a DNS zone

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl zone create --name <domain> [--ttl <seconds>]';
use JSON::MaybeXS qw(encode_json);

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Zone name (domain)',
);

option ttl => (
    is     => 'ro',
    format => 'i',
    doc    => 'Default TTL in seconds',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params = (
        name => $self->name,
    );
    $params{ttl} = $self->ttl if $self->ttl;

    my $zone = $cloud->zones->create(%params);

    if ($main->output eq 'json') {
        print encode_json($zone->data), "\n";
        return;
    }

    print "Zone created:\n";
    printf "  ID:     %s\n", $zone->id;
    printf "  Name:   %s\n", $zone->name;
    printf "  Status: %s\n", $zone->status // 'pending';

    my $ns = $zone->ns;
    if (@$ns) {
        print "  Nameservers:\n";
        for my $n (@$ns) {
            print "    - $n\n";
        }
    }
}

1;
