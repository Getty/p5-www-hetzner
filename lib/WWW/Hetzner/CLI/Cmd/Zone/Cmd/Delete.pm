package WWW::Hetzner::CLI::Cmd::Zone::Cmd::Delete;

# ABSTRACT: Delete a DNS zone

use Moo;
use MooX::Cmd;
use MooX::Options;

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $id = $args->[0] or die "Usage: zone delete <zone-id>\n";

    $cloud->zones->delete($id);

    print "Zone $id deleted.\n";
}

1;
