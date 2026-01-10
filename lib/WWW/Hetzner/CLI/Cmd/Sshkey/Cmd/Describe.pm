package WWW::Hetzner::CLI::Cmd::Sshkey::Cmd::Describe;
our $VERSION = '0.002';
# ABSTRACT: Describe an SSH key

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl sshkey describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl sshkey describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $key = $cloud->ssh_keys->get($id);

    if ($main->output eq 'json') {
        print encode_json($key->data), "\n";
    } else {
        printf "ID:          %s\n", $key->id;
        printf "Name:        %s\n", $key->name;
        printf "Fingerprint: %s\n", $key->fingerprint;
        printf "Created:     %s\n", $key->created // '-';
        printf "Public Key:\n%s\n", $key->public_key;
    }
}

1;
