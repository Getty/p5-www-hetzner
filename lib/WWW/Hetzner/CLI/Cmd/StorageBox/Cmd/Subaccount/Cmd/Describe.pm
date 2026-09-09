package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Subaccount::Cmd::Describe;
# ABSTRACT: Describe a Storage Box subaccount

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box subaccount describe <storage-box> <subaccount>';
use JSON::MaybeXS qw(encode_json);
use WWW::Hetzner::Storage::API::Subaccounts;

=head1 SYNOPSIS

    hcloud.pl storage-box subaccount describe 42 1
    hcloud.pl --output json storage-box subaccount describe 42 1

=head1 DESCRIPTION

Shows a single subaccount of a Storage Box.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $id  = $args->[0] or die "Usage: hcloud.pl storage-box subaccount describe <storage-box> <subaccount>\n";
    my $sub = $args->[1] or die "Usage: hcloud.pl storage-box subaccount describe <storage-box> <subaccount>\n";
    my $main = $chain->[0];
    my $subaccounts = WWW::Hetzner::Storage::API::Subaccounts->new(
        client         => $main->storage,
        storage_box_id => $id,
    );
    my $subaccount = $subaccounts->get($sub);

    if ($main->output eq 'json') {
        print encode_json($subaccount->data), "\n";
        return;
    }

    print "Subaccount:\n";
    printf "  ID:             %s\n", $subaccount->id;
    printf "  Name:           %s\n", ($subaccount->name // '') ne '' ? $subaccount->name : '-';
    printf "  Username:       %s\n", $subaccount->username // '-';
    printf "  Home Directory: %s\n", $subaccount->home_directory // '-';
    printf "  Description:    %s\n", ($subaccount->description // '') ne '' ? $subaccount->description : '-';
    printf "  Created:        %s\n", $subaccount->created // '-';
    my $labels = $subaccount->labels // {};
    if (%$labels) {
        print "  Labels:\n";
        printf "    %s: %s\n", $_, $labels->{$_} for sort keys %$labels;
    }
}

1;
