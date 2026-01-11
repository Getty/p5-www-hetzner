package WWW::Hetzner::CLI::Cmd::Server::Cmd::Describe;
# ABSTRACT: Show server details

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl server describe <id> [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $id = $args->[0] or die "Usage: hcloud server describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $server = $cloud->servers->get($id);

    if ($main->output eq 'json') {
        print encode_json($server->data), "\n";
        return;
    }

    printf "ID:          %s\n", $server->id;
    printf "Name:        %s\n", $server->name;
    printf "Status:      %s\n", $server->status;
    printf "Type:        %s\n", $server->server_type;
    printf "Datacenter:  %s\n", $server->datacenter;
    printf "IPv4:        %s\n", $server->ipv4 // '-';
    printf "IPv6:        %s\n", $server->ipv6 // '-';
    printf "Created:     %s\n", $server->created;

    my $labels = $server->labels;
    if ($labels && %$labels) {
        print "Labels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
