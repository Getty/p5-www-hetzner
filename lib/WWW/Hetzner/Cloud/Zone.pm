package WWW::Hetzner::Cloud::Zone;
our $VERSION = '0.002';
# ABSTRACT: Hetzner Cloud DNS Zone object

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::API::RRSets;
use namespace::clean;

has _client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
    init_arg => 'client',
);

has id => ( is => 'ro' );
has name => ( is => 'rw' );
has status => ( is => 'ro' );
has ttl => ( is => 'rw' );
has created => ( is => 'ro' );
has ns => ( is => 'ro', default => sub { [] } );
has records_count => ( is => 'ro' );
has is_secondary_dns => ( is => 'ro' );
has labels => ( is => 'rw', default => sub { {} } );

sub update {
    my ($self) = @_;
    croak "Cannot update zone without ID" unless $self->id;

    $self->_client->put("/zones/" . $self->id, {
        name   => $self->name,
        labels => $self->labels,
    });
    return $self;
}

sub delete {
    my ($self) = @_;
    croak "Cannot delete zone without ID" unless $self->id;

    $self->_client->delete("/zones/" . $self->id);
    return 1;
}

sub rrsets {
    my ($self) = @_;
    croak "Cannot get rrsets without zone ID" unless $self->id;

    return WWW::Hetzner::Cloud::API::RRSets->new(
        client  => $self->_client,
        zone_id => $self->id,
    );
}

sub export {
    my ($self) = @_;
    croak "Cannot export zone without ID" unless $self->id;

    return $self->_client->get("/zones/" . $self->id . "/export");
}

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

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud::Zone - Hetzner Cloud DNS Zone object

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

=head1 ATTRIBUTES

=head2 id

Zone ID (read-only).

=head2 name

Zone name / domain (read-write).

=head2 status

Zone status: verified, pending, failed (read-only).

=head2 ttl

Default TTL for records (read-write).

=head2 created

Creation timestamp (read-only).

=head2 ns

Nameservers arrayref (read-only).

=head2 records_count

Number of records in the zone (read-only).

=head2 is_secondary_dns

Whether this is a secondary DNS zone (read-only).

=head2 labels

Labels hash (read-write).

=head1 METHODS

=head2 update

    $zone->name('newdomain.com');
    $zone->update;

Saves changes to name and labels back to the API.

=head2 delete

    $zone->delete;

Deletes the zone and all its records.

=head2 rrsets

    my $rrsets = $zone->rrsets;

Returns a L<WWW::Hetzner::Cloud::API::RRSets> object for managing DNS records.

=head2 export

    my $zonefile = $zone->export;

Exports the zone as a standard zone file format.

=head2 data

    my $hashref = $zone->data;

Returns all zone data as a hashref (for JSON serialization).

=cut
