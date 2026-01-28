package WWW::Hetzner::CLI::Cmd::PrimaryIp::Cmd::Describe;
# ABSTRACT: Describe a primary IP

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl primary-ip describe <id>';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl primary-ip describe <id>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $pip = $cloud->primary_ips->get($id);

    if ($main->output eq 'json') {
        print encode_json($pip->data), "\n";
        return;
    }

    printf "ID:           %s\n", $pip->id;
    printf "Name:         %s\n", $pip->name // '-';
    printf "IP:           %s\n", $pip->ip;
    printf "Type:         %s\n", $pip->type;
    printf "Datacenter:   %s\n", $pip->datacenter_name // '-';
    printf "Assignee ID:  %s\n", $pip->assignee_id // 'not assigned';
    printf "Assignee Type:%s\n", $pip->assignee_type // '-';
    printf "Auto Delete:  %s\n", $pip->auto_delete ? 'yes' : 'no';
    printf "Blocked:      %s\n", $pip->blocked ? 'yes' : 'no';
    printf "Created:      %s\n", $pip->created // '-';

    my $dns_ptr = $pip->dns_ptr;
    if ($dns_ptr && @$dns_ptr) {
        print "DNS PTR:\n";
        for my $ptr (@$dns_ptr) {
            printf "  %s -> %s\n", $ptr->{ip}, $ptr->{dns_ptr};
        }
    }

    my $labels = $pip->labels;
    if ($labels && %$labels) {
        print "Labels:\n";
        for my $k (sort keys %$labels) {
            printf "  %s: %s\n", $k, $labels->{$k};
        }
    }
}

1;
