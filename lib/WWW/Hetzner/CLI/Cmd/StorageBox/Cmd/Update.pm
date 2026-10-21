package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Update;
# ABSTRACT: Update a Storage Box

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box update --name <name> <storage-box>';
use JSON::MaybeXS qw(encode_json);

option name => ( is => 'ro', format => 's', required => 1, doc => 'New Storage Box name' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box update --name <name> <storage-box>\n";
    my $main = $chain->[0];
    my $box = $main->storage->storage_boxes->update($id, name => $self->name);
    if ($main->output eq 'json') {
        print encode_json($box->data), "\n";
        return;
    }
    print "Storage Box updated:\n";
    printf "  ID:   %s\n", $box->id;
    printf "  Name: %s\n", $box->name;
}

1;
