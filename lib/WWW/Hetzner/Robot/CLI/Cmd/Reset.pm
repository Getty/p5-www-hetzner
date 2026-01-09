package WWW::Hetzner::Robot::CLI::Cmd::Reset;

# ABSTRACT: Reset a dedicated server

use Moo;
use MooX::Cmd;
use MooX::Options protect_argv => 0, usage_string => 'USAGE: hrobot.pl reset <server-number> [--type sw|hw|man]';

=head1 NAME

hrobot.pl reset - Reset a dedicated server

=head1 SYNOPSIS

    hrobot.pl reset <server-number>
    hrobot.pl reset 123456
    hrobot.pl reset 123456 --type hw
    hrobot.pl reset 123456 -t man

=head1 DESCRIPTION

Triggers a reset of a dedicated server. Supports different reset types:

=over 4

=item B<sw> - Software reset (default, graceful)

=item B<hw> - Hardware reset (immediate power cycle)

=item B<man> - Manual reset (request technician intervention)

=back

=cut

option type => (
    is      => 'ro',
    format  => 's',
    short   => 't',
    doc     => 'Reset type: sw (software), hw (hardware), man (manual)',
    default => 'sw',
);

sub execute {
    my ($self, $args, $chain) = @_;
    my $root = $chain->[0];
    my $robot = $root->robot;

    my $server_number = $args->[0] or die "Usage: hrobot.pl reset <server-number> [--type sw|hw|man]\n";

    my $result = $robot->reset->execute($server_number, $self->type);

    if ($root->output eq 'json') {
        require JSON::MaybeXS;
        print JSON::MaybeXS::encode_json($result);
        print "\n";
    } else {
        print "Reset initiated for server $server_number (type: ", $self->type, ")\n";
    }
}

1;
