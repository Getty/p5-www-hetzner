package WWW::Hetzner::Cloud::Certificate;
# ABSTRACT: Hetzner Cloud Certificate object

our $VERSION = '0.004';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $cert = $cloud->certificates->get($id);

    print $cert->name, "\n";
    print $cert->type, "\n";  # uploaded or managed
    print join(", ", @{$cert->domain_names}), "\n";

    # Update
    $cert->name('new-name');
    $cert->update;

    # Delete
    $cert->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud certificate. Objects are returned by
L<WWW::Hetzner::Cloud::API::Certificates> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Certificate ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Certificate name (read-write).

=cut

has certificate => ( is => 'ro' );

=attr certificate

Certificate PEM content (read-only).

=cut

has domain_names => ( is => 'ro', default => sub { [] } );

=attr domain_names

Arrayref of domain names covered by this certificate (read-only).

=cut

has fingerprint => ( is => 'ro' );

=attr fingerprint

Certificate fingerprint (read-only).

=cut

has status => ( is => 'ro', default => sub { {} } );

=attr status

Certificate status hash (read-only).

=cut

has type => ( is => 'ro' );

=attr type

Certificate type: uploaded or managed (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has not_valid_before => ( is => 'ro' );

=attr not_valid_before

Certificate validity start timestamp (read-only).

=cut

has not_valid_after => ( is => 'ro' );

=attr not_valid_after

Certificate validity end timestamp (read-only).

=cut

# Convenience
sub is_managed { shift->type eq 'managed' }

=method is_managed

Returns true if this is a managed certificate.

=cut

sub is_valid { (shift->status->{issuance} // '') eq 'completed' }

=method is_valid

Returns true if certificate issuance is completed.

=cut

# Actions
sub update {
    my ($self) = @_;
    croak "Cannot update certificate without ID" unless $self->id;

    $self->_client->put("/certificates/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $cert->name('new-name');
    $cert->update;

Saves changes to name and labels.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete certificate without ID" unless $self->id;

    $self->_client->delete("/certificates/" . $self->id);
    return 1;
}

=method delete

    $cert->delete;

Deletes the certificate.

=cut

sub retry {
    my ($self) = @_;
    croak "Cannot retry certificate without ID" unless $self->id;
    croak "Only managed certificates can be retried" unless $self->is_managed;

    $self->_client->post("/certificates/" . $self->id . "/actions/retry", {});
    return $self;
}

=method retry

    $cert->retry;

Retries issuance for a managed certificate.

=cut

sub data {
    my ($self) = @_;
    return {
        id               => $self->id,
        name             => $self->name,
        certificate      => $self->certificate,
        domain_names     => $self->domain_names,
        fingerprint      => $self->fingerprint,
        status           => $self->status,
        type             => $self->type,
        labels           => $self->labels,
        created          => $self->created,
        not_valid_before => $self->not_valid_before,
        not_valid_after  => $self->not_valid_after,
    };
}

=method data

    my $hashref = $cert->data;

Returns all certificate data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::Certificates> - Certificates API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::LoadBalancer> - Load balancer entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
