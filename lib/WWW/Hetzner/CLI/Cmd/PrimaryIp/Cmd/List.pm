package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::List;
# ABSTRACT: List primary IPs

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $pips = $cloud->primary_ips->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$pips ]), "\n";
        return;
    }

    if (!@$pips) {
        print "No primary IPs found.\n";
        return;
    }

    printf "%-8s %-20s %-6s %-18s %-12s %-10s\n", 'ID', 'NAME', 'TYPE', 'IP', 'DATACENTER', 'ASSIGNEE';
    printf "%-8s %-20s %-6s %-18s %-12s %-10s\n", '-' x 8, '-' x 20, '-' x 6, '-' x 18, '-' x 12, '-' x 10;

    for my $pip (@$pips) {
        printf "%-8s %-20s %-6s %-18s %-12s %-10s\n",
            $pip->id,
            $pip->name // '-',
            $pip->type // '-',
            $pip->ip // '-',
            $pip->datacenter_name // '-',
            $pip->assignee_id // '-';
    }
}

1;
