package WWW::Hetzner::Cloud::API::Zones;
# ABSTRACT: Hetzner Cloud DNS Zones API

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::API::RRSets;
use WWW::Hetzner::Cloud::Zone;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # List all zones
    my $zones = $cloud->zones->list;

    # Create a zone
    my $zone = $cloud->zones->create(
        name   => 'example.com',
        ttl    => 3600,
        labels => { env => 'prod' },
    );

    # Zone is a WWW::Hetzner::Cloud::Zone object
    print $zone->id, "\n";
    print $zone->name, "\n";

    # Access RRSets directly from zone object
    my $records = $zone->rrsets->list;
    $zone->rrsets->add_a('www', '1.2.3.4');

    # Update zone
    $zone->name('newdomain.com');
    $zone->update;

    # Delete zone
    $zone->delete;

=head1 DESCRIPTION

This module provides the API for managing Hetzner Cloud DNS zones.
All methods return L<WWW::Hetzner::Cloud::Zone> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::Zone->new(
        client => $self->client,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

=method list

    my $zones = $cloud->zones->list;
    my $zones = $cloud->zones->list(name => 'example.com');
    my $zones = $cloud->zones->list(label_selector => 'env=prod');

Returns an arrayref of L<WWW::Hetzner::Cloud::Zone> objects.
Optional parameters: name, label_selector, sort, page, per_page.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get('/zones', params => \%params);
    return $self->_wrap_list($result->{zones} // []);
}

=method list_by_label

    my $zones = $cloud->zones->list_by_label('env=production');

Convenience method to list zones by label selector.

=cut

sub list_by_label {
    my ($self, $label_selector) = @_;
    return $self->list(label_selector => $label_selector);
}

=method get

    my $zone = $cloud->zones->get($id);

Returns a L<WWW::Hetzner::Cloud::Zone> object.

=cut

sub get {
    my ($self, $id) = @_;
    croak "Zone ID required" unless $id;

    my $result = $self->client->get("/zones/$id");
    return $self->_wrap($result->{zone});
}

=method create

    my $zone = $cloud->zones->create(
        name   => 'example.com',  # required
        ttl    => 3600,           # optional (default TTL)
        labels => { env => 'prod' },  # optional
    );

Creates a new DNS zone. Returns a L<WWW::Hetzner::Cloud::Zone> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};

    my $body = {
        name => $params{name},
    };

    $body->{labels} = $params{labels} if $params{labels};
    $body->{ttl}    = $params{ttl}    if $params{ttl};

    my $result = $self->client->post('/zones', $body);
    return $self->_wrap($result->{zone});
}

=method update

    $cloud->zones->update($id, name => 'newdomain.com', labels => { env => 'dev' });

Updates zone name or labels. Returns a L<WWW::Hetzner::Cloud::Zone> object.

=cut

sub update {
    my ($self, $id, %params) = @_;
    croak "Zone ID required" unless $id;

    my $body = {};
    $body->{name}   = $params{name}   if exists $params{name};
    $body->{labels} = $params{labels} if exists $params{labels};

    my $result = $self->client->put("/zones/$id", $body);
    return $self->_wrap($result->{zone});
}

=method delete

    $cloud->zones->delete($id);

Deletes a zone and all its RRSets.

=cut

sub delete {
    my ($self, $id) = @_;
    croak "Zone ID required" unless $id;

    return $self->client->delete("/zones/$id");
}

=method export

    my $zonefile = $cloud->zones->export($id);

Exports the zone as a standard zone file format.

=cut

sub export {
    my ($self, $id) = @_;
    croak "Zone ID required" unless $id;

    my $result = $self->client->get("/zones/$id/export");
    return $result;
}

=method rrsets

    my $rrsets = $cloud->zones->rrsets($zone_id);
    my $records = $rrsets->list;

Returns a L<WWW::Hetzner::Cloud::API::RRSets> object for managing records in this zone.

=cut

sub rrsets {
    my ($self, $zone_id) = @_;
    croak "Zone ID required" unless $zone_id;

    return WWW::Hetzner::Cloud::API::RRSets->new(
        client  => $self->client,
        zone_id => $zone_id,
    );
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::Zone> - Zone entity class

=item * L<WWW::Hetzner::Cloud::API::RRSets> - RRSets (DNS records) API

=item * L<WWW::Hetzner::CLI::Cmd::Zone> - Zone CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
