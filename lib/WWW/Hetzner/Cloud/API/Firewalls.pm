package WWW::Hetzner::Cloud::API::Firewalls;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Firewalls API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Firewall;
use namespace::clean;

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

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/firewalls', params => \%params);
    return $self->_wrap_list($result->{firewalls} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Firewall ID required" unless $id;

    my $result = $self->client->get("/firewalls/$id");
    return $self->_wrap($result->{firewall});
}

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

sub update {
    my ($self, $id, %params) = @_;
    croak "Firewall ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/firewalls/$id", $body);
    return $self->_wrap($result->{firewall});
}

sub delete {
    my ($self, $id) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->delete("/firewalls/$id");
}

sub set_rules {
    my ($self, $id, $rules) = @_;
    croak "Firewall ID required" unless $id;
    croak "Rules arrayref required" unless ref $rules eq 'ARRAY';

    return $self->client->post("/firewalls/$id/actions/set_rules", {
        rules => $rules,
    });
}

sub apply_to_resources {
    my ($self, $id, @resources) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->post("/firewalls/$id/actions/apply_to_resources", {
        apply_to => \@resources,
    });
}

sub remove_from_resources {
    my ($self, $id, @resources) = @_;
    croak "Firewall ID required" unless $id;

    return $self->client->post("/firewalls/$id/actions/remove_from_resources", {
        remove_from => \@resources,
    });
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::Firewalls - Hetzner Cloud Firewalls API

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

=head1 METHODS

=head2 list(%params)

Returns arrayref of Firewall objects.

=head2 get($id)

Returns Firewall object.

=head2 create(%params)

Creates firewall. Required: name. Optional: rules, labels, apply_to.

=head2 update($id, %params)

Updates firewall. Params: name, labels.

=head2 delete($id)

Deletes firewall.

=head2 set_rules($id, @rules)

Set firewall rules.

=head2 apply_to_resources($id, @resources)

Apply firewall to resources.

=head2 remove_from_resources($id, @resources)

Remove firewall from resources.

=cut
