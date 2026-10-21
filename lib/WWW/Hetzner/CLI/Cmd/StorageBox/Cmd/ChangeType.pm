package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::ChangeType;
# ABSTRACT: Change a Storage Box type

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box change-type --type <type> <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option type => ( is => 'ro', format => 's', required => 1, doc => 'Target Storage Box type ID or name' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box change-type --type <type> <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->change_type($id, storage_box_type => $self->type);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box type change requested.\n" : "Storage Box type changed.\n";
}

1;
