package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Delete;
# ABSTRACT: Delete a primary IP

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl primary-ip delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting primary IP $id...\n";
    $cloud->primary_ips->delete($id);
    print "Primary IP deleted.\n";
}

1;
