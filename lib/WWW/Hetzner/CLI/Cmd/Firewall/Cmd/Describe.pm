package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::Describe;
# ABSTRACT: Describe a firewall

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl firewall describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $fw = $cloud->firewalls->get($id);

    if ($main->output eq 'json') {
        print encode_json($fw->data), "\n";
        return;
    }

    printf "ID:      %s\n", $fw->id;
    printf "Name:    %s\n", $fw->name;
    printf "Created: %s\n", $fw->created // '-';

    my $rules = $fw->rules;
    if ($rules && @$rules) {
        print "\nRules:\n";
        for my $r (@$rules) {
            my $port = $r->{port} // 'any';
            my $proto = $r->{protocol} // 'any';
            my $dir = $r->{direction} // 'in';
            my $sources = $r->{source_ips} ? join(', ', @{$r->{source_ips}}) : 'any';
            my $dests = $r->{destination_ips} ? join(', ', @{$r->{destination_ips}}) : 'any';

            if ($dir eq 'in') {
                printf "  - %s %s/%s from %s\n", $dir, $proto, $port, $sources;
            } else {
                printf "  - %s %s/%s to %s\n", $dir, $proto, $port, $dests;
            }
        }
    }

    my $applied = $fw->applied_to;
    if ($applied && @$applied) {
        print "\nApplied to:\n";
        for my $a (@$applied) {
            my $type = $a->{type};
            if ($type eq 'server' && $a->{server}) {
                printf "  - Server %d\n", $a->{server}{id};
            } elsif ($type eq 'label_selector' && $a->{label_selector}) {
                printf "  - Label: %s\n", $a->{label_selector}{selector};
            }
        }
    }

    my $labels = $fw->labels;
    if ($labels && %$labels) {
        print "\nLabels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
