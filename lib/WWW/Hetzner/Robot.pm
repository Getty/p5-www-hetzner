package WWW::Hetzner::Robot;

# ABSTRACT: Perl client for Hetzner Robot API (Dedicated Servers)

use Moo;
use WWW::Hetzner::Robot::API::Servers;
use WWW::Hetzner::Robot::API::Keys;
use WWW::Hetzner::Robot::API::IPs;
use WWW::Hetzner::Robot::API::Reset;
use WWW::Hetzner::Robot::API::Traffic;
use namespace::clean;

our $VERSION = '0.002';

has user => (
    is      => 'ro',
    default => sub { $ENV{HETZNER_ROBOT_USER} },
);

has password => (
    is      => 'ro',
    default => sub { $ENV{HETZNER_ROBOT_PASSWORD} },
);

# For Role::HTTP compatibility
sub token {
    my $self = shift;
    return $self->user && $self->password;
}

sub _check_auth {
    my ($self) = @_;
    unless ($self->user && $self->password) {
        die "No Robot credentials configured.\n\n" .
            "Set credentials via:\n" .
            "  Environment: HETZNER_ROBOT_USER and HETZNER_ROBOT_PASSWORD\n" .
            "  Options:     --user and --password\n\n" .
            "Get credentials at: https://robot.hetzner.com/preferences/index\n";
    }
}

has base_url => (
    is      => 'ro',
    default => 'https://robot-ws.your-server.de',
);

with 'WWW::Hetzner::Role::HTTP';

around _request => sub {
    my ($orig, $self, @args) = @_;
    $self->_check_auth;
    return $self->$orig(@args);
};

# Override auth for Basic Auth
sub _set_auth {
    my ($self, $request) = @_;
    $request->authorization_basic($self->user, $self->password);
}

# Resource accessors
has servers => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Robot::API::Servers->new(client => shift) },
);

has keys => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Robot::API::Keys->new(client => shift) },
);

has ips => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Robot::API::IPs->new(client => shift) },
);

has reset => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Robot::API::Reset->new(client => shift) },
);

has traffic => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Robot::API::Traffic->new(client => shift) },
);

1;

__END__

=head1 NAME

WWW::Hetzner::Robot - Perl client for Hetzner Robot API (Dedicated Servers)

=head1 SYNOPSIS

    use WWW::Hetzner::Robot;

    my $robot = WWW::Hetzner::Robot->new(
        user     => $ENV{HETZNER_ROBOT_USER},
        password => $ENV{HETZNER_ROBOT_PASSWORD},
    );

    # List servers
    my $servers = $robot->servers->list;

    # Get server details
    my $server = $robot->servers->get(123456);
    print $server->name, "\n";
    print $server->product, "\n";

    # Reset server
    $robot->reset->execute(123456, 'sw');  # software reset
    $robot->reset->execute(123456, 'hw');  # hardware reset

    # Manage SSH keys
    my $keys = $robot->keys->list;
    $robot->keys->create(
        name => 'my-key',
        data => 'ssh-ed25519 AAAA...',
    );

=head1 DESCRIPTION

This module provides access to the Hetzner Robot API for managing dedicated
servers, IPs, SSH keys, and server resets.

Uses HTTP Basic Auth (user/password) instead of Bearer tokens.

=head1 RESOURCES

=over 4

=item * servers - Dedicated server management

=item * keys - SSH key management

=item * ips - IP address management

=item * reset - Server reset (software/hardware)

=item * traffic - Traffic statistics

=back

=head1 ENVIRONMENT

=over 4

=item * C<HETZNER_ROBOT_USER> - Robot webservice username

=item * C<HETZNER_ROBOT_PASSWORD> - Robot webservice password

=back

=head1 SEE ALSO

L<WWW::Hetzner>, L<https://robot.hetzner.com/doc/webservice/en.html>

=cut
