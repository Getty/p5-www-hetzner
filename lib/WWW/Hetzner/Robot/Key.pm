package WWW::Hetzner::Robot::Key;
# ABSTRACT: Hetzner Robot SSH Key entity

our $VERSION = '0.002';

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has name        => ( is => 'rw', required => 1 );

=attr name

Key name.

=cut

has fingerprint => ( is => 'ro', required => 1 );

=attr fingerprint

Key fingerprint (unique ID).

=cut

has type        => ( is => 'ro' );

=attr type

Key type (e.g. ED25519, RSA).

=cut

has size        => ( is => 'ro' );

=attr size

Key size in bits.

=cut

has data        => ( is => 'ro' );

=attr data

Public key data.

=cut

sub delete {
    my ($self) = @_;
    return $self->client->delete("/key/" . $self->fingerprint);
}

=method delete

    $key->delete;

=cut

sub update {
    my ($self) = @_;
    return $self->client->post("/key/" . $self->fingerprint, {
        name => $self->name,
    });
}

=method update

    $key->name('new-name');
    $key->update;

=cut

1;
