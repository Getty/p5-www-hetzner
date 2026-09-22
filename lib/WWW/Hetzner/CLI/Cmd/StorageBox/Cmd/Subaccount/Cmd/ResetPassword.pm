package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::ResetPassword;
# ABSTRACT: Reset a Storage Box subaccount password

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount reset-password --password <password> <storage-box> <subaccount>';
use WWW::Hetzner::Storage::API::Subaccounts;
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount reset-password 42 1 --password new-secret
    hcloud.pl storage-box subaccount reset-password 42 1 --password new-secret --no-wait

=head1 DESCRIPTION

Resets a subaccount password. The supplied password is never echoed to
the output. Polls the action by default unless C<--no-wait> is given.

=cut

option password => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'New subaccount password (input only)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id  = $args->[0] or die "Usage: hcloud.pl storage-box subaccount reset-password <storage-box> <subaccount>\n";
    my $sub = $args->[1] or die "Usage: hcloud.pl storage-box subaccount reset-password <storage-box> <subaccount>\n";

    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $chain->[0]->storage,
        storage_box_id => $id,
    );
    my $action = $subaccounts->reset_subaccount_password($sub, password => $self->password);
    $self->handle_action($action);
    print $self->no_wait ? "Subaccount password reset requested.\n" : "Subaccount password reset.\n";
}

1;
