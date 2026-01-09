package WWW::Hetzner::Robot::CLI::Cmd::Wol;

# ABSTRACT: Send Wake-on-LAN to a server

use Moo;
use MooX::Cmd;

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $server_number = $args->[0] or die "Usage: hrobot wol <server-number>\n";

    my $result = $robot->reset->wol($server_number);

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json($result);
        print "\n";
    } else {
        print "Wake-on-LAN sent to server $server_number\n";
    }
}

1;
