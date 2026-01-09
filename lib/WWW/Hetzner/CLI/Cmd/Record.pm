package WWW::Hetzner::CLI::Cmd::Record;

# ABSTRACT: DNS Record commands

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl record [list|describe|create|delete] --zone <zone-id> [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    # Default to list
    $self->_list($chain);
}

option zone => (
    is     => 'ro',
    format => 's',
    short  => 'z',
    doc    => 'Zone ID (required)',
);

option type => (
    is     => 'ro',
    format => 's',
    short  => 't',
    doc    => 'Filter by record type (A, AAAA, CNAME, MX, TXT, etc.)',
);

sub _list {
    my ($self, $chain) = @_;

    die "Usage: record --zone <zone-id>\n" unless $self->zone;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{type} = $self->type if $self->type;

    my $rrsets = $cloud->zones->rrsets($self->zone);
    my $records = $rrsets->list(%params);

    if ($main->output eq 'json') {
        print encode_json($records), "\n";
        return;
    }

    if (!@$records) {
        print "No records found.\n";
        return;
    }

    printf "%-25s %-8s %-8s %s\n",
        'NAME', 'TYPE', 'TTL', 'VALUES';
    print "-" x 80, "\n";

    for my $r (@$records) {
        my $values = join(', ', map { $_->{value} } @{$r->{records} // []});
        printf "%-25s %-8s %-8s %s\n",
            $r->{name},
            $r->{type},
            $r->{ttl} // '-',
            $values;
    }
}

1;

__END__

=head1 NAME

WWW::Hetzner::CLI::Cmd::Record - DNS Record commands

=head1 SYNOPSIS

    hcloud.pl record --zone <zone-id>                    # List all records
    hcloud.pl record list --zone <zone-id>               # List all records
    hcloud.pl record list --zone <zone-id> --type A      # List A records only
    hcloud.pl record create --zone <zone-id> --name www --type A --value 1.2.3.4
    hcloud.pl record delete --zone <zone-id> --name www --type A

=cut
