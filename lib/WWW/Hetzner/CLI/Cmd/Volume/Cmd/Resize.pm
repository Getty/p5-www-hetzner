package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Resize;
# ABSTRACT: Resize a volume

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume resize <id> --size <gb>';
with 'WWW::Hetzner::CLI::Role::WaitsForAction';

option size => (
    is       => 'ro',
    format   => 'i',
    required => 1,
    doc      => 'New size in GB (can only increase)',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume resize <id> --size <gb>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    print "Resizing volume $id to ", $self->size, " GB...\n";
    my $action = $cloud->volumes->resize($id, $self->size);
    $self->handle_action($action);
    print $self->no_wait ? "Volume resize requested.\n" : "Volume resized.\n";
}

1;
