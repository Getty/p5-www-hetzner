package WWW::Hetzner::CLI::Cmd::Volume;
# ABSTRACT: Volume commands

our $VERSION = '0.003';

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hcloud.pl volume <command> [options]';
use JSON::MaybeXS qw(encode_json);

sub execute {
    my ($self, $args, $chain) = @_;

    # Default to list
    $self->_list($chain);
}

sub _list {
    my ($self, $chain) = @_;

    my $main = $chain->[0];
    my $cloud = $main->cloud;

    my $volumes = $cloud->volumes->list;

    if ($main->output eq 'json') {
        print encode_json([map { $_->data } @$volumes]), "\n";
        return;
    }

    if (!@$volumes) {
        print "No volumes found.\n";
        return;
    }

    printf "%-10s %-25s %-8s %-10s %-10s %s\n",
        'ID', 'NAME', 'SIZE', 'SERVER', 'LOCATION', 'STATUS';
    print "-" x 80, "\n";

    for my $v (@$volumes) {
        printf "%-10s %-25s %-8s %-10s %-10s %s\n",
            $v->id,
            $v->name,
            $v->size . ' GB',
            $v->server // '-',
            $v->location // '-',
            $v->status;
    }
}

1;
