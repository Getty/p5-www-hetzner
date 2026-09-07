package WWW::Hetzner::Cloud::API::Actions;
# ABSTRACT: Hetzner Cloud Actions API

our $VERSION = '0.101';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Action;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all actions
    my $actions = $cloud->actions->list;

    # Fetch a single action
    my $action = $cloud->actions->get($id);

    # Action is a WWW::Hetzner::Cloud::Action object
    print $action->status, "\n";

    # Block until it finishes
    $action->wait;

=head1 DESCRIPTION

This module provides the API for reading Hetzner Cloud actions, the async
job objects returned by resource-mutating calls. All methods return
L<WWW::Hetzner::Cloud::Action> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Action->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method get

    my $action = $cloud->actions->get($id);

Returns a L<WWW::Hetzner::Cloud::Action> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Action ID required" unless $id;

    my $result = $self->client->get("/actions/$id");
    return $self->_wrap($result->{action});
}

=method list

    my $actions = $cloud->actions->list;
    my $actions = $cloud->actions->list(status => 'running');

Returns an arrayref of L<WWW::Hetzner::Cloud::Action> objects.
Optional parameters: status, sort.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/actions', params => \%params);
    return $self->_wrap_list($result->{actions} // []);
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Action> - Action entity class

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
