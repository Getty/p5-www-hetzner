package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::List;
# ABSTRACT: List Storage Boxes

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl storage-box list [options]';
use JSON::MaybeXS qw(encode_json);

option name => ( is => 'ro', format => 's', short => 'n', doc => 'Filter by Storage Box name' );
option selector => ( is => 'ro', format => 's', short => 'l', doc => 'Filter by label selector' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $main = $chain->[0];
    my %params;
    $params{name} = $self->name if defined $self->name;
    $params{label_selector} = $self->selector if defined $self->selector;
    my $boxes = $main->storage->storage_boxes->list_all(%params);

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$boxes]), "\n";
        return;
    }
    if (!@$boxes) {
        print "No Storage Boxes found.\n";
        return;
    }
    printf "%-10s %-25s %-12s %-12s %s\n", 'ID', 'NAME', 'TYPE', 'LOCATION', 'STATUS';
    print '-' x 78, "\n";
    for my $box (@$boxes) {
        my $type = $box->storage_box_type;
        my $location = $box->location;
        printf "%-10s %-25s %-12s %-12s %s\n",
            $box->id,
            $box->name,
            ref $type eq 'HASH' ? ($type->{name} // '-') : ($type // '-'),
            ref $location eq 'HASH' ? ($location->{name} // '-') : ($location // '-'),
            $box->status // '-';
    }
}

1;
