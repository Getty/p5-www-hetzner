package WWW::Hetzner::Robot::RDNS;
# ABSTRACT: Hetzner Robot reverse DNS entry entity

our $VERSION = '0.101';

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has ip  => ( is => 'ro', required => 1 );

=attr ip

IP address the entry belongs to (unique ID).

=cut

has ptr => ( is => 'rw' );

=attr ptr

PTR record, the hostname the IP resolves back to.

=cut

sub update {
    my ($self) = @_;
    my $result = $self->client->post("/rdns/" . $self->ip, { ptr => $self->ptr });
    return $result->{rdns};
}

=method update

    $rdns->ptr('mail.example.com');
    $rdns->update;

Writes the current C<ptr> back to the API.

=cut

sub delete {
    my ($self) = @_;
    return $self->client->delete("/rdns/" . $self->ip);
}

=method delete

    $rdns->delete;

Removes the reverse DNS entry for this IP.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Robot::API::RDNS> - Reverse DNS API

=item * L<WWW::Hetzner::Robot> - Main Robot API client

=item * L<WWW::Hetzner::Robot::IP> - IP entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
