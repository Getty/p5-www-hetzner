package WWW::Hetzner::CLI::Cmd::Server::Cmd::List;
our $VERSION = '0.002';
# ABSTRACT: List servers

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl server list [options]';
use JSON::MaybeXS qw(encode_json);

option selector => (
    is     => 'ro',
    format => 's',
    short  => 'l',
    doc    => 'Label selector (e.g., env=prod)',
);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{label_selector} = $self->selector if $self->selector;

    my $servers = $cloud->servers->list(%params);

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$servers]), "\n";
        return;
    }

    if (!@$servers) {
        print "No servers found.\n";
        return;
    }

    printf "%-10s %-25s %-12s %-16s %-10s %s\n",
        'ID', 'NAME', 'STATUS', 'IPV4', 'TYPE', 'DATACENTER';
    print "-" x 90, "\n";

    for my $s (@$servers) {
        printf "%-10s %-25s %-12s %-16s %-10s %s\n",
            $s->id,
            $s->name,
            $s->status,
            $s->ipv4 // '-',
            $s->server_type // '-',
            $s->datacenter // '-';
    }
}

1;
