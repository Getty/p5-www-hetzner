package WWW::Hetzner::Robot::API::RDNS;
# ABSTRACT: Hetzner Robot Reverse DNS API

our $VERSION = '0.102';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Robot::RDNS;
use namespace::clean;

=head1 SYNOPSIS

    my $robot = WWW::Hetzner::Robot->new(...);

    # List all reverse DNS entries
    my $entries = $robot->rdns->list;

    # Get the entry of one IP
    my $entry = $robot->rdns->get('203.0.113.50');
    print $entry->ptr, "\n";

    # Create or update
    $robot->rdns->create('203.0.113.50', 'mail.example.com');
    $robot->rdns->update('203.0.113.50', 'www.example.com');

    # Delete
    $robot->rdns->delete('203.0.113.50');

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Robot::RDNS->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_->{rdns}) } @$list ];
}

sub list {
    my ($self) = @_;
    my $result = $self->client->get('/rdns');
    return $self->_wrap_list($result // []);
}

=method list

Returns arrayref of L<WWW::Hetzner::Robot::RDNS> objects.

=cut

sub get {
    my ($self, $ip) = @_;
    croak "IP address required" unless $ip;
    my $result = $self->client->get("/rdns/$ip");
    return $self->_wrap($result->{rdns});
}

=method get

    my $entry = $robot->rdns->get($ip_address);

Returns L<WWW::Hetzner::Robot::RDNS> object.

=cut

sub create {
    my ($self, $ip, $ptr) = @_;
    croak "IP address required" unless $ip;
    croak "ptr required" unless defined $ptr;
    my $result = $self->client->put("/rdns/$ip", { ptr => $ptr });
    return $self->_wrap($result->{rdns});
}

=method create

    my $entry = $robot->rdns->create($ip_address, 'mail.example.com');

Creates a new reverse DNS entry. Fails if the IP already has one - use
L</update> to overwrite.

=cut

sub update {
    my ($self, $ip, $ptr) = @_;
    croak "IP address required" unless $ip;
    croak "ptr required" unless defined $ptr;
    my $result = $self->client->post("/rdns/$ip", { ptr => $ptr });
    return $self->_wrap($result->{rdns});
}

=method update

    my $entry = $robot->rdns->update($ip_address, 'www.example.com');

Updates the reverse DNS entry, creating it when there is none.

=cut

sub delete {
    my ($self, $ip) = @_;
    croak "IP address required" unless $ip;
    return $self->client->delete("/rdns/$ip");
}

=method delete

    $robot->rdns->delete($ip_address);

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner::Robot::RDNS> - Reverse DNS entry entity class

=item * L<WWW::Hetzner::Robot::CLI::Cmd::Rdns> - Reverse DNS CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
