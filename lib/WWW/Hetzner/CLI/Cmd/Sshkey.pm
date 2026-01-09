package WWW::Hetzner::CLI::Cmd::Sshkey;

# ABSTRACT: SSH key commands

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl sshkey [list] [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    # Default to list
    my $main = $chain->[0];
    my $cloud = $main->cloud;
    my $keys = $cloud->ssh_keys->list;

    if ($main->output eq 'json') {
        print encode_json($keys), "\n";
        return;
    }

    if (!@$keys) {
        print "No SSH keys found.\n";
        return;
    }

    printf "%-10s %-30s %s\n", 'ID', 'NAME', 'FINGERPRINT';
    print "-" x 80, "\n";

    for my $k (@$keys) {
        printf "%-10s %-30s %s\n",
            $k->{id},
            $k->{name},
            $k->{fingerprint} // '-';
    }
}

1;
