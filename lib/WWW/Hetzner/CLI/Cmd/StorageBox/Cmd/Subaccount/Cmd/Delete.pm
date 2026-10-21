package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Delete;
# ABSTRACT: Delete a Storage Box subaccount

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount delete <storage-box> <subaccount>';
use WWW::Hetzner::Storage::API::Subaccounts;
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount delete 42 1
    hcloud.pl storage-box subaccount delete 42 1 --no-wait

=head1 DESCRIPTION

Deletes a subaccount of a Storage Box. Polls the action by default unless
C<--no-wait> is given.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $id  = $args->[0] or die "Usage: hcloud.pl storage-box subaccount delete <storage-box> <subaccount>\n";
    my $sub = $args->[1] or die "Usage: hcloud.pl storage-box subaccount delete <storage-box> <subaccount>\n";

    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $chain->[0]->storage,
        storage_box_id => $id,
    );
    my $action = $subaccounts->delete($sub);
    $self->handle_action($action);
    print $self->no_wait ? "Subaccount deletion requested.\n" : "Subaccount deleted.\n";
}

1;
