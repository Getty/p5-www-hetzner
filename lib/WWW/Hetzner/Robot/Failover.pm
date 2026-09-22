package WWW::Hetzner::Robot::Failover;
# ABSTRACT: Hetzner Robot failover IP entity

our $VERSION = '0.102';

use Moo;
use Carp qw(croak);
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has ip               => ( is => 'ro', required => 1 );

=attr ip

The failover IP address (unique ID).

=cut

has netmask          => ( is => 'ro' );

=attr netmask

Netmask of the failover IP.

=cut

has server_ip        => ( is => 'ro' );

=attr server_ip

Main IP of the server the failover IP is assigned to.

=cut

has server_ipv6_net  => ( is => 'ro' );

=attr server_ipv6_net

IPv6 network of the server the failover IP is assigned to.

=cut

has server_number    => ( is => 'ro' );

=attr server_number

Number of the server the failover IP is assigned to.

=cut

has active_server_ip => ( is => 'rw' );

=attr active_server_ip

Main IP of the server the failover IP currently routes to. C<undef> when the
routing was deleted.

=cut

sub switch {
    my ($self, $active_server_ip) = @_;
    croak "Target server IP required" unless $active_server_ip;
    my $result = $self->client->post("/failover/" . $self->ip, {
        active_server_ip => $active_server_ip,
    });
    $self->active_server_ip($result->{failover}{active_server_ip});
    return $result->{failover};
}

=method switch

    $failover->switch('198.51.100.10');

Routes the failover IP to another server and updates L</active_server_ip>
from the response.

=cut

sub delete {
    my ($self) = @_;
    my $result = $self->client->delete("/failover/" . $self->ip);
    return $result->{failover};
}

=method delete

    $failover->delete;

Deletes the routing of the failover IP. The IP itself stays in the account -
this is not a cancellation.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot::API::Failover> - Failover API

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner::Robot::IP> - IP entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
