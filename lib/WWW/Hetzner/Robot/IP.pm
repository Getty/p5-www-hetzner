package WWW::Hetzner::Robot::IP;
# ABSTRACT: Hetzner Robot IP entity

our $VERSION = '0.004';

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has ip                => ( is => 'ro', required => 1 );

=attr ip

IP address.

=cut

has server_number     => ( is => 'ro' );

=attr server_number

Associated server.

=cut

has server_ip         => ( is => 'ro' );

=attr server_ip

Main server IP.

=cut

has locked            => ( is => 'ro' );

=attr locked

Lock status.

=cut

has separate_mac      => ( is => 'ro' );

=attr separate_mac

Separate MAC address.

=cut

has traffic_warnings  => ( is => 'rw' );

=attr traffic_warnings

Traffic warning enabled.

=cut

has traffic_hourly    => ( is => 'rw' );

=attr traffic_hourly

Hourly traffic limit.

=cut

has traffic_daily     => ( is => 'rw' );

=attr traffic_daily

Daily traffic limit.

=cut

has traffic_monthly   => ( is => 'rw' );

=attr traffic_monthly

Monthly traffic limit.

=cut

sub update {
    my ($self) = @_;
    my $body = {};
    $body->{traffic_warnings} = $self->traffic_warnings if defined $self->traffic_warnings;
    $body->{traffic_hourly}   = $self->traffic_hourly   if defined $self->traffic_hourly;
    $body->{traffic_daily}    = $self->traffic_daily    if defined $self->traffic_daily;
    $body->{traffic_monthly}  = $self->traffic_monthly  if defined $self->traffic_monthly;
    return $self->client->post("/ip/" . $self->ip, $body);
}

=method update

Updates the IP configuration via the API with current attribute values for
traffic_warnings, traffic_hourly, traffic_daily, and traffic_monthly.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot::API::IPs> - IPs API

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner::Robot::Server> - Server entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
