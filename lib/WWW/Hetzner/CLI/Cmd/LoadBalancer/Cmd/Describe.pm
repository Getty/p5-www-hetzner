package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::Describe;
our $VERSION = '0.002';
# ABSTRACT: Describe a load balancer

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl load-balancer describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $lb = $cloud->load_balancers->get($id);

    if ($main->output eq 'json') {
        print encode_json($lb->data), "\n";
        return;
    }

    printf "ID:        %s\n", $lb->id;
    printf "Name:      %s\n", $lb->name;
    printf "Type:      %s\n", $lb->type_name // '-';
    printf "IPv4:      %s\n", $lb->ipv4 // '-';
    printf "IPv6:      %s\n", $lb->ipv6 // '-';
    printf "Location:  %s\n", $lb->location_name // '-';
    printf "Algorithm: %s\n", $lb->algorithm->{type} // '-';
    printf "Created:   %s\n", $lb->created // '-';

    my $targets = $lb->targets;
    if ($targets && @$targets) {
        print "\nTargets:\n";
        for my $t (@$targets) {
            if ($t->{type} eq 'server' && $t->{server}) {
                printf "  - Server %d\n", $t->{server}{id};
            } elsif ($t->{type} eq 'label_selector') {
                printf "  - Label: %s\n", $t->{label_selector}{selector};
            }
        }
    }

    my $services = $lb->services;
    if ($services && @$services) {
        print "\nServices:\n";
        for my $s (@$services) {
            printf "  - %s :%d -> :%d\n",
                $s->{protocol},
                $s->{listen_port},
                $s->{destination_port};
        }
    }
}

1;
