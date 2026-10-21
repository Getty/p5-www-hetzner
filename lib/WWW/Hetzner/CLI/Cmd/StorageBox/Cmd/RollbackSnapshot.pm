package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::RollbackSnapshot;
# ABSTRACT: Roll a Storage Box back to a snapshot

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box rollback-snapshot --snapshot <id> <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box rollback-snapshot 42 --snapshot 1
    hcloud.pl storage-box rollback-snapshot 42 --snapshot 1 --no-wait

=head1 DESCRIPTION

Rolls a Storage Box back to the contents of an existing snapshot.

=cut

option snapshot => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Snapshot ID to roll back to',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box rollback-snapshot --snapshot <id> <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->rollback_snapshot($id, snapshot => $self->snapshot);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box rollback requested.\n" : "Storage Box rolled back to snapshot.\n";
}

1;
