package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::DisableProtection;
# ABSTRACT: Disable Storage Box delete protection

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box disable-protection <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box disable-protection <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->change_protection($id, delete => 0);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box protection change requested.\n" : "Storage Box protection disabled.\n";
}

1;
