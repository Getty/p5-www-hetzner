package WWW::Hetzner::CLI::Cmd::Network::Cmd::List;
# ABSTRACT: List networks

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl network list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $networks = $cloud->networks->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$networks ]), "\n";
        return;
    }

    if (!@$networks) {
        print "No networks found.\n";
        return;
    }

    printf "%-8s %-25s %-18s %-10s\n", 'ID', 'NAME', 'IP_RANGE', 'SERVERS';
    printf "%-8s %-25s %-18s %-10s\n", '-' x 8, '-' x 25, '-' x 18, '-' x 10;

    for my $n (@$networks) {
        printf "%-8s %-25s %-18s %-10d\n",
            $n->id,
            $n->name // '-',
            $n->ip_range // '-',
            scalar(@{ $n->servers // [] });
    }
}

1;
