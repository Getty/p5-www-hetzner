package WWW::Hetzner::Robot::CLI::Cmd::Server;

# ABSTRACT: Robot server commands

use Moo;
use MooX::Cmd;

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    # Default: list servers
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
