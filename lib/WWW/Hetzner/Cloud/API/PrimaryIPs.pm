package WWW::Hetzner::Cloud::API::PrimaryIPs;

# ABSTRACT: Hetzner Cloud Primary IPs API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::PrimaryIP;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::PrimaryIP->new(
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

    my $result = $self->client->get('/primary_ips', params => \%params);
    return $self->_wrap_list($result->{primary_ips} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Primary IP ID required" unless $id;

    my $result = $self->client->get("/primary_ips/$id");
    return $self->_wrap($result->{primary_ip});
}

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "type required (ipv4 or ipv6)" unless $params{type};
    croak "assignee_type required" unless $params{assignee_type};
    croak "datacenter required" unless $params{datacenter};

    my $body = {
        name          => $params{name},
        type          => $params{type},
        assignee_type => $params{assignee_type},
        datacenter    => $params{datacenter},
    };

    $body->{assignee_id} = $params{assignee_id} if $params{assignee_id};
    $body->{auto_delete} = $params{auto_delete} if exists $params{auto_delete};
    $body->{labels}      = $params{labels}      if $params{labels};

    my $result = $self->client->post('/primary_ips', $body);
    return $self->_wrap($result->{primary_ip});
}

sub update {
    my ($self, $id, %params) = @_;
    croak "Primary IP ID required" unless $id;

    my $body = {};
    $body->{name}        = $params{name}        if exists $params{name};
    $body->{auto_delete} = $params{auto_delete} if exists $params{auto_delete};
    $body->{labels}      = $params{labels}      if exists $params{labels};

    my $result = $self->client->put("/primary_ips/$id", $body);
    return $self->_wrap($result->{primary_ip});
}

sub delete {
    my ($self, $id) = @_;
    croak "Primary IP ID required" unless $id;

    return $self->client->delete("/primary_ips/$id");
}

sub assign {
    my ($self, $id, $assignee_id, $assignee_type) = @_;
    croak "Primary IP ID required" unless $id;
    croak "Assignee ID required" unless $assignee_id;
    $assignee_type //= 'server';

    return $self->client->post("/primary_ips/$id/actions/assign", {
        assignee_id   => $assignee_id,
        assignee_type => $assignee_type,
    });
}

sub unassign {
    my ($self, $id) = @_;
    croak "Primary IP ID required" unless $id;

    return $self->client->post("/primary_ips/$id/actions/unassign", {});
}

sub change_dns_ptr {
    my ($self, $id, $ip, $dns_ptr) = @_;
    croak "Primary IP ID required" unless $id;
    croak "IP required" unless $ip;
    croak "dns_ptr required" unless defined $dns_ptr;

    return $self->client->post("/primary_ips/$id/actions/change_dns_ptr", {
        ip      => $ip,
        dns_ptr => $dns_ptr,
    });
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::PrimaryIPs - Hetzner Cloud Primary IPs API

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List primary IPs
    my $pips = $cloud->primary_ips->list;

    # Create primary IP
    my $pip = $cloud->primary_ips->create(
        name          => 'my-primary-ip',
        type          => 'ipv4',
        assignee_type => 'server',
        datacenter    => 'fsn1-dc14',
    );

    # Assign to server
    $cloud->primary_ips->assign($pip->id, $server_id, 'server');

    # Unassign
    $cloud->primary_ips->unassign($pip->id);

    # Delete
    $cloud->primary_ips->delete($pip->id);

=head1 METHODS

=head2 list(%params)

Returns arrayref of PrimaryIP objects.

=head2 get($id)

Returns PrimaryIP object.

=head2 create(%params)

Creates primary IP. Required: name, type, assignee_type, datacenter. Optional: assignee_id, auto_delete, labels.

=head2 update($id, %params)

Updates primary IP. Params: name, auto_delete, labels.

=head2 delete($id)

Deletes primary IP.

=head2 assign($id, $assignee_id, $assignee_type)

Assign primary IP to resource.

=head2 unassign($id)

Unassign primary IP from resource.

=head2 change_dns_ptr($id, $ip, $dns_ptr)

Change reverse DNS pointer.

=cut
