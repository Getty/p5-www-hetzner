package WWW::Hetzner::CLI::Cmd::StorageBox::Cmd::Folders;
# ABSTRACT: List Storage Box folders

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl storage-box folders [--path <path>] <storage-box>';
use JSON::MaybeXS qw(encode_json);

=head1 SYNOPSIS

    hcloud.pl storage-box folders 42
    hcloud.pl storage-box folders 42 --path /backup
    hcloud.pl --output json storage-box folders 42

=head1 DESCRIPTION

Lists the folders exposed by a Storage Box at the supplied path (default
C</>).

=cut

option path => (
    is     => 'ro',
    format => 's',
    doc    => 'Folder path (default /)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl storage-box folders <storage-box>\n";
    my $main = $chain->[0];

    my %params;
    $params{path} = $self->path if defined $self->path;

    my $folders = $main->storage->storage_boxes->folders($id, %params);

    if ($main->output eq 'json') {
        print encode_json($folders), "\n";
        return;
    }

    if (!@$folders) {
        print "No folders found.\n";
        return;
    }

    printf "%s\n", 'PATH';
    print '-' x 60, "\n";
    for my $folder (@$folders) {
        printf "%s\n", $folder;
    }
}

1;
