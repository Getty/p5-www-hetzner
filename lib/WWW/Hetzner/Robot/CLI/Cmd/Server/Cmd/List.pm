package WWW::Hetzner::Robot::CLI::Cmd::Server::Cmd::List;
our $VERSION = '0.002';
# ABSTRACT: List dedicated servers

use Moo;
use MooX::Cmd;
use MooX::Options usage_string => 'USAGE: hrobot.pl server list [options]';

=head1 NAME

hrobot.pl server list - List all dedicated servers

=head1 SYNOPSIS

    hrobot.pl server list
    hrobot.pl server list -o json

=head1 DESCRIPTION

Lists all dedicated servers in your Hetzner Robot account.
Shows server number, name, IP, product, and datacenter for each server.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $servers = $robot->servers->list;

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json([map { +{
            server_number => $_->server_number,
            server_name   => $_->server_name,
            server_ip     => $_->server_ip,
            product       => $_->product,
            dc            => $_->dc,
            status        => $_->status,
        } } @$servers]);
        print "\n";
    } else {
        printf "%-12s %-20s %-15s %-20s %s\n",
            'NUMBER', 'NAME', 'IP', 'PRODUCT', 'DC';
        for my $s (@$servers) {
            printf "%-12s %-20s %-15s %-20s %s\n",
                $s->server_number // '',
                $s->server_name // '',
                $s->server_ip // '',
                $s->product // '',
                $s->dc // '';
        }
    }
}

1;
