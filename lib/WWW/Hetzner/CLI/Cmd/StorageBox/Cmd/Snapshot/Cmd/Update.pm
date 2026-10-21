package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Snapshot::Cmd::Update;
# ABSTRACT: Update a Storage Box snapshot

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box snapshot update [--description <description>] <storage-box> <snapshot>';
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::Storage::API::Snapshots;

=head1 SYNOPSIS

    hcloud.pl storage-box snapshot update 42 1 --description "after upgrade"
    hcloud.pl --output json storage-box snapshot update 42 1 --description "after upgrade"

=head1 DESCRIPTION

Updates the description of a snapshot. The returned entity is displayed;
no action is polled.

=cut

option description => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'New snapshot description',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id   = $args->[0] or die "Usage: hcloud.pl storage-box snapshot update <storage-box> <snapshot>\n";
    my $snap = $args->[1] or die "Usage: hcloud.pl storage-box snapshot update <storage-box> <snapshot>\n";
    my $main = $chain->[0];

    my $snapshots = WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $main->storage,
        storage_box_id => $id,
    );
    my $snapshot = $snapshots->update(
        $snap,
        description => $self->description,
    );

    if ($main->output eq 'json') {
        print encode_json($snapshot->data), "\n";
        return;
    }

    print "Snapshot updated:\n";
    printf "  ID:          %s\n", $snapshot->id;
    printf "  Name:        %s\n", $snapshot->name // '-';
    printf "  Description: %s\n", ($snapshot->description // '') ne '' ? $snapshot->description : '-';
    printf "  Created:     %s\n", $snapshot->created // '-';
}

1;
