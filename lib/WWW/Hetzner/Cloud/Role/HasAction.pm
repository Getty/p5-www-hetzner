package WWW::Hetzner::Cloud::Role::HasAction;
# ABSTRACT: Entity role exposing the creation Action

our $VERSION = '0.101';

use Moo::Role;
use namespace::clean;

=head1 SYNOPSIS

    package WWW::Hetzner::Cloud::Server;
    use Moo;
    with 'WWW::Hetzner::Cloud::Role::HasAction';

    # after create()
    print $server->action->command, "\n";       # e.g. "create_server"
    print scalar @{ $server->next_actions }, "\n";

=head1 DESCRIPTION

Shared attributes for Cloud entities whose creation endpoint returns a
singular C<action> (and optionally C<next_actions>) alongside the resource
itself. Populated by the owning API controller's C<create> method; not
maintained afterwards.

Consumed by L<WWW::Hetzner::Cloud::Certificate>, L<WWW::Hetzner::Cloud::FloatingIP>,
L<WWW::Hetzner::Cloud::LoadBalancer>, L<WWW::Hetzner::Cloud::PrimaryIP>,
L<WWW::Hetzner::Cloud::Server>, L<WWW::Hetzner::Cloud::Volume>,
L<WWW::Hetzner::Cloud::PlacementGroup> and L<WWW::Hetzner::Cloud::Zone> --
the eight entities whose C<create> response carries a singular C<action>.
L<WWW::Hetzner::Cloud::Firewall> is the exception: its C<create> returns
C<actions> in the plural, so it does not consume this role and instead
declares its own L<WWW::Hetzner::Cloud::Firewall/actions> attribute.

=cut

has action => ( is => 'ro' );

=attr action

The L<WWW::Hetzner::Cloud::Action> returned by C<create>, or undef when the
API did not emit one (e.g. an unmanaged placement group). Reflects creation
state only: the consuming entity's own C<refresh> method, where it defines
one, does not update it.

=cut

has next_actions => ( is => 'ro', default => sub { [] } );

=attr next_actions

Arrayref of L<WWW::Hetzner::Cloud::Action> objects returned by C<create> as
C<next_actions> (e.g. attaching to a network right after creation). Empty
arrayref when the API did not emit any.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::Role::HasActions> - Controller role wrapping raw hashes as Action objects

=item * L<WWW::Hetzner::Cloud::Action> - Action entity class

=back

=cut

1;
