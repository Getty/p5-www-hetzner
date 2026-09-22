package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Create;
# ABSTRACT: Create a Storage Box subaccount

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount create --home-directory <dir> --password <password> [--name <name>] [--description <description>] <storage-box>';
use WWW::Hetzner::Storage::API::Subaccounts;
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount create 42 --home-directory backup/host01 --password secret
    hcloud.pl storage-box subaccount create 42 --home-directory backup/host01 --password secret --name host01 --no-wait

=head1 DESCRIPTION

Creates a subaccount of a Storage Box. C<--home-directory> and
C<--password> are required. The supplied password is never echoed to the
output. Polls the create action by default unless C<--no-wait> is given.

=cut

option home_directory => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Subaccount home directory',
);

option password => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Subaccount password (input only)',
);

option name => (
    is     => 'ro',
    format => 's',
    doc    => 'Subaccount display name',
);

option description => (
    is     => 'ro',
    format => 's',
    doc    => 'Subaccount description',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box subaccount create <storage-box>\n";

    my %params = (
        home_directory => $self->home_directory,
        password       => $self->password,
    );
    $params{name} = $self->name if defined $self->name;
    $params{description} = $self->description if defined $self->description;

    print "Creating subaccount for Storage Box $id...\n";
    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $chain->[0]->storage,
        storage_box_id => $id,
    );
    my $subaccount = $subaccounts->create(%params);
    $self->handle_action($subaccount->action);
    print $self->no_wait ? "Subaccount creation requested.\n" : "Subaccount created.\n";
}

1;
