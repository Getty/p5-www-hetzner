package WWW::Hetzner::Cloud::LoadBalancerType;
# ABSTRACT: Hetzner Cloud LoadBalancerType object

our $VERSION = '0.102';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $type = $cloud->load_balancer_types->get_by_name('lb11');

    print $type->name, "\n";            # lb11
    print $type->max_connections, "\n"; # 20000
    print $type->max_services, "\n";    # 5
    print $type->max_targets, "\n";     # 25

=head1 DESCRIPTION

This class represents a Hetzner Cloud load balancer type (connection, service
and target limits). Objects are returned by
L<WWW::Hetzner::Cloud::API::LoadBalancerTypes> methods.

Load balancer types are read-only resources.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Load balancer type ID.

=cut

has name => ( is => 'ro' );

=attr name

Load balancer type name, e.g. "lb11", "lb21", "lb31".

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has max_connections => ( is => 'ro' );

=attr max_connections

Maximum number of simultaneous open connections.

=cut

has max_services => ( is => 'ro' );

=attr max_services

Maximum number of services.

=cut

has max_targets => ( is => 'ro' );

=attr max_targets

Maximum number of targets.

=cut

has max_assigned_certificates => ( is => 'ro' );

=attr max_assigned_certificates

Maximum number of certificates that can be assigned.

=cut

has prices => ( is => 'ro', default => sub { [] } );

=attr prices

Arrayref of per-location prices, each a hashref with C<location>,
C<price_hourly>, C<price_monthly>, C<included_traffic> and
C<price_per_tb_traffic>.

=cut

has deprecated => ( is => 'ro' );

=attr deprecated

Deprecation timestamp if deprecated, undef otherwise.

=cut

has deprecation => ( is => 'ro' );

=attr deprecation

Deprecation hashref with C<announced> and C<unavailable_after> timestamps,
undef unless the type is deprecated.

=cut

sub data {
    my ($self) = @_;
    return {
        id                        => $self->id,
        name                      => $self->name,
        description               => $self->description,
        max_connections           => $self->max_connections,
        max_services              => $self->max_services,
        max_targets               => $self->max_targets,
        max_assigned_certificates => $self->max_assigned_certificates,
        prices                    => $self->prices,
        deprecated                => $self->deprecated,
        deprecation               => $self->deprecation,
    };
}

=method data

    my $hashref = $type->data;

Returns all load balancer type data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::LoadBalancerTypes> - Load Balancer Types API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::LoadBalancer> - LoadBalancer entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
