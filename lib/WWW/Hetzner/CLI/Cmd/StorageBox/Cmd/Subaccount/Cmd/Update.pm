package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Update;
# ABSTRACT: Update a Storage Box subaccount

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount update [--name <name>] [--description <description>] <storage-box> <subaccount>';
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::Storage::API::Subaccounts;

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount update 42 1 --name host01 --description "host01 backup"
    hcloud.pl --output json storage-box subaccount update 42 1 --name host01

=head1 DESCRIPTION

Updates the C<name> and/or C<description> of a subaccount. Only the
supplied fields are sent in the request body. The returned entity is
displayed; no action is polled.

=cut

option name => (
    is     => 'ro',
    format => 's',
    doc    => 'New subaccount name',
);

option description => (
    is     => 'ro',
    format => 's',
    doc    => 'New subaccount description',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id  = $args->[0] or die "Usage: hcloud.pl storage-box subaccount update <storage-box> <subaccount>\n";
    my $sub = $args->[1] or die "Usage: hcloud.pl storage-box subaccount update <storage-box> <subaccount>\n";
    my $main = $chain->[0];

    my %body;
    $body{name} = $self->name if defined $self->name;
    $body{description} = $self->description if defined $self->description;

    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $main->storage,
        storage_box_id => $id,
    );
    my $subaccount = $subaccounts->update($sub, %body);

    if ($main->output eq 'json') {
        print encode_json($subaccount->data), "\n";
        return;
    }

    print "Subaccount updated:\n";
    printf "  ID:             %s\n", $subaccount->id;
    printf "  Name:           %s\n", ($subaccount->name // '') ne '' ? $subaccount->name : '-';
    printf "  Username:       %s\n", $subaccount->username // '-';
    printf "  Home Directory: %s\n", $subaccount->home_directory // '-';
    printf "  Description:    %s\n", ($subaccount->description // '') ne '' ? $subaccount->description : '-';
}

1;
