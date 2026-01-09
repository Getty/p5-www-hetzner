package WWW::Hetzner::CLI::Cmd::Image;

# ABSTRACT: Image commands

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl image [--type system|snapshot|backup] [options]';
use JSON::MaybeXS qw(encode_json);

option type => (
    is      => 'ro',
    format  => 's',
    doc     => 'Filter by type (system, snapshot, backup)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{type} = $self->type if $self->type;

    my $images = $cloud->images->list(%params);

    if ($main->output eq 'json') {
        print encode_json($images), "\n";
        return;
    }

    printf "%-10s %-20s %-10s %-15s %s\n",
        'ID', 'NAME', 'TYPE', 'OS', 'STATUS';
    print "-" x 70, "\n";

    for my $i (@$images) {
        printf "%-10s %-20s %-10s %-15s %s\n",
            $i->{id},
            $i->{name} // '-',
            $i->{type},
            ($i->{os_flavor} // '') . ' ' . ($i->{os_version} // ''),
            $i->{status};
    }
}

1;
