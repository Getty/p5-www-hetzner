package WWW::Hetzner::CLI::Cmd::Iso;
# ABSTRACT: ISO commands

our $VERSION = '0.103';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl iso [--architecture x86|arm] [--name NAME] [options]';
use JSON::MaybeXS qw(encode_json);

=head1 SYNOPSIS

    hcloud.pl iso                            # List ISOs
    hcloud.pl iso --architecture arm         # Only ARM ISOs
    hcloud.pl iso --name netboot.xyz.iso     # Look up one ISO by name

=cut

option architecture => (
    is     => 'ro',
    format => 's',
    doc    => 'Filter by architecture (x86, arm)',
);

=opt --architecture

Only list ISOs for that CPU architecture: C<x86> or C<arm>.

=cut

option name => (
    is     => 'ro',
    format => 's',
    doc    => 'Filter by exact ISO name',
);

=opt --name

Only list the ISO with that exact name.

=cut

sub execute {
    my ($self, $args, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my %params;
    $params{architecture} = $self->architecture if $self->architecture;
    $params{name}         = $self->name         if $self->name;

    my $isos = $cloud->isos->list_all(%params);

    if ($main->output eq 'json') {
        print encode_json([ map { $_->data } @$isos ]), "\n";
        return;
    }

    if (!@$isos) {
        print "No ISOs found.\n";
        return;
    }

    printf "%-8s %-40s %-8s %-6s %s\n", 'ID', 'NAME', 'TYPE', 'ARCH', 'DEPRECATED';
    printf "%-8s %-40s %-8s %-6s %s\n", '-' x 8, '-' x 40, '-' x 8, '-' x 6, '-' x 10;

    for my $iso (@$isos) {
        printf "%-8s %-40s %-8s %-6s %s\n",
            $iso->id,
            $iso->name // '-',
            $iso->type // '-',
            $iso->architecture // '-',
            ($iso->deprecation ? $iso->deprecation->{unavailable_after}
                               : $iso->deprecated) // '-';
    }
}

1;
