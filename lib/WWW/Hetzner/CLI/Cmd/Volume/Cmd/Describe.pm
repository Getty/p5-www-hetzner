package WWW::Hetzner::CLI::Cmd::Volume::Cmd::Describe;
# ABSTRACT: Describe a volume

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl volume describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl volume describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $volume = $cloud->volumes->get($id);

    if ($main->output eq 'json') {
        print encode_json($volume->data), "\n";
        return;
    }

    printf "ID:           %s\n", $volume->id;
    printf "Name:         %s\n", $volume->name;
    printf "Size:         %s GB\n", $volume->size;
    printf "Status:       %s\n", $volume->status;
    printf "Location:     %s\n", $volume->location // '-';
    printf "Server:       %s\n", $volume->server // 'not attached';
    printf "Linux Device: %s\n", $volume->linux_device // '-';
    printf "Format:       %s\n", $volume->format // '-';
    printf "Created:      %s\n", $volume->created // '-';

    my $labels = $volume->labels;
    if ($labels && %$labels) {
        print "Labels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
