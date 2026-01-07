# WWW-Hetzner

Perl client for Hetzner APIs (Cloud, Storage, Robot).

## Installation

```bash
cpanm WWW::Hetzner
```

## Usage

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
);
$server->power_on;
$server->delete;

# DNS Zones
my $zones = $cloud->zones->list;
my $zone = $cloud->zones->create(name => 'example.com');

# DNS Records
$zone->rrsets->add_a('www', '203.0.113.10');
$zone->rrsets->add_cname('blog', 'www.example.com.');
$zone->rrsets->add_mx('@', 'mail.example.com.', 10);

# SSH Keys
my $key = $cloud->ssh_keys->create(
    name       => 'my-key',
    public_key => 'ssh-ed25519 AAAA...',
);
```

## CLI

```bash
export HETZNER_API_TOKEN=your-token

hcloud.pl servers list
hcloud.pl servers create --name test --type cx22 --image debian-12
hcloud.pl zones list
hcloud.pl ssh-keys list
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

# Or with Log::Dispatch
use Log::Any::Adapter ('Dispatch', dispatcher => $dispatcher);
```

Log levels: `debug` (requests/responses), `info` (successful calls), `error` (API errors).

## Hetzner APIs

| API | Base URL | Resources |
|-----|----------|-----------|
| Cloud API | api.hetzner.cloud | Servers, DNS, Volumes, Networks, Firewalls, Load Balancers |
| Hetzner API | api.hetzner.com | Storage Boxes |
| Robot API | robot-ws.your-server.de | Dedicated Servers, vSwitches |

**Note:** The old standalone DNS API (dns.hetzner.com) no longer exists. DNS is now part of the Cloud API.

## License

This is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
