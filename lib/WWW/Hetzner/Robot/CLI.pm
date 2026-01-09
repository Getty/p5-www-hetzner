package WWW::Hetzner::Robot::CLI;

# ABSTRACT: Hetzner Robot CLI

use Moo;
use MooX::Cmd;
use MooX::Options;
use WWW::Hetzner::Robot;

our $VERSION = '0.001';

option user => (
    is     => 'ro',
    format => 's',
    short  => 'u',
    doc    => 'Robot user (default: HETZNER_ROBOT_USER env)',
    default => sub { $ENV{HETZNER_ROBOT_USER} },
);

option password => (
    is     => 'ro',
    format => 's',
    short  => 'p',
    doc    => 'Robot password (default: HETZNER_ROBOT_PASSWORD env)',
    default => sub { $ENV{HETZNER_ROBOT_PASSWORD} },
);

option output => (
    is      => 'ro',
    format  => 's',
    short   => 'o',
    doc     => 'Output format: table, json (default: table)',
    default => 'table',
);

has robot => (
    is      => 'lazy',
    builder => sub {
        my ($self) = @_;
        WWW::Hetzner::Robot->new(
            user     => $self->user,
            password => $self->password,
        );
    },
);

sub execute {
    my ($self, $args, $chain) = @_;

    print "Usage: hrobot <command> [options]\n\n";
    print "Commands:\n";
    print "  server    Manage dedicated servers\n";
    print "  key       Manage SSH keys\n";
    print "  reset     Reset a server\n";
    print "  wol       Wake-on-LAN\n";
    print "\nRun 'hrobot <command> --help' for more information.\n";
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::CLI - Command-line interface for Hetzner Robot

=head1 SYNOPSIS

    use WWW::Hetzner::Robot::CLI;
    WWW::Hetzner::Robot::CLI->new_with_cmd;

=head1 DESCRIPTION

CLI for the Hetzner Robot API (dedicated servers).

This is a Perl implementation to manage dedicated servers via the Robot API.

=head1 ATTRIBUTES

=head2 user

Robot webservice username. Use C<--user> or C<-u> flag, or set via
C<HETZNER_ROBOT_USER> environment variable.

=head2 password

Robot webservice password. Use C<--password> or C<-p> flag, or set via
C<HETZNER_ROBOT_PASSWORD> environment variable.

=head2 output

Output format: C<table> (default) or C<json>. Use C<--output> or C<-o> flag.

=head2 robot

L<WWW::Hetzner::Robot> instance.

=head1 COMMANDS

=over 4

=item * server - Manage dedicated servers (list, describe)

=item * key - Manage SSH keys (list)

=item * reset - Reset a server (software, hardware, manual)

=item * wol - Send Wake-on-LAN packet

=back

=head1 SEE ALSO

L<WWW::Hetzner::Robot>

=cut
