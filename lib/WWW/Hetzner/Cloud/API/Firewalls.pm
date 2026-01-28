package WWW::Hetzner::Cloud::API::Firewalls;
# ABSTRACT: Hetzner Cloud Firewalls API

our $VERSION = '0.004';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Firewall;
use namespace::clean;

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List firewalls
    my $firewalls = $cloud->firewalls->list;

    # Create firewall with rules
    my $fw = $cloud->firewalls->create(
        name  => 'web-firewall',
        rules => [
            {
                direction   => 'in',
                protocol    => 'tcp',
                port        => '22',
                source_ips  => ['0.0.0.0/0', '::/0'],
            },
            {
                direction   => 'in',
                protocol    => 'tcp',
                port        => '80',
                source_ips  => ['0.0.0.0/0', '::/0'],
            },
        ],
    );

    # Apply to server
    $cloud->firewalls->apply_to_resources($fw->id,
        { type => 'server', server => { id => 123 } },
    );

    # Delete
    $cloud->firewalls->delete($fw->id);

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud firewalls.
All methods return L<WWW::Hetzner::Cloud::Firewall> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Firewall->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $firewalls = $cloud->firewalls->list;
    my $firewalls = $cloud->firewalls->list(label_selector => 'env=prod');

Returns arrayref of L<WWW::Hetzner::Cloud::Firewall> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/firewalls', params => \%params);
    return $self->_wrap_list($result->{firewalls} // []);
}

=method get

    my $firewall = $cloud->firewalls->get($id);

Returns L<WWW::Hetzner::Cloud::Firewall> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Firewall ID required" unless $id;

    my $result = $self->client->get("/firewalls/$id");
    return $self->_wrap($result->{firewall});
}

=method create

    my $fw = $cloud->firewalls->create(
        name     => 'my-firewall',  # required
        rules    => [ ... ],        # optional
        labels   => { ... },        # optional
        apply_to => [ ... ],        # optional
    );

Creates firewall. Returns L<WWW::Hetzner::Cloud::Firewall> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};

    my $body = {
        name => $params{name},
    };

    $body->{rules}    = $params{rules}    if $params{rules};
    $body->{labels}   = $params{labels}   if $params{labels};
    $body->{apply_to} = $params{apply_to} if $params{apply_to};

    my $result = $self->client->post('/firewalls', $body);
    return $self->_wrap($result->{firewall});
}

=method update

    $cloud->firewalls->update($id, name => 'new-name', labels => { ... });

Updates firewall. Returns L<WWW::Hetzner::Cloud::Firewall> object.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak "Firewall ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/firewalls/$id", $body);
    return $self->_wrap($result->{firewall});
}

=method delete

    $cloud->firewalls->delete($id);

Deletes firewall.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->delete("/firewalls/$id");
}

=method set_rules

    $cloud->firewalls->set_rules($id, \@rules);

Set firewall rules, replacing all existing rules.

=cut

sub set_rules {
    my ($self, $id, $rules) = @_;
    croak "Firewall ID required" unless $id;
    croak "Rules arrayref required" unless ref $rules eq 'ARRAY';

    return $self->client->post("/firewalls/$id/actions/set_rules", {
        rules => $rules,
    });
}

=method apply_to_resources

    $cloud->firewalls->apply_to_resources($id,
        { type => 'server', server => { id => 123 } },
    );

Apply firewall to resources.

=cut

sub apply_to_resources {
    my ($self, $id, @resources) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->post("/firewalls/$id/actions/apply_to_resources", {
        apply_to => \@resources,
    });
}

=method remove_from_resources

    $cloud->firewalls->remove_from_resources($id,
        { type => 'server', server => { id => 123 } },
    );

Remove firewall from resources.

=cut

sub remove_from_resources {
    my ($self, $id, @resources) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->post("/firewalls/$id/actions/remove_from_resources", {
        remove_from => \@resources,
    });
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Firewall> - Firewall entity class

=item * L<WWW::Hetzner::CLI::Cmd::Firewall> - Firewall CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
