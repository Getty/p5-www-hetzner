package WWW::Hetzner::Robot::IP;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Robot IP entity

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has ip                => ( is => 'ro', required => 1 );
has server_number     => ( is => 'ro' );
has server_ip         => ( is => 'ro' );
has locked            => ( is => 'ro' );
has separate_mac      => ( is => 'ro' );
has traffic_warnings  => ( is => 'rw' );
has traffic_hourly    => ( is => 'rw' );
has traffic_daily     => ( is => 'rw' );
has traffic_monthly   => ( is => 'rw' );

sub update {
    my ($self) = @_;
    my $body = {};
    $body->{traffic_warnings} = $self->traffic_warnings if defined $self->traffic_warnings;
    $body->{traffic_hourly}   = $self->traffic_hourly   if defined $self->traffic_hourly;
    $body->{traffic_daily}    = $self->traffic_daily    if defined $self->traffic_daily;
    $body->{traffic_monthly}  = $self->traffic_monthly  if defined $self->traffic_monthly;
    return $self->client->post("/ip/" . $self->ip, $body);
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::IP - Hetzner Robot IP entity

=head1 ATTRIBUTES

=over 4

=item * ip - IP address

=item * server_number - Associated server

=item * server_ip - Main server IP

=item * locked - Lock status

=item * separate_mac - Separate MAC address

=item * traffic_warnings - Traffic warning enabled

=item * traffic_hourly/daily/monthly - Traffic limits

=back

=cut
