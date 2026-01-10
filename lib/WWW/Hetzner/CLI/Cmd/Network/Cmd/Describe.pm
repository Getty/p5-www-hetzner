package WWW::Hetzner::CLI::Cmd::Network::Cmd::Describe;
our $VERSION = '0.002';
# ABSTRACT: Describe a network

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl network describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $network = $cloud->networks->get($id);

    if ($main->output eq 'json') {
        print encode_json($network->data), "\n";
        return;
    }

    printf "ID:       %s\n", $network->id;
    printf "Name:     %s\n", $network->name;
    printf "IP Range: %s\n", $network->ip_range;
    printf "Created:  %s\n", $network->created // '-';

    my $servers = $network->servers;
    if ($servers && @$servers) {
        printf "Servers:  %s\n", join(', ', @$servers);
    } else {
        print "Servers:  none\n";
    }

    my $subnets = $network->subnets;
    if ($subnets && @$subnets) {
        print "\nSubnets:\n";
        for my $s (@$subnets) {
            printf "  - %s (%s, %s)\n",
                $s->{ip_range},
                $s->{network_zone},
                $s->{type};
        }
    }

    my $routes = $network->routes;
    if ($routes && @$routes) {
        print "\nRoutes:\n";
        for my $r (@$routes) {
            printf "  - %s via %s\n", $r->{destination}, $r->{gateway};
        }
    }

    my $labels = $network->labels;
    if ($labels && %$labels) {
        print "\nLabels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
