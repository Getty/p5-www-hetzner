package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Snapshot::Cmd::Delete;
# ABSTRACT: Delete a Storage Box snapshot

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box snapshot delete <storage-box> <snapshot>';
use WWW::Hetzner::Storage::API::Snapshots;
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box snapshot delete 42 1
    hcloud.pl storage-box snapshot delete 42 1 --no-wait

=head1 DESCRIPTION

Deletes a snapshot of a Storage Box. Polls the action by default unless
C<--no-wait> is given.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $id   = $args->[0] or die "Usage: hcloud.pl storage-box snapshot delete <storage-box> <snapshot>\n";
    my $snap = $args->[1] or die "Usage: hcloud.pl storage-box snapshot delete <storage-box> <snapshot>\n";

    my $snapshots = WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $chain->[0]->storage,
        storage_box_id => $id,
    );
    my $action = $snapshots->delete($snap);
    $self->handle_action($action);
    print $self->no_wait ? "Snapshot deletion requested.\n" : "Snapshot deleted.\n";
}

1;
