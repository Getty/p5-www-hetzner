package WWW::Hetzner::Cloud::API::RRSets;
# ABSTRACT: Hetzner Cloud DNS RRSets (Records) API

our $VERSION = '0.003';

use Moo;
use Carp qw(croak);
use WWW::Hetzner::Cloud::RRSet;
use namespace::clean;

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});

    # Get RRSets object for a zone
    my $rrsets = $cloud->zones->rrsets($zone_id);

    # Or from a Zone object
    my $zone = $cloud->zones->get($zone_id);
    my $rrsets = $zone->rrsets;

    # List all records
    my $records = $rrsets->list;
    my $records = $rrsets->list(type => 'A');

    # Get specific record
    my $record = $rrsets->get('www', 'A');
    printf "Record: %s -> %s\n", $record->name, $record->records->[0]{value};

    # Create records
    my $record = $rrsets->create(
        name    => 'www',
        type    => 'A',
        ttl     => 300,
        records => [{ value => '203.0.113.10' }],
    );

    # Convenience methods
    $rrsets->add_a('www', '203.0.113.10', ttl => 300);
    $rrsets->add_aaaa('www', '2001:db8::1');
    $rrsets->add_cname('blog', 'www.example.com.');
    $rrsets->add_mx('@', 'mail.example.com.', 10);
    $rrsets->add_txt('@', 'v=spf1 include:_spf.example.com ~all');

    # Update record
    $rrsets->update('www', 'A', records => [{ value => '203.0.113.20' }]);

    # Delete record
    $rrsets->delete('www', 'A');

=head1 DESCRIPTION

This module provides access to DNS RRSets (Resource Record Sets) within a zone.
RRSets are groups of DNS records with the same name and type.
All methods return L<WWW::Hetzner::Cloud::RRSet> objects.

=cut

has client => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

has zone_id => (
    is       => 'ro',
    required => 1,
);

sub _wrap {
    my ($self, $data) = @_;
    return WWW::Hetzner::Cloud::RRSet->new(
        client  => $self->client,
        zone_id => $self->zone_id,
        %$data,
    );
}

sub _wrap_list {
    my ($self, $list) = @_;
    return [ map { $self->_wrap($_) } @$list ];
}

sub _base_path {
    my ($self) = @_;
    return "/zones/" . $self->zone_id . "/rrsets";
}

=method list

    my $records = $rrsets->list;
    my $records = $rrsets->list(type => 'A', name => 'www');

Returns an arrayref of L<WWW::Hetzner::Cloud::RRSet> objects.
Optional parameters: name, type, sort, page, per_page.

=cut

sub list {
    my ($self, %params) = @_;

    my $result = $self->client->get($self->_base_path, params => \%params);
    return $self->_wrap_list($result->{rrsets} // []);
}

=method get

    my $record = $rrsets->get($name, $type);
    my $record = $rrsets->get('www', 'A');

Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub get {
    my ($self, $name, $type) = @_;
    croak "Record name required" unless $name;
    croak "Record type required" unless $type;

    my $path = $self->_base_path . "/$name/$type";
    my $result = $self->client->get($path);
    return $self->_wrap($result->{rrset});
}

=method create

    my $record = $rrsets->create(
        name    => 'www',           # required
        type    => 'A',             # required
        records => [{ value => '1.2.3.4' }],  # required
        ttl     => 300,             # optional
    );

Creates a new RRSet. Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub create {
    my ($self, %params) = @_;

    croak "name required" unless $params{name};
    croak "type required" unless $params{type};
    croak "records required" unless $params{records};

    my $body = {
        name    => $params{name},
        type    => $params{type},
        records => $params{records},
    };

    $body->{ttl} = $params{ttl} if $params{ttl};

    my $result = $self->client->post($self->_base_path, $body);
    return $self->_wrap($result->{rrset});
}

=method update

    my $record = $rrsets->update('www', 'A',
        ttl     => 600,
        records => [{ value => '1.2.3.5' }],
    );

Updates an existing RRSet. Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub update {
    my ($self, $name, $type, %params) = @_;
    croak "Record name required" unless $name;
    croak "Record type required" unless $type;

    my $body = {};
    $body->{ttl}     = $params{ttl}     if exists $params{ttl};
    $body->{records} = $params{records} if exists $params{records};

    my $path = $self->_base_path . "/$name/$type";
    my $result = $self->client->put($path, $body);
    return $self->_wrap($result->{rrset});
}

=method delete

    $rrsets->delete('www', 'A');

Deletes an RRSet.

=cut

sub delete {
    my ($self, $name, $type) = @_;
    croak "Record name required" unless $name;
    croak "Record type required" unless $type;

    my $path = $self->_base_path . "/$name/$type";
    return $self->client->delete($path);
}

=method add_a

    my $record = $rrsets->add_a('www', '203.0.113.10', ttl => 300);

Creates an A record. Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub add_a {
    my ($self, $name, $ip, %opts) = @_;
    croak "name required" unless $name;
    croak "IP address required" unless $ip;

    return $self->create(
        name    => $name,
        type    => 'A',
        records => [{ value => $ip }],
        %opts,
    );
}

=method add_aaaa

    my $record = $rrsets->add_aaaa('www', '2001:db8::1', ttl => 300);

Creates an AAAA record. Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub add_aaaa {
    my ($self, $name, $ip, %opts) = @_;
    croak "name required" unless $name;
    croak "IPv6 address required" unless $ip;

    return $self->create(
        name    => $name,
        type    => 'AAAA',
        records => [{ value => $ip }],
        %opts,
    );
}

=method add_cname

    my $record = $rrsets->add_cname('blog', 'www.example.com.', ttl => 3600);

Creates a CNAME record. Target should end with a dot.
Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub add_cname {
    my ($self, $name, $target, %opts) = @_;
    croak "name required" unless $name;
    croak "target required" unless $target;

    return $self->create(
        name    => $name,
        type    => 'CNAME',
        records => [{ value => $target }],
        %opts,
    );
}

=method add_mx

    my $record = $rrsets->add_mx('@', 'mail.example.com.', 10, ttl => 3600);

Creates an MX record with priority.
Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub add_mx {
    my ($self, $name, $mailserver, $priority, %opts) = @_;
    croak "name required" unless $name;
    croak "mailserver required" unless $mailserver;
    $priority //= 10;

    return $self->create(
        name    => $name,
        type    => 'MX',
        records => [{ value => "$priority $mailserver" }],
        %opts,
    );
}

=method add_txt

    my $record = $rrsets->add_txt('@', 'v=spf1 include:_spf.example.com ~all');

Creates a TXT record. Returns a L<WWW::Hetzner::Cloud::RRSet> object.

=cut

sub add_txt {
    my ($self, $name, $value, %opts) = @_;
    croak "name required" unless $name;
    croak "value required" unless $value;

    return $self->create(
        name    => $name,
        type    => 'TXT',
        records => [{ value => $value }],
        %opts,
    );
}

=seealso

=over 4

=item * L<WWW::Hetzner::Cloud> - Main Cloud API client

=item * L<WWW::Hetzner::Cloud::RRSet> - RRSet entity class

=item * L<WWW::Hetzner::Cloud::API::Zones> - Zones API

=item * L<WWW::Hetzner::CLI::Cmd::Record> - Record CLI commands

=item * L<WWW::Hetzner> - Main umbrella module

=back

=cut

1;
