package WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::List;
# ABSTRACT: List placement groups

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $pgs = $cloud->placement_groups->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$pgs ]), "\n";
        return;
    }

    if (!@$pgs) {
        print "No placement groups found.\n";
        return;
    }

    printf "%-8s %-30s %-10s %-10s\n", 'ID', 'NAME', 'TYPE', 'SERVERS';
    printf "%-8s %-30s %-10s %-10s\n", '-' x 8, '-' x 30, '-' x 10, '-' x 10;

    for my $pg (@$pgs) {
        printf "%-8s %-30s %-10s %-10d\n",
            $pg->id, $pg->name // '-', $pg->type // '-',
            scalar(@{$pg->servers // []});
    }
}

1;
