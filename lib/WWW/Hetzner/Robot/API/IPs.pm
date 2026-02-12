package WWW::Hetzner::Robot::API::IPs;
# ABSTRACT: Hetzner Robot IPs API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Robot::IP;
use namespace::clean;

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # List all IPs
    my $ips = $robot->ips->list;

    # Get specific IP
    my $ip = $robot->ips->get('1.2.3.4');

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Robot::IP->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_->{ip}) } @$list ];
}

sub list {
    my ($self) = @_;
    my $result = $self->client->get('/ip');
    return $self->_wrap_list($result // []);
}

=method list

Returns arrayref of L<WWW::Hetzner::Robot::IP> objects.

=cut

sub get {
    my ($self, $ip) = @_;
    croak "IP address required" unless $ip;
    my $result = $self->client->get("/ip/$ip");
    return $self->_wrap($result->{ip});
}

=method get

    my $ip = $robot->ips->get($ip_address);

Returns L<WWW::Hetzner::Robot::IP> object.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner::Robot::IP> - IP entity class

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
