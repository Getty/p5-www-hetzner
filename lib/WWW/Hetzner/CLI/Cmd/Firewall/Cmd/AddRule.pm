package WWW::Hetzner::CLI::Cmd::Firewall::Cmd::AddRule;
# ABSTRACT: Add a rule to a firewall

our $VERSION = '0.004';

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hcloud.pl firewall add-rule <id> --direction <in|out> --protocol <tcp|udp|icmp|gre|esp> --port <port> [--source-ips <ips>]';

option direction => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Direction: in or out',
);

option protocol => (
    is       => 'ro',
    format   => 's',
    required => 1,
    doc      => 'Protocol: tcp, udp, icmp, gre, esp',
);

option port => (
    is     => 'ro',
    format => 's',
    doc    => 'Port or port range (e.g. 22 or 80-443)',
);

option 'source_ips' => (
    is        => 'ro',
    format    => 's@',
    long_doc  => 'source-ips',
    doc       => 'Source IPs (can specify multiple)',
    default   => sub { ['0.0.0.0/0', '::/0'] },
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $id = $args->[0] or die "Usage: hcloud.pl firewall add-rule <id> --direction <in|out> --protocol <tcp|udp|icmp> --port <port>\n";

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    # Get existing firewall
    my $fw = $cloud->firewalls->get($id);
    my @rules = @{ $fw->rules // [] };

    # Build new rule
    my $rule = {
        direction => $self->direction,
        protocol  => $self->protocol,
    };
    $rule->{port} = $self->port if $self->port;

    if ($self->direction eq 'in') {
        $rule->{source_ips} = $self->source_ips;
    } else {
        $rule->{destination_ips} = $self->source_ips;  # reuse for simplicity
    }

    push @rules, $rule;

    print "Adding rule to firewall $id...\n";
    $cloud->firewalls->set_rules($id, @rules);
    print "Rule added.\n";
}

1;
