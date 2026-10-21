package WWW::Hetzner::Storage::StorageBoxType;
# ABSTRACT: Hetzner Storage Box Type object

our $VERSION = '0.103';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $type = $storage->storage_box_types->get_by_name('bx20');
    print $type->size, "\n";

=head1 DESCRIPTION

Represents a Storage Box type returned by
L<WWW::Hetzner::Storage::API::StorageBoxTypes>.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id                       => ( is => 'ro' );
has name                     => ( is => 'ro' );
has description              => ( is => 'ro' );
has snapshot_limit           => ( is => 'ro' );
has automatic_snapshot_limit => ( is => 'ro' );
has subaccounts_limit        => ( is => 'ro' );
has size                     => ( is => 'ro' );
has prices                   => ( is => 'ro' );
has deprecation              => ( is => 'ro' );

=attr id

Storage Box Type ID (read-only).

=cut

=attr name

Storage Box Type name, e.g. C<bx20> (read-only).

=cut

=attr description

Human-readable description (read-only).

=cut

=attr snapshot_limit

Maximum number of manual snapshots, or undef when unlimited (read-only).

=cut

=attr automatic_snapshot_limit

Maximum number of automatic snapshots, or undef when unlimited (read-only).

=cut

=attr subaccounts_limit

Maximum number of subaccounts (read-only).

=cut

=attr size

Storage size in bytes (read-only).

=cut

=attr prices

Arrayref of per-location pricing data (read-only).

=cut

=attr deprecation

Deprecation data, or undef when not deprecated (read-only).

=cut

=method data

    my $hashref = $type->data;

Returns the complete Storage Box Type representation returned by the API.

=cut

sub data {
    my ($self) = @_;
    return {
        id                       => $self->id,
        name                     => $self->name,
        description              => $self->description,
        snapshot_limit           => $self->snapshot_limit,
        automatic_snapshot_limit => $self->automatic_snapshot_limit,
        subaccounts_limit        => $self->subaccounts_limit,
        size                     => $self->size,
        prices                   => $self->prices,
        deprecation              => $self->deprecation,
    };
}

=seealso

=over 4

=item * L<WWW::Hetzner::Storage::API::StorageBoxTypes> - Storage Box Type controller

=item * L<WWW::Hetzner::Storage> - Storage client

=back

=cut

1;
