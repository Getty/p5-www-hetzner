# WWW-Hetzner

[![CPAN Version](https://img.shields.io/cpan/v/WWW-Hetzner.svg)](https://metacpan.org/pod/WWW::Hetzner)
[![License](https://img.shields.io/cpan/l/WWW-Hetzner.svg)](https://metacpan.org/pod/WWW::Hetzner)

Perl client for Hetzner APIs (Cloud and Robot).

## Installation

```bash
cpanm WWW::Hetzner
```

## Cloud API

```perl
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
    location    => 'fsn1',
    ssh_keys    => ['my-key'],
);
$server->power_off;
$server->power_on;
$server->reboot;
$server->delete;

# Volumes
my $volume = $cloud->volumes->create(
    name     => 'data',
    size     => 50,
    location => 'fsn1',
);
$cloud->volumes->attach($volume->id, server => $server->id);
$cloud->volumes->resize($volume->id, size => 100);

# Networks
my $network = $cloud->networks->create(
    name     => 'my-network',
    ip_range => '10.0.0.0/8',
);
$cloud->networks->add_subnet($network->id,
    ip_range     => '10.0.1.0/24',
    type         => 'cloud',
    network_zone => 'eu-central',
);

# Firewalls
my $firewall = $cloud->firewalls->create(name => 'web-fw');
$cloud->firewalls->set_rules($firewall->id, [
    { direction => 'in', protocol => 'tcp', port => '80', source_ips => ['0.0.0.0/0'] },
    { direction => 'in', protocol => 'tcp', port => '443', source_ips => ['0.0.0.0/0'] },
]);

# Floating IPs
my $ip = $cloud->floating_ips->create(type => 'ipv4', home_location => 'fsn1');
$cloud->floating_ips->assign($ip->id, server => $server->id);

# Load Balancers
my $lb = $cloud->load_balancers->create(
    name              => 'my-lb',
    load_balancer_type => 'lb11',
    location          => 'fsn1',
);

# DNS Zones
my $zone = $cloud->zones->create(name => 'example.com');
$zone->rrsets->add_a('www', '203.0.113.10');
$zone->rrsets->add_cname('blog', 'www.example.com.');
$zone->rrsets->add_mx('@', 'mail.example.com.', 10);

# SSH Keys
my $key = $cloud->ssh_keys->create(
    name       => 'my-key',
    public_key => 'ssh-ed25519 AAAA...',
);
```

## Robot API (Dedicated Servers)

```perl
use WWW::Hetzner::Robot;

my $robot = WWW::Hetzner::Robot->new(
    user     => $ENV{HETZNER_ROBOT_USER},
    password => $ENV{HETZNER_ROBOT_PASSWORD},
);

# Dedicated servers
my $servers = $robot->servers->list;
my $server = $robot->servers->get(123456);
print $server->server_name, " - ", $server->product, "\n";

# SSH Keys
my $keys = $robot->keys->list;
$robot->keys->create(name => 'my-key', data => 'ssh-ed25519 AAAA...');

# IPs
my $ips = $robot->ips->list;

# Server reset
$robot->reset->software(123456);  # CTRL+ALT+DEL
$robot->reset->hardware(123456);  # Power cycle
$robot->reset->wol(123456);       # Wake-on-LAN

# Boot configuration (rescue system, Linux/VNC/Windows installation)
my $boot = $robot->boot->get(123456);
my $rescue = $robot->boot->enable_rescue(123456, os => 'linux');
print $rescue->{password}, "\n";  # only in the activating response
$robot->boot->enable_linux(123456, dist => 'Debian 12 minimal', lang => 'en');
$robot->boot->disable_rescue(123456);

# Reverse DNS
my $entries = $robot->rdns->list;
$robot->rdns->update('203.0.113.50', 'mail.example.com');
$robot->rdns->delete('203.0.113.50');

# Failover IPs
my $failovers = $robot->failover->list;
$robot->failover->switch('203.0.113.60', '198.51.100.10');
$robot->failover->delete('203.0.113.60');  # drops the routing, not the IP

# Traffic statistics
my $traffic = $robot->traffic->query(
    ip   => '1.2.3.4',
    from => '2024-01-01',
    to   => '2024-01-31',
);
```

## CLI Tools

### hcloud.pl (Cloud)

```bash
export HETZNER_API_TOKEN=your-token

# Servers
hcloud.pl server list
hcloud.pl server create --name test --type cx22 --image debian-12
hcloud.pl server describe 12345
hcloud.pl server poweron 12345
hcloud.pl server poweroff 12345
hcloud.pl server delete 12345

# Volumes
hcloud.pl volume list
hcloud.pl volume create --name data --size 50 --location fsn1
hcloud.pl volume attach 12345 --server 67890
hcloud.pl volume resize 12345 --size 100

# Networks
hcloud.pl network list
hcloud.pl network create --name mynet --ip-range 10.0.0.0/8
hcloud.pl network add-subnet 12345 --ip-range 10.0.1.0/24 --type cloud --network-zone eu-central

# Firewalls
hcloud.pl firewall list
hcloud.pl firewall create --name web-fw
hcloud.pl firewall add-rule 12345 --direction in --protocol tcp --port 80

# Floating IPs
hcloud.pl floating-ip list
hcloud.pl floating-ip create --type ipv4 --home-location fsn1
hcloud.pl floating-ip assign 12345 --server 67890

# Primary IPs
hcloud.pl primary-ip list

# Load Balancers
hcloud.pl load-balancer list
hcloud.pl load-balancer create --name lb --type lb11 --location fsn1
hcloud.pl load-balancer-type

# Placement Groups
hcloud.pl placement-group list
hcloud.pl placement-group create --name spread --type spread

# Certificates
hcloud.pl certificate list

# DNS
hcloud.pl zone list
hcloud.pl record list --zone example.com

# Info
hcloud.pl servertype list
hcloud.pl image list
hcloud.pl iso
hcloud.pl iso --architecture arm
hcloud.pl location list
hcloud.pl datacenter list
hcloud.pl sshkey list
hcloud.pl pricing

# JSON output
hcloud.pl -o json server list
```

### hrobot.pl (Robot)

```bash
export HETZNER_ROBOT_USER=your-user
export HETZNER_ROBOT_PASSWORD=your-password

hrobot.pl server list
hrobot.pl server describe 123456
hrobot.pl key list
hrobot.pl reset 123456 --type sw
hrobot.pl wol 123456
hrobot.pl traffic query --ip 1.2.3.4 --from 2024-01-01

hrobot.pl boot 123456
hrobot.pl boot rescue 123456 --enable --os linux
hrobot.pl boot linux 123456 --enable --dist 'Debian 12 minimal' --lang en

hrobot.pl rdns
hrobot.pl rdns 203.0.113.50 --ptr mail.example.com

hrobot.pl failover
hrobot.pl failover 203.0.113.60 --to 198.51.100.10
```

## Cloud API Resources

| Resource | API Methods |
|----------|-------------|
| Servers | list, get, create, delete, power_on, power_off, shutdown, reboot, reset, rebuild, rescue |
| Volumes | list, get, create, delete, attach, detach, resize |
| Networks | list, get, create, update, delete, add_subnet, delete_subnet, add_route, delete_route |
| Firewalls | list, get, create, update, delete, set_rules, apply_to_resources, remove_from_resources |
| Floating IPs | list, get, create, delete, assign, unassign |
| Primary IPs | list, get, create, delete, assign, unassign |
| Load Balancers | list, get, create, delete, add_target, add_service |
| Load Balancer Types | list, get, get_by_name |
| Certificates | list, get, create, delete |
| Placement Groups | list, get, create, update, delete |
| SSH Keys | list, get, get_by_name, create, update, delete, ensure |
| DNS Zones | list, get, create, update, delete, export |
| DNS Records | add_a, add_aaaa, add_cname, add_mx, add_txt |
| Server Types | list, get, get_by_name |
| Images | list, get, get_by_name |
| ISOs | list, get, get_by_name |
| Locations | list, get, get_by_name |
| Datacenters | list, get, get_by_name |
| Pricing | get |

## Async Support

For non-blocking IO::Async integration, see
[Net::Async::Hetzner](https://metacpan.org/pod/Net::Async::Hetzner):

```perl
use IO::Async::Loop;
use Net::Async::Hetzner::Cloud;

my $loop = IO::Async::Loop->new;
my $cloud = Net::Async::Hetzner::Cloud->new(token => $ENV{HETZNER_API_TOKEN});
$loop->add($cloud);

my $data = $cloud->get('/servers')->get;  # Future-based
```

## Custom HTTP Backend

HTTP transport is pluggable via `WWW::Hetzner::Role::IO`. The default backend
is `WWW::Hetzner::LWPIO` (synchronous, LWP::UserAgent). You can swap it for
custom backends:

```perl
my $cloud = WWW::Hetzner::Cloud->new(
    token => $ENV{HETZNER_API_TOKEN},
    io    => My::CustomIO->new,
);
```

A custom backend implements `WWW::Hetzner::Role::IO` and its `call` method:

```perl
package My::CustomIO;
use Moo;
with 'WWW::Hetzner::Role::IO';

sub call {
    my ($self, $req) = @_;
    # $req->method, $req->url, $req->headers, $req->content
    # ... execute HTTP request ...
    return WWW::Hetzner::HTTPResponse->new(status => $status, content => $body);
}
```

## Logging

Uses [Log::Any](https://metacpan.org/pod/Log::Any) for flexible logging integration.

```perl
# Enable logging to STDERR
use Log::Any::Adapter ('Stderr', log_level => 'debug');

# Or to a file
use Log::Any::Adapter ('File', '/var/log/hetzner.log');

# Or integrate with Log::Log4perl
use Log::Any::Adapter ('Log4perl');
```

Log levels: `debug` (requests/responses), `info` (successful calls), `error` (API errors).

### HTTP Debugging

For full HTTP request/response dumps (headers, bodies, status), use
[LWP::ConsoleLogger::Everywhere](https://metacpan.org/pod/LWP::ConsoleLogger::Everywhere):

```bash
perl -MLWP::ConsoleLogger::Everywhere your_script.pl
```

## Hetzner APIs

| API | Base URL | Purpose |
|-----|----------|---------|
| Cloud API | api.hetzner.cloud | Cloud Servers, Volumes, Networks, DNS, Load Balancers |
| Robot API | robot-ws.your-server.de | Dedicated Servers, IPs, Reset, Boot Configuration, Reverse DNS, Failover IPs |

**Note:** The old standalone DNS API (dns.hetzner.com) no longer exists. DNS is now part of the Cloud API.

## Development

```bash
# Run tests
prove -l t/

# Run integration tests (requires API token)
HETZNER_TEST_TOKEN=xxx prove -lv t/integration_cloud.t

# Build
dzil build

# Release
dzil release
```

## License

This is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

## Author

Torsten Raudssus <torsten@raudssus.de> ([GETTY](https://metacpan.org/author/GETTY))
