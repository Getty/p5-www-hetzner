package WWW::Hetzner::CLI::Cmd::LoadBalancerType;
# ABSTRACT: Load balancer type commands

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl load-balancer-type [options]';
use JSON::MaybeXS qw(encode_json);

=head1 SYNOPSIS

    hcloud.pl load-balancer-type            # List load balancer types
    hcloud.pl -o json load-balancer-type    # ... including their prices

=cut

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $types = $cloud->load_balancer_types->list_all;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$types ]), "\n";
        return;
    }

    if (!@$types) {
        print "No load balancer types found.\n";
        return;
    }

    printf "%-8s %-10s %-14s %-10s %-10s %s\n",
        'ID', 'NAME', 'CONNECTIONS', 'SERVICES', 'TARGETS', 'CERTIFICATES';
    printf "%-8s %-10s %-14s %-10s %-10s %s\n",
        '-' x 8, '-' x 10, '-' x 14, '-' x 10, '-' x 10, '-' x 12;

    for my $t (@$types) {
        printf "%-8s %-10s %-14s %-10s %-10s %s\n",
            $t->id,
            $t->name // '-',
            $t->max_connections // '-',
            $t->max_services // '-',
            $t->max_targets // '-',
            $t->max_assigned_certificates // '-';
    }
}

1;
