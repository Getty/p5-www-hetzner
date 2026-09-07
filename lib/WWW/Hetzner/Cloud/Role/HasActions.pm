package WWW::Hetzner::Cloud::Role::HasActions;
# ABSTRACT: Controller role wrapping raw hashes as Action objects

our $VERSION = '0.101';

use Moo::Role;
use WWW::Hetzner::Cloud::Action;
use namespace::clean;

=head1 SYNOPSIS

    package WWW::Hetzner::Cloud::API::Servers;
    use Moo;
    with 'WWW::Hetzner::Cloud::Role::HasActions';

    # inside a method that returns an action
    return $self->_wrap_action($result->{action});

=head1 DESCRIPTION

Shared helper for Cloud API controllers whose endpoints return an action or
a list of actions alongside (or instead of) the primary resource. Wraps raw
decoded-JSON hashes as L<WWW::Hetzner::Cloud::Action> objects.

Requires the consumer to provide a C<client> attribute/method, as every
Cloud API controller does.

=cut

requires 'client';

sub _wrap_action {
    my ($self, $data) = @_;
    return defined $data
        ? WWW::Hetzner::Cloud::Action->new(client => $self->client, %$data)
        : undef;
}

=method _wrap_action

    my $action = $self->_wrap_action($hash);

Wraps a decoded action hashref as a L<WWW::Hetzner::Cloud::Action>. Returns
undef when C<$hash> is undef.

=cut

sub _wrap_actions {
    my ($self, $list) = @_;
    return [ map { $self->_wrap_action($_) } @{ $list // [] } ];
}

=method _wrap_actions

    my $actions = $self->_wrap_actions($arrayref);

Wraps each element of C<$arrayref> via L</_wrap_action>. Returns an empty
arrayref when C<$arrayref> is undef.

=cut

sub _wrap_action_result {
    my ($self, $result) = @_;
    my %sidecar = %$result;
    my $action = delete $sidecar{action};
    return undef unless defined $action;
    WWW::Hetzner::Cloud::Action->new(client => $self->client, %$action, result => \%sidecar);
}

=method _wrap_action_result

    my $action = $self->_wrap_action_result($result);

Wraps a full decoded-JSON response hashref as a L<WWW::Hetzner::Cloud::Action>,
same as L</_wrap_action>, but keeps whatever the endpoint returned alongside
C<action> (e.g. C<root_password>) as the Action's L<WWW::Hetzner::Cloud::Action/result>.
Returns undef when C<$result> carries no C<action> key.

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::Action> - Action entity class

=item * L<WWW::Hetzner::Cloud::API::Actions> - Actions API

=back

=cut

1;
