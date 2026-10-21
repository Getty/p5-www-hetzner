package WWW::Hetzner::Role::HasAction;
# ABSTRACT: Entity role exposing a creation action

our $VERSION = '0.103';

use Moo::Role;
use namespace::clean;

=head1 SYNOPSIS

    package WWW::Hetzner::Cloud::Server;
    use Moo;
    with 'WWW::Hetzner::Role::HasAction';

    # after create()
    print $server->action->command, "\n";       # e.g. "create_server"
    print scalar @{ $server->next_actions }, "\n";

=head1 DESCRIPTION

Shared attributes for entities whose creation endpoint returns a singular
C<action> (and optionally C<next_actions>) alongside the resource itself.
The owning API controller populates them from its C<create> response; they are
not maintained afterwards.

=cut

has action => ( is => 'ro' );

=attr action

The L<WWW::Hetzner::Action> returned by C<create>, or undef when the API did
not emit one. Reflects creation state only: the consuming entity's own
C<refresh> method, where it defines one, does not update it.

=cut

has next_actions => ( is => 'ro', default => sub { [] } );

=attr next_actions

Arrayref of L<WWW::Hetzner::Action> objects returned by C<create> as
C<next_actions>. Empty arrayref when the API did not emit any.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Role::HasActions> - Controller role wrapping raw hashes as Action objects

=item * L<WWW::Hetzner::Action> - Action entity class

=back

=cut

1;
