package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::EnableSnapshotPlan;
# ABSTRACT: Enable a Storage Box snapshot plan

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box enable-snapshot-plan --max-snapshots <count> --minute <minute> --hour <hour> [options] <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option max_snapshots => ( is => 'ro', format => 'i', required => 1, doc => 'Maximum retained snapshots' );
option minute => ( is => 'ro', format => 'i', required => 1, doc => 'Minute of scheduled snapshot' );
option hour => ( is => 'ro', format => 'i', required => 1, doc => 'Hour of scheduled snapshot' );
option day_of_week => ( is => 'ro', format => 's', doc => 'Day of week for scheduled snapshot' );
option day_of_month => ( is => 'ro', format => 'i', doc => 'Day of month for scheduled snapshot' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box enable-snapshot-plan --max-snapshots <count> --minute <minute> --hour <hour> <storage-box>\n";
    my %params = (
        max_snapshots => $self->max_snapshots,
        minute        => $self->minute,
        hour          => $self->hour,
    );
    $params{day_of_week} = $self->day_of_week if defined $self->day_of_week;
    $params{day_of_month} = $self->day_of_month if defined $self->day_of_month;
    my $action = $chain->[0]->storage->storage_boxes->enable_snapshot_plan($id, %params);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box snapshot plan enable requested.\n" : "Storage Box snapshot plan enabled.\n";
}

1;
