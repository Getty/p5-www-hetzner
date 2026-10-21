package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount;
# ABSTRACT: Storage Box subaccount commands

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount <command> [options] <storage-box>';
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::Storage::API::Subaccounts;

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount list 42
    hcloud.pl storage-box subaccount describe 42 1
    hcloud.pl storage-box subaccount create 42 --home-directory backup/host01 --password secret
    hcloud.pl storage-box subaccount delete 42 1

=head1 DESCRIPTION

Manage subaccounts of a single Storage Box. Without an explicit subcommand,
the subaccount list for the given Storage Box is shown.

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::List>

=item * L<describe|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Describe>

=item * L<create|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Create>

=item * L<update|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Update>

=item * L<delete|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Delete>

=item * L<reset-password|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::ResetPassword>

=item * L<change-home-directory|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::ChangeHomeDirectory>

=item * L<update-access-settings|WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::UpdateAccessSettings>

=back

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    $self->_list($args, $chain);
}

sub _list {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box subaccount list <storage-box>\n";
    my $main = $chain->[0];
    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $main->storage,
        storage_box_id => $id,
    )->list;

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$subaccounts]), "\n";
        return;
    }

    if (!@$subaccounts) {
        print "No subaccounts found.\n";
        return;
    }

    printf "%-10s %-25s %-25s %-40s %s\n", 'ID', 'NAME', 'USERNAME', 'HOME_DIRECTORY', 'DESCRIPTION';
    print '-' x 120, "\n";
    for my $sub (@$subaccounts) {
        printf "%-10s %-25s %-25s %-40s %s\n",
            $sub->id,
            ($sub->name // '') ne '' ? $sub->name : '-',
            $sub->username // '-',
            $sub->home_directory // '-',
            ($sub->description // '') ne '' ? $sub->description : '-';
    }
}

=seealso

=over 4

=item * L<WWW::Hetzner::CLI::Cmd::StorageBox> - Parent Storage Box command tree

=item * L<WWW::Hetzner::Storage::Subaccount> - Subaccount entity

=back

=cut

1;
