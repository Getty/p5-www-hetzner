package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::List;
# ABSTRACT: List firewalls

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall list';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $firewalls = $cloud->firewalls->list;

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$firewalls ]), "\n";
        return;
    }

    if (!@$firewalls) {
        print "No firewalls found.\n";
        return;
    }

    printf "%-8s %-30s %-8s %-12s\n", 'ID', 'NAME', 'RULES', 'APPLIED_TO';
    printf "%-8s %-30s %-8s %-12s\n", '-' x 8, '-' x 30, '-' x 8, '-' x 12;

    for my $fw (@$firewalls) {
        printf "%-8s %-30s %-8d %-12d\n",
            $fw->id,
            $fw->name // '-',
            scalar(@{ $fw->rules // [] }),
            scalar(@{ $fw->applied_to // [] });
    }
}

1;
