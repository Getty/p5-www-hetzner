package WWW::Hetzner::CLI::Cmd::Zone::Cmd::Describe;
# ABSTRACT: Describe a DNS zone

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl zone describe <zone-id> [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $id = $args->[0] or die "Usage: zone describe <zone-id>\n";

    my $zone = $cloud->zones->get($id);

    if ($main->output eq 'json') {
        print encode_json($zone->data), "\n";
        return;
    }

    print "Zone:\n";
    printf "  ID:      %s\n", $zone->id;
    printf "  Name:    %s\n", $zone->name;
    printf "  Status:  %s\n", $zone->status // '-';
    printf "  TTL:     %s\n", $zone->ttl // '-';
    printf "  Created: %s\n", $zone->created // '-';

    my $ns = $zone->ns;
    if (@$ns) {
        print "  Nameservers:\n";
        for my $n (@$ns) {
            print "    - $n\n";
        }
    }

    my $labels = $zone->labels;
    if (%$labels) {
        print "  Labels:\n";
        for my $k (sort keys %$labels) {
            printf "    %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
