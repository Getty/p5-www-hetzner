package WWW::Hetzner::CLI::Cmd::Zone;
# ABSTRACT: DNS Zone commands

our $VERSION = '0.102';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl zone [list|describe|create|delete] [options]';
use JSON::MaybeXS qw(encode_json);

=head1 SYNOPSIS

    hcloud.pl zone                      # List all zones
    hcloud.pl zone list                 # List all zones
    hcloud.pl zone describe <id>        # Show zone details
    hcloud.pl zone create --name example.com
    hcloud.pl zone delete <id>

=cut

=head1 SUBCOMMANDS

=over 4

=item * L<list|WWW::Hetzner::CLI::Cmd::Zone::Cmd::List> - List DNS zones

=item * L<describe|WWW::Hetzner::CLI::Cmd::Zone::Cmd::Describe> - Describe a DNS zone

=item * L<create|WWW::Hetzner::CLI::Cmd::Zone::Cmd::Create> - Create a DNS zone

=item * L<delete|WWW::Hetzner::CLI::Cmd::Zone::Cmd::Delete> - Delete a DNS zone

=back

=cut

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
    doc    => 'Filter by zone name',
);

sub _list {
    my ($self, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{label_selector} = $self->selector if $self->selector;
    $params{name} = $self->name if $self->name;

    my $zones = $cloud->zones->list_all(%params);

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$zones ]), "\n";
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
        my $labels_data = $z->labels;
        my $labels = join(', ', map { "$_=$labels_data->{$_}" } keys %{$labels_data // {}});
        printf "%-15s %-30s %-10s %-8s %s\n",
            $z->id,
            $z->name,
            $z->status // '-',
            $z->ttl // '-',
            $labels || '-';
    }
}

1;
