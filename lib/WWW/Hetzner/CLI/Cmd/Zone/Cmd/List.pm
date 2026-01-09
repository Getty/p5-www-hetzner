package WWW::Hetzner::CLI::Cmd::Zone::Cmd::List;

# ABSTRACT: List DNS zones

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl zone list [options]';
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

    my $zones = $cloud->zones->list(%params);

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$zones]), "\n";
        return;
    }

    if (!@$zones) {
        print "No zones found.\n";
        return;
    }

    printf "%-15s %-30s %-10s %-8s %s\n",
        'ID', 'NAME', 'STATUS', 'TTL', 'LABELS';
    print "-" x 80, "\n";

    for my $z (@$zones) {
        my $labels = $z->labels;
        my $label_str = join(', ', map { "$_=$labels->{$_}" } keys %$labels);
        printf "%-15s %-30s %-10s %-8s %s\n",
            $z->id,
            $z->name,
            $z->status // '-',
            $z->ttl // '-',
            $label_str || '-';
    }
}

1;
