package WWW::Hetzner::Cloud::API::Certificates;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Certificates API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Certificate;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Certificate->new(
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

    my $result = $self->client->get('/certificates', params => \%params);
    return $self->_wrap_list($result->{certificates} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Certificate ID required" unless $id;

    my $result = $self->client->get("/certificates/$id");
    return $self->_wrap($result->{certificate});
}

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "type required (uploaded or managed)" unless $params{type};

    my $body = {
        name => $params{name},
        type => $params{type},
    };

    # For uploaded certificates
    $body->{certificate} = $params{certificate} if $params{certificate};
    $body->{private_key} = $params{private_key} if $params{private_key};

    # For managed certificates
    $body->{domain_names} = $params{domain_names} if $params{domain_names};

    $body->{labels} = $params{labels} if $params{labels};

    my $result = $self->client->post('/certificates', $body);
    return $self->_wrap($result->{certificate});
}

sub update {
    my ($self, $id, %params) = @_;
    croak "Certificate ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/certificates/$id", $body);
    return $self->_wrap($result->{certificate});
}

sub delete {
    my ($self, $id) = @_;
    croak "Certificate ID required" unless $id;

    return $self->client->delete("/certificates/$id");
}

sub retry {
    my ($self, $id) = @_;
    croak "Certificate ID required" unless $id;

    return $self->client->post("/certificates/$id/actions/retry", {});
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::Certificates - Hetzner Cloud Certificates API

=head1 SYNOPSIS

    my $cloud = WWW::Hetzner::Cloud->new(token => $token);

    # List certificates
    my $certs = $cloud->certificates->list;

    # Create managed certificate (Let's Encrypt)
    my $cert = $cloud->certificates->create(
        name         => 'my-cert',
        type         => 'managed',
        domain_names => ['example.com', 'www.example.com'],
    );

    # Create uploaded certificate
    my $cert = $cloud->certificates->create(
        name        => 'my-cert',
        type        => 'uploaded',
        certificate => $pem_cert,
        private_key => $pem_key,
    );

    # Delete
    $cloud->certificates->delete($cert->id);

=cut
