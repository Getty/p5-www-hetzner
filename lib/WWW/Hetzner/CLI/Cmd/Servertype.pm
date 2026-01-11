package WWW::Hetzner::CLI::Cmd::Servertype;
# ABSTRACT: Server type commands

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl servertype [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;
    my $types = $cloud->server_types->list;

    if ($main->output eq 'json') {
        print encode_json($types), "\n";
        return;
    }

    printf "%-10s %-12s %-8s %-10s %-10s %s\n",
        'ID', 'NAME', 'CORES', 'MEMORY', 'DISK', 'DEPRECATED';
    print "-" x 70, "\n";

    for my $t (@$types) {
        printf "%-10s %-12s %-8s %-10s %-10s %s\n",
            $t->{id},
            $t->{name},
            $t->{cores},
            $t->{memory} . ' GB',
            $t->{disk} . ' GB',
            $t->{deprecated} ? 'yes' : '-';
    }
}

1;
