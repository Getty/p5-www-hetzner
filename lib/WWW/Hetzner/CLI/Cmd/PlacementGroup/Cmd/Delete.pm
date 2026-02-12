package WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Delete;
# ABSTRACT: Delete a placement group

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl placement-group delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting placement group $id...\n";
    $cloud->placement_groups->delete($id);
    print "Placement group deleted.\n";
}

1;
