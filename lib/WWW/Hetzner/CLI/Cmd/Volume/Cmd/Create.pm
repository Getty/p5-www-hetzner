package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Create;
# ABSTRACT: Create a volume

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl volume create --name <name> --size <gb> --location <loc>';
use JSON::MaybeXS qw(encode_json);

option name => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Volume name',
);

option size => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'Volume size in GB (min 10)',
);

option location => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Location (e.g., fsn1, nbg1, hel1)',
);

option format => (
    is      => 'ro',
    format  => 's',
    doc     => 'Filesystem format: ext4, xfs (default: ext4)',
    default => 'ext4',
);

option server => (
    is     => 'ro',
    format => 'i',
    doc    => 'Server ID to attach to',
);

option automount => (
    is      => 'ro',
    doc     => 'Automount volume after attach',
    default => 0,
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Creating volume '", $self->name, "'...\n";

    my $volume = $cloud->volumes->create(
        name      => $self->name,
        size      => $self->size,
        location  => $self->location,
        format    => $self->format,
        server    => $self->server,
        automount => $self->automount,
    );

    if ($main->output eq 'json') {
        print encode_json($volume->data), "\n";
        return;
    }

    print "Volume created:\n";
    printf "  ID:       %s\n", $volume->id;
    printf "  Name:     %s\n", $volume->name;
    printf "  Size:     %s GB\n", $volume->size;
    printf "  Location: %s\n", $volume->location;
    printf "  Device:   %s\n", $volume->linux_device // '-';
    printf "  Server:   %s\n", $volume->server // 'not attached';
}

1;
