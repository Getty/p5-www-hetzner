package WWW::Hetzner::Cloud::API::FloatingIPs;

# ABSTRACT: Hetzner Cloud Floating IPs API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::FloatingIP;
use namespace::clean;

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

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/floating_ips', params => \%params);
    return $self->_wrap_list($result->{floating_ips} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    my $result = $self->client->get("/floating_ips/$id");
    return $self->_wrap($result->{floating_ip});
}

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

sub delete {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    return $self->client->delete("/floating_ips/$id");
}

sub assign {
    my ($self, $id, $server_id) = @_;
    croak "Floating IP ID required" unless $id;
    croak "Server ID required" unless $server_id;

    return $self->client->post("/floating_ips/$id/actions/assign", {
        server => $server_id,
    });
}

sub unassign {
    my ($self, $id) = @_;
    croak "Floating IP ID required" unless $id;

    return $self->client->post("/floating_ips/$id/actions/unassign", {});
}

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

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::FloatingIPs - Hetzner Cloud Floating IPs API

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

=head1 METHODS

=head2 list(%params)

Returns arrayref of FloatingIP objects.

=head2 get($id)

Returns FloatingIP object.

=head2 create(%params)

Creates floating IP. Required: type, home_location. Optional: name, description, server, labels.

=head2 update($id, %params)

Updates floating IP. Params: name, description, labels.

=head2 delete($id)

Deletes floating IP.

=head2 assign($id, $server_id)

Assign floating IP to server.

=head2 unassign($id)

Unassign floating IP from server.

=head2 change_dns_ptr($id, $ip, $dns_ptr)

Change reverse DNS pointer.

=cut
