package WWW::Hetzner::Robot::CLI::Cmd::Server::Cmd::Describe;
our $VERSION = '0.002';
# ABSTRACT: Describe a dedicated server

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hrobot.pl server describe <server-number> [options]';

=head1 NAME

hrobot.pl server describe - Show details of a dedicated server

=head1 SYNOPSIS

    hrobot.pl server describe <server-number>
    hrobot.pl server describe 123456
    hrobot.pl server describe 123456 -o json

=head1 DESCRIPTION

Shows detailed information about a dedicated server including:
server number, name, IP, product, datacenter, status, traffic,
cancellation status, and paid-until date.

=cut

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $server_number = $args->[0] or die "Usage: hrobot.pl server describe <server-number>\n";

    my $s = $robot->servers->get($server_number);

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json({
            server_number => $s->server_number,
            server_name   => $s->server_name,
            server_ip     => $s->server_ip,
            product       => $s->product,
            dc            => $s->dc,
            status        => $s->status,
            traffic       => $s->traffic,
            cancelled     => $s->cancelled,
            paid_until    => $s->paid_until,
        });
        print "\n";
    } else {
        print "Server Number: ", $s->server_number // '', "\n";
        print "Name:          ", $s->server_name // '', "\n";
        print "IP:            ", $s->server_ip // '', "\n";
        print "Product:       ", $s->product // '', "\n";
        print "Datacenter:    ", $s->dc // '', "\n";
        print "Status:        ", $s->status // '', "\n";
        print "Traffic:       ", $s->traffic // '', "\n";
        print "Cancelled:     ", $s->cancelled ? 'yes' : 'no', "\n";
        print "Paid Until:    ", $s->paid_until // '', "\n";
    }
}

1;
