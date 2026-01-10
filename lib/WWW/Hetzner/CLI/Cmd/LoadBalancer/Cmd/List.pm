package WWW::Hetzner::CLI::Cmd::LoadBalancer::Cmd::List;

# ABSTRACT: List load balancers

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl load-balancer list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $lbs = $cloud->load_balancers->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$lbs ]), "\n";
        return;
    }

    if (!@$lbs) {
        print "No load balancers found.\n";
        return;
    }

    printf "%-8s %-25s %-10s %-18s %-10s\n", 'ID', 'NAME', 'TYPE', 'IPV4', 'LOCATION';
    printf "%-8s %-25s %-10s %-18s %-10s\n", '-' x 8, '-' x 25, '-' x 10, '-' x 18, '-' x 10;

    for my $lb (@$lbs) {
        printf "%-8s %-25s %-10s %-18s %-10s\n",
            $lb->id,
            $lb->name // '-',
            $lb->type_name // '-',
            $lb->ipv4 // '-',
            $lb->location_name // '-';
    }
}

1;
