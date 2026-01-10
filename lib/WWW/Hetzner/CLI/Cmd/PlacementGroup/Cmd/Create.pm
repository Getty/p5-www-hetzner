package WWW::Hetzner::CLI::Cmd::PlacementGroup::Cmd::Create;

# ABSTRACT: Create a placement group

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl placement-group create --name <name>';

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Placement group name',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating placement group '", $self->name, "'...\n";
    my $pg = $cloud->placement_groups->create(
        name => $self->name,
        type => 'spread',
    );
    print "Placement group created with ID ", $pg->id, "\n";
}

1;
