package WWW::Hetzner::Cloud::SSHKey;
# ABSTRACT: Hetzner Cloud SSHKey object

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $key = $cloud->ssh_keys->get($id);

    # Read attributes
    print $key->id, "\n";
    print $key->name, "\n";
    print $key->fingerprint, "\n";
    print $key->public_key, "\n";

    # Update
    $key->name('renamed-key');
    $key->labels({ env => 'prod' });
    $key->update;

    # Delete
    $key->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud SSH key. Objects are returned by
L<WWW::Hetzner::Cloud::API::SSHKeys> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

SSH key ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

SSH key name (read-write).

=cut

has public_key => ( is => 'ro' );

=attr public_key

The public key content (read-only).

=cut

has fingerprint => ( is => 'ro' );

=attr fingerprint

SSH key fingerprint (read-only).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

sub update {
    my ($self) = @_;
    croak "Cannot update SSH key without ID" unless $self->id;

    $self->_client->put("/ssh_keys/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $key->name('new-name');
    $key->update;

Saves changes to name and labels back to the API.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete SSH key without ID" unless $self->id;

    $self->_client->delete("/ssh_keys/" . $self->id);
    return 1;
}

=method delete

    $key->delete;

Deletes the SSH key.

=cut

sub data {
    my ($self) = @_;
    return {
        id          => $self->id,
        name        => $self->name,
        public_key  => $self->public_key,
        fingerprint => $self->fingerprint,
        created     => $self->created,
        labels      => $self->labels,
    };
}

=method data

    my $hashref = $key->data;

Returns all SSH key data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::SSHKeys> - SSH Keys API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Server> - Server entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
