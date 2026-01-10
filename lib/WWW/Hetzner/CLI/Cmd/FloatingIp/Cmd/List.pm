package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::List;

# ABSTRACT: List floating IPs

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $fips = $cloud->floating_ips->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$fips ]), "\n";
        return;
    }

    if (!@$fips) {
        print "No floating IPs found.\n";
        return;
    }

    printf "%-8s %-20s %-6s %-18s %-10s %-10s\n", 'ID', 'NAME', 'TYPE', 'IP', 'LOCATION', 'SERVER';
    printf "%-8s %-20s %-6s %-18s %-10s %-10s\n", '-' x 8, '-' x 20, '-' x 6, '-' x 18, '-' x 10, '-' x 10;

    for my $fip (@$fips) {
        printf "%-8s %-20s %-6s %-18s %-10s %-10s\n",
            $fip->id,
            $fip->name // '-',
            $fip->type // '-',
            $fip->ip // '-',
            $fip->location // '-',
            $fip->server // '-';
    }
}

1;
