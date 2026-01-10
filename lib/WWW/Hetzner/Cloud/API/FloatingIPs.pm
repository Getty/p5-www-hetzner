package WWW::Hetzner::Cloud::API::FloatingIPs;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Floating IPs API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::FloatingIP;
use namespace::clean;

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List floating IPs
    my $fips = $cloud->floating_ips->list;

    # Create floating IP
    my $fip = $cloud->floating_ips->create(
        type          => 'ipv4',
        home_location => 'fsn1',
        name          => 'my-floating-ip',
    );

    # Assign to server
    $cloud->floating_ips->assign($fip->id, $server_id);

    # Unassign
    $cloud->floating_ips->unassign($fip->id);

    # Delete
    $cloud->floating_ips->delete($fip->id);

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud floating IPs.
All methods return L<WWW::Hetzner::Cloud::FloatingIP> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::FloatingIP->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $fips = $cloud->floating_ips->list;
    my $fips = $cloud->floating_ips->list(label_selector => 'env=prod');

Returns arrayref of L<WWW::Hetzner::Cloud::FloatingIP> objects.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/floating_ips', params => \%params);
    return $self->_wrap_list($result->{floating_ips} // []);
}

=method get

    my $fip = $cloud->floating_ips->get($id);

Returns L<WWW::Hetzner::Cloud::FloatingIP> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    my $result = $self->client->get("/floating_ips/$id");
    return $self->_wrap($result->{floating_ip});
}

=method create

    my $fip = $cloud->floating_ips->create(
        type          => 'ipv4',       # required (ipv4 or ipv6)
        home_location => 'fsn1',       # required
        name          => 'my-ip',      # optional
        description   => '...',        # optional
        server        => $server_id,   # optional
        labels        => { ... },      # optional
    );

Creates floating IP. Returns L<WWW::Hetzner::Cloud::FloatingIP> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "type required (ipv4 or ipv6)" unless $params{type};
    croak "home_location required" unless $params{home_location};

    my $body = {
        type          => $params{type},
        home_location => $params{home_location},
    };

    $body->{name}        = $params{name}        if $params{name};
    $body->{description} = $params{description} if $params{description};
    $body->{server}      = $params{server}      if $params{server};
    $body->{labels}      = $params{labels}      if $params{labels};

    my $result = $self->client->post('/floating_ips', $body);
    return $self->_wrap($result->{floating_ip});
}

=method update

    $cloud->floating_ips->update($id,
        name        => 'new-name',
        description => 'new description',
        labels      => { ... },
    );

Updates floating IP. Returns L<WWW::Hetzner::Cloud::FloatingIP> object.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak "Floating IP ID required" unless $id;

    my $body = {};
    $body->{name}        = $params{name}        if exists $params{name};
    $body->{description} = $params{description} if exists $params{description};
    $body->{labels}      = $params{labels}      if exists $params{labels};

    my $result = $self->client->put("/floating_ips/$id", $body);
    return $self->_wrap($result->{floating_ip});
}

=method delete

    $cloud->floating_ips->delete($id);

Deletes floating IP.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    return $self->client->delete("/floating_ips/$id");
}

=method assign

    $cloud->floating_ips->assign($id, $server_id);

Assign floating IP to server.

=cut

sub assign {
    my ($self, $id, $server_id) = @_;
    croak "Floating IP ID required" unless $id;
    croak "Server ID required" unless $server_id;

    return $self->client->post("/floating_ips/$id/actions/assign", {
        server => $server_id,
    });
}

=method unassign

    $cloud->floating_ips->unassign($id);

Unassign floating IP from server.

=cut

sub unassign {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    return $self->client->post("/floating_ips/$id/actions/unassign", {});
}

=method change_dns_ptr

    $cloud->floating_ips->change_dns_ptr($id, $ip, $dns_ptr);

Change reverse DNS pointer for the floating IP.

=cut

sub change_dns_ptr {
    my ($self, $id, $ip, $dns_ptr) = @_;
    croak "Floating IP ID required" unless $id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    return $self->client->post("/floating_ips/$id/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
}

1;
