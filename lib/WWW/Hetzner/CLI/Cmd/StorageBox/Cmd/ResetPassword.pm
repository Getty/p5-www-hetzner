package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::ResetPassword;
# ABSTRACT: Reset a Storage Box password

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box reset-password --password <password> <storage-box>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option password => ( is => 'ro', format => 's', required => 1, doc => 'New Storage Box password' );

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box reset-password --password <password> <storage-box>\n";
    my $action = $chain->[0]->storage->storage_boxes->reset_password($id, password => $self->password);
    $self->handle_action($action);
    print $self->no_wait ? "Storage Box password reset requested.\n" : "Storage Box password reset.\n";
}

1;
