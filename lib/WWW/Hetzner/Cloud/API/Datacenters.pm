package WWW::Hetzner::Cloud::API::Datacenters;

# ABSTRACT: Hetzner Cloud Datacenters API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Datacenter;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Datacenter->new(
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

    my $result = $self->client->get('/datacenters', params => \%params);
    return $self->_wrap_list($result->{datacenters} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Datacenter ID required" unless $id;

    my $result = $self->client->get("/datacenters/$id");
    return $self->_wrap($result->{datacenter});
}

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $datacenters = $self->list;
    for my $dc (@$datacenters) {
        return $dc if $dc->name eq $name;
    }
    return;
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::Datacenters - Hetzner Cloud Datacenters API

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all datacenters
    my $datacenters = $cloud->datacenters->list;

    # Get by name
    my $dc = $cloud->datacenters->get_by_name('fsn1-dc14');
    printf "Datacenter: %s at %s\n", $dc->name, $dc->location;

=head1 DESCRIPTION

This module provides access to Hetzner Cloud datacenters. Datacenters are
virtual subdivisions of locations with specific server type availability.
All methods return L<WWW::Hetzner::Cloud::Datacenter> objects.

=head1 METHODS

=head2 list

    my $datacenters = $cloud->datacenters->list;

Returns an arrayref of L<WWW::Hetzner::Cloud::Datacenter> objects.

=head2 get

    my $datacenter = $cloud->datacenters->get($id);

Returns a L<WWW::Hetzner::Cloud::Datacenter> object.

=head2 get_by_name

    my $datacenter = $cloud->datacenters->get_by_name('fsn1-dc14');

Returns a L<WWW::Hetzner::Cloud::Datacenter> object. Returns undef if not found.

=cut
