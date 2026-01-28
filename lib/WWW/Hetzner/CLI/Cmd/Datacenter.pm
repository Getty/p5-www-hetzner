package WWW::Hetzner::CLI::Cmd::Datacenter;
# ABSTRACT: Datacenter commands

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl datacenter [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;
    my $datacenters = $cloud->datacenters->list;

    if ($main->output eq 'json') {
        print encode_json($datacenters), "\n";
        return;
    }

    printf "%-10s %-15s %-30s %s\n", 'ID', 'NAME', 'DESCRIPTION', 'LOCATION';
    print "-" x 80, "\n";

    for my $d (@$datacenters) {
        printf "%-10s %-15s %-30s %s\n",
            $d->{id},
            $d->{name},
            $d->{description},
            $d->{location}{name} // '-';
    }
}

1;
