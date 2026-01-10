package WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Describe;
our $VERSION = '0.002';
# ABSTRACT: Describe a placement group

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl placement-group describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $pg = $cloud->placement_groups->get($id);

    if ($main->output eq 'json') {
        print encode_json($pg->data), "\n";
        return;
    }

    printf "ID:      %s\n", $pg->id;
    printf "Name:    %s\n", $pg->name;
    printf "Type:    %s\n", $pg->type;
    printf "Created: %s\n", $pg->created // '-';

    my $servers = $pg->servers;
    if ($servers && @$servers) {
        printf "Servers: %s\n", join(', ', @$servers);
    } else {
        print "Servers: none\n";
    }
}

1;
