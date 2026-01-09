package WWW::Hetzner::CLI::Cmd::Location;

# ABSTRACT: Location commands

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl location [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;
    my $locations = $cloud->locations->list;

    if ($main->output eq 'json') {
        print encode_json($locations), "\n";
        return;
    }

    printf "%-10s %-30s %-10s %s\n", 'ID', 'NAME', 'COUNTRY', 'CITY';
    print "-" x 70, "\n";

    for my $l (@$locations) {
        printf "%-10s %-30s %-10s %s\n",
            $l->{id},
            $l->{name},
            $l->{country},
            $l->{city};
    }
}

1;
