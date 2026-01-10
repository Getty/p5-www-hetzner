package WWW::Hetzner::Cloud::API::ServerTypes;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Server Types API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::ServerType;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::ServerType->new(
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

    my $result = $self->client->get('/server_types', params => \%params);
    return $self->_wrap_list($result->{server_types} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Server Type ID required" unless $id;

    my $result = $self->client->get("/server_types/$id");
    return $self->_wrap($result->{server_type});
}

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $types = $self->list;
    for my $type (@$types) {
        return $type if $type->name eq $name;
    }
    return;
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::ServerTypes - Hetzner Cloud Server Types API

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all server types
    my $types = $cloud->server_types->list;

    # Get by ID
    my $type = $cloud->server_types->get(22);

    # Get by name
    my $cx23 = $cloud->server_types->get_by_name('cx23');
    printf "CX23: %d cores, %d GB RAM\n", $cx23->cores, $cx23->memory;

=head1 DESCRIPTION

This module provides access to Hetzner Cloud server types. Server types define
the available CPU, memory, and disk configurations for cloud servers.
All methods return L<WWW::Hetzner::Cloud::ServerType> objects.

=head1 METHODS

=head2 list

    my $types = $cloud->server_types->list;

Returns an arrayref of L<WWW::Hetzner::Cloud::ServerType> objects.

=head2 get

    my $type = $cloud->server_types->get($id);

Returns a L<WWW::Hetzner::Cloud::ServerType> object.

=head2 get_by_name

    my $type = $cloud->server_types->get_by_name('cx23');

Returns a L<WWW::Hetzner::Cloud::ServerType> object. Returns undef if not found.

=cut
