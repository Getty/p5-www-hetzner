package WWW::Hetzner::CLI::Cmd::Server;
# ABSTRACT: Server commands

our $VERSION = '0.002';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl server <command> [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    # Default to list
    $self->_list($chain);
}

option selector => (
    is     => 'ro',
    format => 's',
    short  => 'l',
    doc    => 'Label selector (e.g., env=prod)',
);

option name => (
    is     => 'ro',
    format => 's',
    short  => 'n',
    doc    => 'Filter by name',
);

sub _list {
    my ($self, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{label_selector} = $self->selector if $self->selector;
    $params{name} = $self->name if $self->name;

    my $servers = $cloud->servers->list(%params);

    if ($main->output eq 'json') {
        print encode_json($servers), "\n";
        return;
    }

    # Table output
    if (!@$servers) {
        print "No servers found.\n";
        return;
    }

    printf "%-10s %-25s %-12s %-16s %-10s %s\n",
        'ID', 'NAME', 'STATUS', 'IPV4', 'TYPE', 'DATACENTER';
    print "-" x 90, "\n";

    for my $s (@$servers) {
        printf "%-10s %-25s %-12s %-16s %-10s %s\n",
            $s->{id},
            $s->{name},
            $s->{status},
            $s->{public_net}{ipv4}{ip} // '-',
            $s->{server_type}{name} // '-',
            $s->{datacenter}{name} // '-';
    }
}

1;
