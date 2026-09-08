package WWW::Hetzner::Cloud::API::LoadBalancerTypes;
# ABSTRACT: Hetzner Cloud Load Balancer Types API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::LoadBalancerType;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all load balancer types
    my $types = $cloud->load_balancer_types->list;

    # Get by ID
    my $type = $cloud->load_balancer_types->get(1);

    # Get by name
    my $lb11 = $cloud->load_balancer_types->get_by_name('lb11');
    printf "LB11: %d services, %d targets\n", $lb11->max_services, $lb11->max_targets;

=head1 DESCRIPTION

This module provides access to Hetzner Cloud load balancer types. Load balancer
types define the connection, service and target limits of a load balancer.
All methods return L<WWW::Hetzner::Cloud::LoadBalancerType> objects.

Load balancer types are read-only resources.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::LoadBalancerType->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $types = $cloud->load_balancer_types->list;

Returns an arrayref of L<WWW::Hetzner::Cloud::LoadBalancerType> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/load_balancer_types', params => \%params);
    return $self->_wrap_list($result->{load_balancer_types} // []);
}

=method get

    my $type = $cloud->load_balancer_types->get($id);

Returns a L<WWW::Hetzner::Cloud::LoadBalancerType> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Load Balancer Type ID required" unless $id;

    my $result = $self->client->get("/load_balancer_types/$id");
    return $self->_wrap($result->{load_balancer_type});
}

=method get_by_name

    my $type = $cloud->load_balancer_types->get_by_name('lb11');

Returns a L<WWW::Hetzner::Cloud::LoadBalancerType> object. Returns undef if
not found.

=cut

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $types = $self->list;
    for my $type (@$types) {
        return $type if $type->name eq $name;
    }
    return;
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::LoadBalancerType> - LoadBalancerType entity class

=item * L<WWW::Hetzner::CLI::Cmd::LoadBalancerType> - LoadBalancerType CLI commands

=item * L<WWW::Hetzner::Cloud::API::LoadBalancers> - Load Balancers API

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
