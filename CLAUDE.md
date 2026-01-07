# WWW-Hetzner

Perl client for Hetzner APIs (Cloud, Storage, Robot).

## Hetzner APIs

**Cloud API** (`api.hetzner.cloud`)
- Cloud Servers, Volumes, Networks, Firewalls, Load Balancers
- **DNS Zones und Records** - Die alte standalone DNS API (`dns.hetzner.com`) existiert nicht mehr! DNS ist jetzt Teil der Cloud API.

**Hetzner API** (`api.hetzner.com`)
- Offizieller Name, bietet aber aktuell nur Storage Box Funktionen

**Robot API** (`robot-ws.your-server.de`)
- Dedicated Servers, vSwitches

## Build & Test

```bash
dzil build          # Build distribution
dzil test           # Run all tests
prove -lv t/        # Run tests directly
```

## Structure

- `lib/WWW/Hetzner.pm` - Main entry point
- `lib/WWW/Hetzner/Cloud/` - Cloud API modules (Servers, Zones, SSHKeys, etc.)
- `lib/WWW/Hetzner/CLI/` - CLI commands for `bin/hcloud.pl`
- `t/` - Tests with mock fixtures in `t/fixtures/`

## Tech

- **Moo** for OOP
- **Dist::Zilla** with `[@Author::GETTY]`
