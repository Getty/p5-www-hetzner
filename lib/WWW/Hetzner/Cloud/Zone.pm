package WWW::Hetzner::Cloud::Zone;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud DNS Zone object

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::API::RRSets;
use namespace::clean;

=head1 SYNOPSIS

    my $zone = $cloud->zones->get($id);

    # Read attributes
    print $zone->id, "\n";
    print $zone->name, "\n";
    print $zone->status, "\n";
    print $zone->ttl, "\n";

    # Update
    $zone->name('newdomain.com');
    $zone->labels({ env => 'prod' });
    $zone->update;

    # Access RRSets (DNS records)
    my $rrsets = $zone->rrsets;
    my $records = $rrsets->list;
    $rrsets->add_a('www', '1.2.3.4');

    # Export as zone file
    my $zonefile = $zone->export;

    # Delete
    $zone->delete;

=head1 DESCRIPTION

This class represents a Hetzner Cloud DNS zone. Objects are returned by
L<WWW::Hetzner::Cloud::API::Zones> methods.

=cut

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );

=attr id

Zone ID (read-only).

=cut

has name => ( is => 'rw' );

=attr name

Zone name / domain (read-write).

=cut

has status => ( is => 'ro' );

=attr status

Zone status: verified, pending, failed (read-only).

=cut

has ttl => ( is => 'rw' );

=attr ttl

Default TTL for records (read-write).

=cut

has created => ( is => 'ro' );

=attr created

Creation timestamp (read-only).

=cut

has ns => ( is => 'ro', default => sub { [] } );

=attr ns

Nameservers arrayref (read-only).

=cut

has records_count => ( is => 'ro' );

=attr records_count

Number of records in the zone (read-only).

=cut

has is_secondary_dns => ( is => 'ro' );

=attr is_secondary_dns

Whether this is a secondary DNS zone (read-only).

=cut

has labels => ( is => 'rw', default => sub { {} } );

=attr labels

Labels hash (read-write).

=cut

sub update {
    my ($self) = @_;
    croak "Cannot update zone without ID" unless $self->id;

    $self->_client->put("/zones/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

=method update

    $zone->name('newdomain.com');
    $zone->update;

Saves changes to name and labels back to the API.

=cut

sub delete {
    my ($self) = @_;
    croak "Cannot delete zone without ID" unless $self->id;

    $self->_client->delete("/zones/" . $self->id);
    return 1;
}

=method delete

    $zone->delete;

Deletes the zone and all its records.

=cut

sub rrsets {
    my ($self) = @_;
    croak "Cannot get rrsets without zone ID" unless $self->id;

    return WWW::Hetzner::Cloud::API::RRSets->new(
        client  => $self->_client,
        zone_id => $self->id,
    );
}

=method rrsets

    my $rrsets = $zone->rrsets;

Returns a L<WWW::Hetzner::Cloud::API::RRSets> object for managing DNS records.

=cut

sub export {
    my ($self) = @_;
    croak "Cannot export zone without ID" unless $self->id;

    return $self->_client->get("/zones/" . $self->id . "/export");
}

=method export

    my $zonefile = $zone->export;

Exports the zone as a standard zone file format.

=cut

sub data {
    my ($self) = @_;
    return {
        id              => $self->id,
        name            => $self->name,
        status          => $self->status,
        ttl             => $self->ttl,
        created         => $self->created,
        ns              => $self->ns,
        records_count   => $self->records_count,
        is_secondary_dns => $self->is_secondary_dns,
        labels          => $self->labels,
    };
}

=method data

    my $hashref = $zone->data;

Returns all zone data as a hashref (for JSON serialization).

=cut

1;
