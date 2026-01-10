package WWW::Hetzner::Cloud::Location;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud Location object

use Moo;
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'ro' );
has description => ( is => 'ro' );
has city => ( is => 'ro' );
has country => ( is => 'ro' );
has network_zone => ( is => 'ro' );

sub data {
    my ($self) = @_;
    return {
        id           => $self->id,
        name         => $self->name,
        description  => $self->description,
        city         => $self->city,
        country      => $self->country,
        network_zone => $self->network_zone,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Location - Hetzner Cloud Location object

=head1 SYNOPSIS

    my $loc = $cloud->locations->get_by_name('fsn1');

    print $loc->name, "\n";         # fsn1
    print $loc->city, "\n";         # Falkenstein
    print $loc->country, "\n";      # DE
    print $loc->network_zone, "\n"; # eu-central

=head1 DESCRIPTION

This class represents a Hetzner Cloud location (physical data center site).
Objects are returned by L<WWW::Hetzner::Cloud::API::Locations> methods.

Locations are read-only resources.

=head1 ATTRIBUTES

=head2 id

Location ID.

=head2 name

Location name, e.g. "fsn1", "nbg1", "hel1".

=head2 description

Human-readable description.

=head2 city

City name, e.g. "Falkenstein".

=head2 country

Country code, e.g. "DE".

=head2 network_zone

Network zone, e.g. "eu-central".

=head1 METHODS

=head2 data

    my $hashref = $loc->data;

Returns all location data as a hashref (for JSON serialization).

=cut
