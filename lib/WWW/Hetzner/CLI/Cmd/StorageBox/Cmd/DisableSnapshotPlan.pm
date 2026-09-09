package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::DisableSnapshotPlan;
# ABSTRACT: Disable a Storage Box snapshot plan

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box disable-snapshot-plan <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box disable-snapshot-plan <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->disable_snapshot_plan($id);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box snapshot plan disable requested.\n" : "Storage Box snapshot plan disabled.\n";
}

1;
