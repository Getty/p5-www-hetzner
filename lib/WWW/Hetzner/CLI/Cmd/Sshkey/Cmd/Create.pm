package WWW::Hetzner::CLI::Cmd::Sshkey::Cmd::Create;
our $VERSION = '0.002';
# ABSTRACT: Create an SSH key

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl sshkey create --name <name> --public-key <key>';
use JSON::MaybeXS qw(encode_json);
use Path::Tiny qw(path);

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'SSH key name',
);

option public_key => (
    is     => 'ro',
    format => 's',
    doc    => 'Public key string',
);

option public_key_from_file => (
    is     => 'ro',
    format => 's',
    doc    => 'Read public key from file',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $public_key = $self->public_key;
    if ($self->public_key_from_file) {
        $public_key = path($self->public_key_from_file)->slurp_utf8;
        $public_key =~ s/\s+$//;
    }

    die "Either --public-key or --public-key-from-file required\n"
        unless $public_key;

    my $key = $cloud->ssh_keys->create(
        name       => $self->name,
        public_key => $public_key,
    );

    if ($main->output eq 'json') {
        print encode_json($key->data), "\n";
    } else {
        print "SSH key created:\n";
        printf "  ID:          %s\n", $key->id;
        printf "  Name:        %s\n", $key->name;
        printf "  Fingerprint: %s\n", $key->fingerprint;
    }
}

1;
