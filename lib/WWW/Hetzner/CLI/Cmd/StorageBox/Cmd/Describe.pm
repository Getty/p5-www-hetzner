package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Describe;
# ABSTRACT: Describe a Storage Box

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box describe <storage-box>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box describe <storage-box>\n";
    my $main = $chain->[0];
    my $box = $main->storage->storage_boxes->get($id);

    if ($main->output eq 'json') {
        print encode_json($box->data), "\n";
        return;
    }

    my $type = $box->storage_box_type;
    my $location = $box->location;
    print "Storage Box:\n";
    printf "  ID:       %s\n", $box->id;
    printf "  Name:     %s\n", $box->name;
    printf "  Type:     %s\n", ref $type eq 'HASH' ? ($type->{name} // '-') : ($type // '-');
    printf "  Location: %s\n", ref $location eq 'HASH' ? ($location->{name} // '-') : ($location // '-');
    printf "  Status:   %s\n", $box->status // '-';
    printf "  Username: %s\n", $box->username // '-';
    printf "  Server:   %s\n", $box->server // '-';
    my $labels = $box->labels // {};
    if (%$labels) {
        print "  Labels:\n";
        printf "    %s: %s\n", $_, $labels->{$_} for sort keys %$labels;
    }
}

1;
