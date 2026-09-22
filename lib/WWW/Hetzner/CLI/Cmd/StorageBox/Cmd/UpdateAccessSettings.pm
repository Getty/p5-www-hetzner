package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::UpdateAccessSettings;
# ABSTRACT: Update Storage Box access settings

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box update-access-settings [options] <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box update-access-settings 42 --enable-samba --enable-ssh --no-wait

=head1 DESCRIPTION

Updates the access settings of a Storage Box. Only the flags explicitly
enabled on the command line are sent in the request body; the absence of
a flag leaves the corresponding setting unchanged.

=cut

option enable_samba => ( is => 'ro', negativable => 1, doc => 'Enable Samba' );
option enable_ssh => ( is => 'ro', negativable => 1, doc => 'Enable SSH' );
option enable_webdav => ( is => 'ro', negativable => 1, doc => 'Enable WebDAV' );
option enable_zfs => ( is => 'ro', negativable => 1, doc => 'Show the ZFS Snapshot folder' );
option reachable_externally => ( is => 'ro', negativable => 1, doc => 'Allow access outside Hetzner networks' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box update-access-settings <storage-box>\n";

    my %body;
    $body{samba_enabled} = $self->enable_samba if defined $self->enable_samba;
    $body{ssh_enabled} = $self->enable_ssh if defined $self->enable_ssh;
    $body{webdav_enabled} = $self->enable_webdav if defined $self->enable_webdav;
    $body{zfs_enabled} = $self->enable_zfs if defined $self->enable_zfs;
    $body{reachable_externally} = $self->reachable_externally if defined $self->reachable_externally;

    my $action = $chain->[0]->storage->storage_boxes->update_access_settings($id, %body);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box access settings update requested.\n" : "Storage Box access settings updated.\n";
}

1;
