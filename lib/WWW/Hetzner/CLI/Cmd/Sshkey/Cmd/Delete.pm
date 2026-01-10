package WWW::Hetzner::CLI::Cmd::Sshkey::Cmd::Delete;
our $VERSION = '0.002';
# ABSTRACT: Delete an SSH key

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl sshkey delete <id>';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl sshkey delete <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Deleting SSH key $id...\n";
    $cloud->ssh_keys->delete($id);
    print "SSH key deleted.\n";
}

1;
