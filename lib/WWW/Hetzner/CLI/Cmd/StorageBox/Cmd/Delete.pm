package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Delete;
# ABSTRACT: Delete a Storage Box

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box delete <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box delete <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->delete($id);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box deletion requested.\n" : "Storage Box deleted.\n";
}

1;
