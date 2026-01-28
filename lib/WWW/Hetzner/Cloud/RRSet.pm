package WWW::Hetzner::Cloud::RRSet;
# ABSTRACT: Hetzner Cloud DNS RRSet object

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use namespace::clean;

=head1 SYNOPSIS

    my $record = $zone->rrsets->get('www', 'A');

    # Read attributes
    print $record->name, "\n";
    print $record->type, "\n";
    print $record->ttl, "\n";

    # Get values
    my $values = $record->values;  # ['1.2.3.4']

    # Update
    $record->ttl(600);
    $record->records([{ value => '5.6.7.8' }]);
    $record->update;

    # Delete
    $record->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud DNS RRSet (Resource Record Set).
Objects are returned by L<WWW::Hetzner::Cloud::API::RRSets> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has zone_id => ( is => 'ro', required => 1 );

=attr zone_id

Zone ID this record belongs to (read-only).

=cut

has name => ( is => 'ro' );

=attr name

Record name, e.g. "www" or "@" for apex (read-only).

=cut

has type => ( is => 'ro' );

=attr type

Record type: A, AAAA, CNAME, MX, TXT, etc. (read-only).

=cut

has ttl => ( is => 'rw' );

=attr ttl

Time to live in seconds (read-write).

=cut

has records => ( is => 'rw', default => sub { [] } );

=attr records

Arrayref of record values: C<[{ value => '1.2.3.4' }, ...]> (read-write).

=cut

sub update {
    my ($self) = @_;
    croak "Cannot update RRSet without zone_id" unless $self->zone_id;
    croak "Cannot update RRSet without name" unless $self->name;
    croak "Cannot update RRSet without type" unless $self->type;

    my $path = "/zones/" . $self->zone_id . "/rrsets/" . $self->name . "/" . $self->type;
    $self->_client->put($path, {
        ttl     => $self->ttl,
        records => $self->records,
    });
    return $self;
}

=method update

    $record->ttl(600);
    $record->records([{ value => '5.6.7.8' }]);
    $record->update;

Saves changes to TTL and records back to the API.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete RRSet without zone_id" unless $self->zone_id;
    croak "Cannot delete RRSet without name" unless $self->name;
    croak "Cannot delete RRSet without type" unless $self->type;

    my $path = "/zones/" . $self->zone_id . "/rrsets/" . $self->name . "/" . $self->type;
    $self->_client->delete($path);
    return 1;
}

=method delete

    $record->delete;

Deletes the RRSet.

=cut

sub values {
    my ($self) = @_;
    return [ map { $_->{value} } @{$self->records} ];
}

=method values

    my $values = $record->values;  # ['1.2.3.4', '5.6.7.8']

Returns an arrayref of just the record values (without the hash structure).

=cut

sub data {
    my ($self) = @_;
    return {
        zone_id => $self->zone_id,
        name    => $self->name,
        type    => $self->type,
        ttl     => $self->ttl,
        records => $self->records,
    };
}

=method data

    my $hashref = $record->data;

Returns all RRSet data as a hashref (for JSON serialization).

=cut

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud::API::RRSets> - DNS records API

=item * L<WWW::Hetzner::Cloud::API::Zones> - Zones API

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Zone> - DNS zone entity

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1.
