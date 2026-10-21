package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Snapshot::Cmd::Create;
# ABSTRACT: Create a Storage Box snapshot

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box snapshot create [--description <description>] <storage-box>';
use WWW::Hetzner::Storage::API::Snapshots;
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

=head1 SYNOPSIS

    hcloud.pl storage-box snapshot create 42 --description "before upgrade"
    hcloud.pl storage-box snapshot create 42 --description "before upgrade" --no-wait

=head1 DESCRIPTION

Creates a snapshot of a Storage Box. The create action is polled by
default unless C<--no-wait> is given.

=cut

option description => (
    is     => 'ro',
    format => 's',
    doc    => 'Snapshot description',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box snapshot create <storage-box>\n";

    my %params;
    $params{description} = $self->description if defined $self->description;

    print "Creating snapshot for Storage Box $id...\n";
    my $snapshots = WWW::Hetzner::Storage::API::Snapshots->new(
        client         => $chain->[0]->storage,
        storage_box_id => $id,
    );
    my $snapshot = $snapshots->create(%params);
    $self->handle_action($snapshot->action);
    print $self->no_wait ? "Snapshot creation requested.\n" : "Snapshot created.\n";
}

1;
