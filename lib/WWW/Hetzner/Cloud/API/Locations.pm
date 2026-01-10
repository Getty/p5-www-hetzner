package WWW::Hetzner::Cloud::API::Locations;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Locations API

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::Location;
use namespace::clean;

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Location->new(
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

    my $result = $self->client->get('/locations', params => \%params);
    return $self->_wrap_list($result->{locations} // []);
}

sub get {
    my ($self, $id) = @_;
    croak "Location ID required" unless $id;

    my $result = $self->client->get("/locations/$id");
    return $self->_wrap($result->{location});
}

sub get_by_name {
    my ($self, $name) = @_;
    croak "Name required" unless $name;

    my $locations = $self->list;
    for my $loc (@$locations) {
        return $loc if $loc->name eq $name;
    }
    return;
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::API::Locations - Hetzner Cloud Locations API

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all locations
    my $locations = $cloud->locations->list;

    # Get by name
    my $fsn1 = $cloud->locations->get_by_name('fsn1');
    printf "Falkenstein: %s, %s\n", $fsn1->city, $fsn1->country;

=head1 DESCRIPTION

This module provides access to Hetzner Cloud locations. Locations are physical
data center sites where servers can be deployed.
All methods return L<WWW::Hetzner::Cloud::Location> objects.

Available locations: fsn1 (Falkenstein), nbg1 (Nuremberg), hel1 (Helsinki),
ash (Ashburn), hil (Hillsboro), sin (Singapore).

=head1 METHODS

=head2 list

    my $locations = $cloud->locations->list;

Returns an arrayref of L<WWW::Hetzner::Cloud::Location> objects.

=head2 get

    my $location = $cloud->locations->get($id);

Returns a L<WWW::Hetzner::Cloud::Location> object.

=head2 get_by_name

    my $location = $cloud->locations->get_by_name('fsn1');

Returns a L<WWW::Hetzner::Cloud::Location> object. Returns undef if not found.

=cut
