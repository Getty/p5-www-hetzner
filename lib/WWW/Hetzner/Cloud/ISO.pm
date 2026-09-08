package WWW::Hetzner::Cloud::ISO;
# ABSTRACT: Hetzner Cloud ISO object

our $VERSION = '0.101';

use Moo;
use namespace::clean;

=head1 SYNOPSIS

    my $iso = $cloud->isos->get_by_name('netboot.xyz.iso');

    print $iso->name, "\n";         # netboot.xyz.iso
    print $iso->description, "\n";  # netboot.xyz
    print $iso->type, "\n";         # public
    print $iso->architecture, "\n"; # x86

    $cloud->servers->attach_iso($server_id, $iso->name);

=head1 DESCRIPTION

This class represents a Hetzner Cloud ISO image. Objects are returned by
L<WWW::Hetzner::Cloud::API::ISOs> methods.

ISOs are read-only resources.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

ISO ID.

=cut

has name => ( is => 'ro' );

=attr name

ISO name, e.g. "netboot.xyz.iso". This is what
L<WWW::Hetzner::Cloud::API::Servers/attach_iso> expects.

=cut

has description => ( is => 'ro' );

=attr description

Human-readable description.

=cut

has type => ( is => 'ro' );

=attr type

ISO type: public or private.

=cut

has architecture => ( is => 'ro' );

=attr architecture

CPU architecture the ISO can be attached to: x86 or arm. undef for ISOs
that are not bound to an architecture.

=cut

has deprecation => ( is => 'ro' );

=attr deprecation

Deprecation hashref with C<announced> and C<unavailable_after> timestamps,
undef unless the ISO is deprecated.

=cut

has deprecated => ( is => 'ro' );

=attr deprecated

Legacy deprecation timestamp. Superseded by C<deprecation> in the current
API; kept for responses that still carry it.

=cut

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        description  => $self->description,
        type         => $self->type,
        architecture => $self->architecture,
        deprecation  => $self->deprecation,
        deprecated   => $self->deprecated,
    };
}

=method data

    my $hashref = $iso->data;

Returns all ISO data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::ISOs> - ISOs API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::API::Servers> - Servers API (attach_iso, detach_iso)

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
