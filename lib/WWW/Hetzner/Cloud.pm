package WWW::Hetzner::Cloud;

# ABSTRACT: Perl client for Hetzner Cloud API

use Moo;
use WWW::Hetzner::Cloud::API::Servers;
use WWW::Hetzner::Cloud::API::ServerTypes;
use WWW::Hetzner::Cloud::API::Images;
use WWW::Hetzner::Cloud::API::SSHKeys;
use WWW::Hetzner::Cloud::API::Locations;
use WWW::Hetzner::Cloud::API::Datacenters;
use WWW::Hetzner::Cloud::API::Zones;
use WWW::Hetzner::Cloud::API::Volumes;
use WWW::Hetzner::Cloud::API::Networks;
use WWW::Hetzner::Cloud::API::Firewalls;
use WWW::Hetzner::Cloud::API::FloatingIPs;
use WWW::Hetzner::Cloud::API::PrimaryIPs;
use WWW::Hetzner::Cloud::API::LoadBalancers;
use WWW::Hetzner::Cloud::API::Certificates;
use WWW::Hetzner::Cloud::API::PlacementGroups;
use namespace::clean;

our $VERSION = '0.002';

has token => (
    is      => 'ro',
    default => sub { $ENV{HETZNER_API_TOKEN} },
);

sub _check_auth {
    my ($self) = @_;
    unless ($self->token) {
        die "No Cloud API token configured.\n\n" .
            "Set token via:\n" .
            "  Environment: HETZNER_API_TOKEN\n" .
            "  Option:      --token\n\n" .
            "Get token at: https://console.hetzner.cloud/ -> Select project -> Security -> API tokens\n";
    }
}

has base_url => (
    is      => 'ro',
    default => 'https://api.hetzner.cloud/v1',
);

with 'WWW::Hetzner::Role::HTTP';

around _request => sub {
    my ($orig, $self, @args) = @_;
    $self->_check_auth;
    return $self->$orig(@args);
};

# Resource accessors
has servers => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Servers->new(client => shift) },
);

has server_types => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::ServerTypes->new(client => shift) },
);

has images => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Images->new(client => shift) },
);

has ssh_keys => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::SSHKeys->new(client => shift) },
);

has locations => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Locations->new(client => shift) },
);

has datacenters => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Datacenters->new(client => shift) },
);

has zones => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Zones->new(client => shift) },
);

has volumes => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Volumes->new(client => shift) },
);

has networks => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Networks->new(client => shift) },
);

has firewalls => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Firewalls->new(client => shift) },
);

has floating_ips => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::FloatingIPs->new(client => shift) },
);

has primary_ips => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::PrimaryIPs->new(client => shift) },
);

has load_balancers => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::LoadBalancers->new(client => shift) },
);

has certificates => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::Certificates->new(client => shift) },
);

has placement_groups => (
    is      => 'lazy',
    builder => sub { WWW::Hetzner::Cloud::API::PlacementGroups->new(client => shift) },
);

1;

__END__

=head1 NAME

WWW::Hetzner::Cloud - Perl client for Hetzner Cloud API

=head1 SYNOPSIS

    use WWW::Hetzner::Cloud;

    my $cloud = WWW::Hetzner::Cloud->new(
        token => $ENV{HETZNER_API_TOKEN},
    );

    # List servers
    my $servers = $cloud->servers->list;

    # Create server
    my $server = $cloud->servers->create(
        name        => 'my-server',
        server_type => 'cx23',
        image       => 'debian-13',
        location    => 'fsn1',
        ssh_keys    => ['my-key'],
    );

    # Delete server
    $cloud->servers->delete($server->{id});

=head1 RESOURCES

=head2 Compute

=over 4

=item * servers - Cloud servers (create, delete, power on/off, reboot, rebuild, rescue)

=item * server_types - Available server types

=item * images - OS images

=item * ssh_keys - SSH keys

=item * placement_groups - Placement groups for server distribution

=back

=head2 Networking

=over 4

=item * networks - Private networks with subnets and routes

=item * firewalls - Firewall rules and application

=item * floating_ips - Reassignable public IPs

=item * primary_ips - Primary IPs for servers

=item * load_balancers - Load balancers with targets and services

=back

=head2 Storage

=over 4

=item * volumes - Block storage volumes

=back

=head2 DNS

=over 4

=item * zones - DNS zones and records

=back

=head2 Security

=over 4

=item * certificates - TLS certificates (managed or uploaded)

=back

=head2 Info

=over 4

=item * locations - Locations (fsn1, nbg1, hel1, ash, hil, sin)

=item * datacenters - Datacenters

=back

=head1 DNS EXAMPLE

    # List DNS zones
    my $zones = $cloud->zones->list;

    # Create a zone
    my $zone = $cloud->zones->create(name => 'example.com');

    # Add DNS records
    my $rrsets = $zone->rrsets;
    $rrsets->add_a('www', '203.0.113.10');
    $rrsets->add_cname('blog', 'www.example.com.');
    $rrsets->add_mx('@', 'mail.example.com.', 10);

=head1 LOGGING

WWW::Hetzner::Cloud uses L<Log::Any> for logging via L<WWW::Hetzner::Role::HTTP>.
This allows you to integrate with any logging framework of your choice.

=head2 Log Levels Used

=over 4

=item * B<debug> - Request URLs, bodies, response status

=item * B<info> - Successful API calls (method, path, status)

=item * B<error> - API errors before croak

=back

=head2 Enabling Logging

By default, logs are discarded. To see them, configure a Log::Any adapter:

    # Simple: output to STDERR
    use Log::Any::Adapter ('Stderr');

    # With minimum level
    use Log::Any::Adapter ('Stderr', log_level => 'debug');

    # To a file
    use Log::Any::Adapter ('File', '/var/log/hetzner.log');

    # Integration with Log::Log4perl
    use Log::Log4perl;
    Log::Log4perl->init('log4perl.conf');
    use Log::Any::Adapter ('Log4perl');

    # Integration with Log::Dispatch
    use Log::Dispatch;
    my $dispatcher = Log::Dispatch->new(...);
    use Log::Any::Adapter ('Dispatch', dispatcher => $dispatcher);

See L<Log::Any::Adapter> for all available adapters.

=head1 SEE ALSO

L<WWW::Hetzner>, L<WWW::Hetzner::Role::HTTP>

=cut
