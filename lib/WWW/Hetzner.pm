package WWW::Hetzner;

# ABSTRACT: Perl client for Hetzner APIs (Cloud, Storage, Robot)

use Moo;
use WWW::Hetzner::Cloud;
use namespace::clean;

our $VERSION = '0.001';

has cloud => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud->new },
);

# TODO: Storage and Robot APIs not yet implemented
# has storage => (
#     is      => 'lazy',
#     builder => sub { WWW::Hetzner::Storage->new },
# );
#
# has robot => (
#     is      => 'lazy',
#     builder => sub { WWW::Hetzner::Robot->new },
# );

1;

__END__

=head1 NAME

WWW::Hetzner - Perl client for Hetzner APIs (Cloud, Storage, Robot)

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(
        token => $ENV{HETZNER_API_TOKEN},
    );

    # Servers
    my $servers = $cloud->servers->list;
    my $server = $cloud->servers->create(
        name        => 'my-server',
        server_type => 'cx22',
        image       => 'debian-12',
    );

    # DNS
    my $zones = $cloud->zones->list;
    my $zone = $cloud->zones->create(name => 'example.com');
    $zone->rrsets->add_a('www', '1.2.3.4');

=head1 HETZNER APIs

=over 4

=item * B<Cloud API> (L<WWW::Hetzner::Cloud>) - api.hetzner.cloud

=item * B<Hetzner API> - api.hetzner.com (Storage Boxes, not yet implemented)

=item * B<Robot API> - robot-ws.your-server.de (Dedicated servers, not yet implemented)

=back

B<Note:> The old standalone DNS API (dns.hetzner.com) no longer exists.
DNS is now part of the Cloud API.

=head1 CLOUD API CLASSES

=head2 Main Client

=over 4

=item * L<WWW::Hetzner::Cloud> - Main client class

=back

=head2 API Classes (Controllers)

=over 4

=item * L<WWW::Hetzner::Cloud::API::Servers> - Server management

=item * L<WWW::Hetzner::Cloud::API::SSHKeys> - SSH key management

=item * L<WWW::Hetzner::Cloud::API::Zones> - DNS zone management

=item * L<WWW::Hetzner::Cloud::API::RRSets> - DNS record management

=item * L<WWW::Hetzner::Cloud::API::Images> - OS images (read-only)

=item * L<WWW::Hetzner::Cloud::API::ServerTypes> - Server types (read-only)

=item * L<WWW::Hetzner::Cloud::API::Locations> - Locations (read-only)

=item * L<WWW::Hetzner::Cloud::API::Datacenters> - Datacenters (read-only)

=back

=head2 Entity Classes (Models)

=over 4

=item * L<WWW::Hetzner::Cloud::Server> - Server object

=item * L<WWW::Hetzner::Cloud::SSHKey> - SSH key object

=item * L<WWW::Hetzner::Cloud::Zone> - DNS zone object

=item * L<WWW::Hetzner::Cloud::RRSet> - DNS record object

=item * L<WWW::Hetzner::Cloud::Image> - Image object

=item * L<WWW::Hetzner::Cloud::ServerType> - Server type object

=item * L<WWW::Hetzner::Cloud::Location> - Location object

=item * L<WWW::Hetzner::Cloud::Datacenter> - Datacenter object

=back

=head1 SERVERS API

    $cloud->servers->list
    $cloud->servers->list_by_label($selector)
    $cloud->servers->get($id)
    $cloud->servers->create(%params)
    $cloud->servers->update($id, %params)
    $cloud->servers->delete($id)
    $cloud->servers->power_on($id)
    $cloud->servers->power_off($id)
    $cloud->servers->shutdown($id)
    $cloud->servers->reboot($id)
    $cloud->servers->rebuild($id, $image)
    $cloud->servers->change_type($id, $type, %opts)
    $cloud->servers->wait_for_status($id, $status, $timeout)

Server objects:

    $server->id
    $server->name
    $server->status
    $server->ipv4
    $server->ipv6
    $server->server_type
    $server->datacenter
    $server->image
    $server->labels
    $server->is_running
    $server->update
    $server->delete
    $server->power_on
    $server->shutdown
    $server->reboot
    $server->rebuild($image)
    $server->refresh

=head1 SSH KEYS API

    $cloud->ssh_keys->list
    $cloud->ssh_keys->get($id)
    $cloud->ssh_keys->create(%params)
    $cloud->ssh_keys->update($id, %params)
    $cloud->ssh_keys->delete($id)

SSH key objects:

    $key->id
    $key->name
    $key->public_key
    $key->fingerprint
    $key->labels
    $key->update
    $key->delete

=head1 DNS ZONES API

    $cloud->zones->list
    $cloud->zones->list_by_label($selector)
    $cloud->zones->get($id)
    $cloud->zones->create(%params)
    $cloud->zones->update($id, %params)
    $cloud->zones->delete($id)
    $cloud->zones->export($id)
    $cloud->zones->rrsets($zone_id)

Zone objects:

    $zone->id
    $zone->name
    $zone->ttl
    $zone->labels
    $zone->rrsets
    $zone->update
    $zone->delete
    $zone->export

=head1 DNS RECORDS API

    $zone->rrsets->list
    $zone->rrsets->get($name, $type)
    $zone->rrsets->create(%params)
    $zone->rrsets->update($name, $type, %params)
    $zone->rrsets->delete($name, $type)
    $zone->rrsets->add_a($name, $ip, %opts)
    $zone->rrsets->add_aaaa($name, $ip, %opts)
    $zone->rrsets->add_cname($name, $target, %opts)
    $zone->rrsets->add_mx($name, $mailserver, $priority, %opts)
    $zone->rrsets->add_txt($name, $value, %opts)

RRSet objects:

    $record->name
    $record->type
    $record->ttl
    $record->records
    $record->values
    $record->update
    $record->delete

=head1 READ-ONLY APIs

    # Images
    $cloud->images->list
    $cloud->images->get($id)

    # Server Types
    $cloud->server_types->list
    $cloud->server_types->get($id)

    # Locations
    $cloud->locations->list
    $cloud->locations->get($id)

    # Datacenters
    $cloud->datacenters->list
    $cloud->datacenters->get($id)

=head1 LOGGING

Uses L<Log::Any> for flexible logging. See L<WWW::Hetzner::Cloud/LOGGING>.

    use Log::Any::Adapter ('Stderr', log_level => 'debug');

=head1 CLI

1:1 replica of the official C<hcloud> CLI from Hetzner:

    hcloud.pl servers list
    hcloud.pl servers create --name test --type cx22 --image debian-12
    hcloud.pl zones list
    hcloud.pl ssh-keys list

See L<WWW::Hetzner::CLI>.

=head1 SEE ALSO

=over 4

=item * L<https://docs.hetzner.cloud/> - Cloud API documentation

=item * L<https://docs.hetzner.com/> - Hetzner API documentation

=item * L<https://robot.hetzner.com/doc/webservice/en.html> - Robot API documentation

=back

=cut
