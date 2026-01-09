package WWW::Hetzner::Robot::Key;

# ABSTRACT: Hetzner Robot SSH Key entity

use Moo;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has name        => ( is => 'rw', required => 1 );
has fingerprint => ( is => 'ro', required => 1 );
has type        => ( is => 'ro' );
has size        => ( is => 'ro' );
has data        => ( is => 'ro' );

sub delete {
    my ($self) = @_;
    return $self->client->delete("/key/" . $self->fingerprint);
}

sub update {
    my ($self) = @_;
    return $self->client->post("/key/" . $self->fingerprint, {
        name => $self->name,
    });
}

1;

__END__

=head1 NAME

WWW::Hetzner::Robot::Key - Hetzner Robot SSH Key entity

=head1 ATTRIBUTES

=over 4

=item * name - Key name

=item * fingerprint - Key fingerprint (unique ID)

=item * type - Key type (e.g. ED25519, RSA)

=item * size - Key size in bits

=item * data - Public key data

=back

=head1 METHODS

=head2 delete

    $key->delete;

=head2 update

    $key->name('new-name');
    $key->update;

=cut
