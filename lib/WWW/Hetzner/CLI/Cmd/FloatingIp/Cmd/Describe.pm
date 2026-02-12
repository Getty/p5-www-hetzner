package WWW::Hetzner::CLI::Cmd::FloatingIp::Cmd::Describe;
# ABSTRACT: Describe a floating IP

our $VERSION = '0.101';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl floating-ip describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl floating-ip describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $fip = $cloud->floating_ips->get($id);

    if ($main->output eq 'json') {
        print encode_json($fip->data), "\n";
        return;
    }

    printf "ID:          %s\n", $fip->id;
    printf "Name:        %s\n", $fip->name // '-';
    printf "Description: %s\n", $fip->description // '-';
    printf "IP:          %s\n", $fip->ip;
    printf "Type:        %s\n", $fip->type;
    printf "Location:    %s\n", $fip->location // '-';
    printf "Server:      %s\n", $fip->server // 'not assigned';
    printf "Blocked:     %s\n", $fip->blocked ? 'yes' : 'no';
    printf "Created:     %s\n", $fip->created // '-';

    my $dns_ptr = $fip->dns_ptr;
    if ($dns_ptr && @$dns_ptr) {
        print "DNS PTR:\n";
        for my $ptr (@$dns_ptr) {
            printf "  %s -> %s\n", $ptr->{ip}, $ptr->{dns_ptr};
        }
    }

    my $labels = $fip->labels;
    if ($labels && %$labels) {
        print "Labels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
