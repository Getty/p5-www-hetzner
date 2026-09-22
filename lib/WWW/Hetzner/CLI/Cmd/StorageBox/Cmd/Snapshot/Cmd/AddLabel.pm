package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Snapshot::Cmd::AddLabel;
# ABSTRACT: Add a label to a Storage Box snapshot

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box snapshot add-label <storage-box> <snapshot> <key>=<value>';
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::Storage::API::Snapshots;

=head1 SYNOPSIS

    hcloud.pl storage-box snapshot add-label 42 1 release=before-upgrade

=head1 DESCRIPTION

Reads the snapshot, merges the supplied key=value label into the existing
label set, and writes it back. Other labels are preserved.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $id      = $args->[0] or die "Usage: hcloud.pl storage-box snapshot add-label <storage-box> <snapshot> <key>=<value>\n";
    my $snap    = $args->[1] or die "Usage: hcloud.pl storage-box snapshot add-label <storage-box> <snapshot> <key>=<value>\n";
    my $label   = $args->[2] or die "Usage: hcloud.pl storage-box snapshot add-label <storage-box> <snapshot> <key>=<value>\n";
    my ($key, $value) = split /=/, $label, 2;
    die "Label must be key=value\n" unless defined $key && length $key && defined $value;

    my $main = $chain->[0];
    my $snapshots = WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $main->storage,
        storage_box_id => $id,
    );
    my $snapshot = $snapshots->get($snap);
    my %labels = %{ $snapshot->labels // {} };
    $labels{$key} = $value;
    my $updated = $snapshots->update($snap, labels => \%labels);

    if ($main->output eq 'json') {
        print encode_json($updated->data), "\n";
        return;
    }

    print "Snapshot labels updated:\n";
    printf "  ID:   %s\n", $updated->id;
    printf "  Name: %s\n", $updated->name // '-';
    my $new_labels = $updated->labels // {};
    if (%$new_labels) {
        print "  Labels:\n";
        printf "    %s: %s\n", $_, $new_labels->{$_} for sort keys %$new_labels;
    }
}

1;
