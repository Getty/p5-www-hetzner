package WWW::Hetzner::Cloud::Datacenter;

# ABSTRACT: Hetzner Cloud Datacenter object

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
has location_data => ( is => 'ro', init_arg => 'location', default => sub { {} } );

sub location { shift->location_data->{name} }

sub data {
    my ($self) = @_;
    return {
        id          => $self->id,
        name        => $self->name,
        description => $self->description,
        location    => $self->location_data,
    };
}

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Datacenter - Hetzner Cloud Datacenter object

=head1 SYNOPSIS

    my $dc = $cloud->datacenters->get_by_name('fsn1-dc14');

    print $dc->name, "\n";        # fsn1-dc14
    print $dc->description, "\n"; # Falkenstein 1 DC14
    print $dc->location, "\n";    # fsn1

=head1 DESCRIPTION

This class represents a Hetzner Cloud datacenter (virtual subdivision of a location).
Objects are returned by L<WWW::Hetzner::Cloud::API::Datacenters> methods.

Datacenters are read-only resources.

=head1 ATTRIBUTES

=head2 id

Datacenter ID.

=head2 name

Datacenter name, e.g. "fsn1-dc14".

=head2 description

Human-readable description.

=head2 location

Location name (convenience accessor).

=head1 METHODS

=head2 data

    my $hashref = $dc->data;

Returns all datacenter data as a hashref (for JSON serialization).

=cut
