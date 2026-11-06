---
name: perl-www-hetzner
description: Use when calling WWW::Hetzner from another project — Cloud servers, ssh_keys->ensure, locations, server_types, wait_for_status, list_by_label, API errors, mock IO.
---

# WWW::Hetzner — calling it

Synchronous Perl client (Moo) for Hetzner. Pin **WWW::Hetzner 0.102** or later when you read
`ServerType->locations`. Changing the dist itself is `www-hetzner-core`; Hetzner platform
knowledge (networks, firewalls, IPs, costs) is `hetzner-operator@getty`.

## Which class

| API | Class | Auth |
|---|---|---|
| Cloud (servers, ssh keys, volumes, networks, DNS zones, ...) | `WWW::Hetzner::Cloud` | `token`, default `$ENV{HETZNER_API_TOKEN}` |
| Robot (dedicated servers) | `WWW::Hetzner::Robot` | `user` / `password`, defaults `HETZNER_ROBOT_USER` / `HETZNER_ROBOT_PASSWORD` |
| Storage Boxes (`api.hetzner.com`) | `WWW::Hetzner::Storage` | `token`, default `HETZNER_API_TOKEN` |

```perl
use WWW::Hetzner::Cloud;
my $cloud = WWW::Hetzner::Cloud->new( token => $token );   # lazy controllers: ->servers ->ssh_keys ->locations ...
```

Construction never checks the token; the first request dies without one (see Errors).

## Servers

```perl
my $s = $cloud->servers->create(
    name        => 'node1',            # name, server_type, image are required (croak "name required" ...)
    server_type => 'cx32',
    image       => 'debian-13',
    location    => 'fsn1',             # optional; omit and Hetzner chooses
    ssh_keys    => ['my-key'],         # names or ids; none = a server nobody can log in to
    labels      => { 'app' => 'x' },
    user_data   => $cloud_init,        # optional
);                                      # -> Server object, status 'initializing'
$s = $cloud->servers->wait_for_status( $s->id, 'running', 180 );   # -> fresh Server
my $found = $cloud->servers->list_all( label_selector => 'app=x,role=web' );   # arrayref
my $one   = $cloud->servers->get($id);                 # dies if absent, never undef
my $act   = $cloud->servers->delete($id);              # -> WWW::Hetzner::Action
$act->wait( interval => 2, timeout => 120 );           # optional: block until the server is gone
```

- `list`, `list_by_label` fetch **one page** (the API's default page size); `list_all(%filters)` follows
  every page. Use `list_all( label_selector => ... )` wherever completeness matters (orphan sweeps,
  idempotency lookups), or pass `per_page`. Filters: `label_selector`, `name`, `status`, `sort`.
- Label selectors use Hetzner syntax: `k=v`, comma means AND.
- `wait_for_status($id, $status, $timeout=120)` re-reads the server every 2 s on the wall clock
  (plain `sleep`, not injectable) and returns the Server that matched. It dies with
  `Timeout waiting for server <id> to reach status '<status>'` after `$timeout`; a timeout of 0 dies
  without any request.
- To wait on the create itself instead, use `$server->action->wait` (also `next_actions`).
  `Action->wait` polls through the client's injectable `sleeper`: `$cloud->sleeper( sub {} )` makes it instant in tests.
  It dies on `error` status: `Action <id> (<command>) failed: <API message>`.
- `servers->delete` returns at once; the deletion runs on. Mutating calls return an `Action`
  (`power_on`, `power_off`, `reboot`, `shutdown`, `rebuild`, `change_type`); `create` and `get` return a Server.

### Server accessors

`id name status labels created locked backup_window`, `ipv4` / `ipv6` (undef without a public
address), `server_type`, `location`, `datacenter`, `image` (each the **name string**, so
`$s->server_type->{name}` dies under strict refs; raw hashes are `server_type_data`,
`location_data`), `is_running`, `is_off`, `refresh` (re-reads status, name, labels only),
`delete`, `update` (saves `name` and `labels`), `data`. `status` is a snapshot: call `refresh`
or `wait_for_status` to move on. `labels` is a plain hashref.

## SSH keys

`$cloud->ssh_keys->ensure($name, $pubkey)` -> SSHKey (`id name public_key fingerprint`).
It looks the key up **by name** (`get_by_name`, undef when absent), then:
absent -> create; same content (trailing whitespace ignored) -> return the existing one;
different content -> **delete and recreate** under the same name, so the id changes.
Nothing looks at the fingerprint, so a key with identical content stored under another name goes to
`create`, and Hetzner's rejection surfaces as a `Hetzner API error`. Pass the whole public key line;
a changed comment counts as different content.

## Locations and server types

```perl
my $locs  = $cloud->locations->list_all;                   # name city country network_zone description
my $types = $cloud->server_types->list_all;                # name cores memory(GB) disk(GB) cpu_type architecture
my ($t) = grep { $_->name eq 'cx32' } @$types;             # or ->get_by_name('cx32')
my @here = grep { $_->{name} eq 'fsn1' && $_->{available} && !$_->{deprecation} } @{ $t->locations };
```

- `architecture` is `x86` or `arm`; `cpu_type` is `shared` or `dedicated`.
- `ServerType->locations` is an arrayref of `{ id, name, deprecation, recommended, available }`, one per
  location the type is offered in. Decide "orderable in L" from that entry. `available` false means
  ordering there fails at create time.
- Test the per-location `deprecation`. `ServerType->deprecated` is true only when the type is
  deprecated in every location, so it does not tell whether L is fine.
- `locations->list` and `server_types->list` are single pages too; the catalogue can exceed one page. Use `list_all`.
- `datacenters` is dead (every call dies with API error 410 Gone); use `locations`.

## Errors

API errors are `WWW::Hetzner::Error` objects (`status`, `code`, `api_message`, `message`) that
stringify to `Hetzner API error: ...`. Every other error (no token, missing argument, action,
pagination) stays a plain string via `croak`.

| Situation | Message starts with |
|---|---|
| no token (first request) | `No Cloud API token configured.` |
| missing argument | `Server ID required`, `name required`, `server_type required`, `image required`, `Name required` |
| any non-2xx (404, 422, ...) | `Hetzner API error: <error.message> (<status> <code>)`; `(<status>)` without a code |
| non-2xx without API message | `Hetzner API error: 429 rate_limit_exceeded`, or for a non-JSON body (proxy 502) `Hetzner API error: 502 <tag-stripped body text>`; `<status>` alone for an empty body |
| transport failure (DNS, refused, TLS, timeout) | `Hetzner API error: <LWP reason> (500 transport_error)` |
| action failed / timed out | `Action <id> (<command>) failed: ...` / `Timed out waiting for action ...` |

Read status and code off the object: `blessed $@ && $@->isa('WWW::Hetzner::Error') && $@->status == 404`
(`$@->code` is Hetzner's `error.code` or undef). The text quotes nothing from the request, and a
credential echoed by the response body reads `********`. A caller that
needs "does it exist" semantics wraps `get` in `eval` and tests `status == 404`, or looks the thing up with
`list_all( name => ... )` (servers) or `get_by_name` (ssh_keys, locations, server_types, images), which
return empty/undef instead of dying.
Default HTTP timeout is 30 s per request: `io => WWW::Hetzner::LWPIO->new( timeout => 60 )`.

## Tests without network

All HTTP passes through `io`, an object doing `WWW::Hetzner::Role::IO` (`call($req)` ->
`WWW::Hetzner::HTTPResponse`). The dist's own `Test::WWW::Hetzner::Mock` lives in its `t/lib` and is not
installed, so write a small IO class in your tests (or fake the `cloud` object at your own seam):

```perl
package My::FakeIO;  use Moo;  with 'WWW::Hetzner::Role::IO';
use JSON::MaybeXS qw(encode_json);  use WWW::Hetzner::HTTPResponse;
has routes => ( is => 'ro', default => sub { {} } );     # "GET /servers/5" => hashref | coderef
sub call {
    my ( $self, $req ) = @_;
    ( my $path = $req->url ) =~ s{^https://api\.hetzner\.cloud/v1}{};
    my ($p) = split /\?/, $path;                         # the query string is part of ->url
    my $r = $self->routes->{ $req->method . " $p" } or die "no route: " . $req->method . " $p";
    $r = $r->($req) if ref $r eq 'CODE';
    return $r if ref $r eq 'WWW::Hetzner::HTTPResponse';
    return WWW::Hetzner::HTTPResponse->new( status => 200, content => encode_json($r) );
}
my $cloud = WWW::Hetzner::Cloud->new( token => 't', io => My::FakeIO->new( routes => {...} ), sleeper => sub {} );
```

Response shapes mirror the Hetzner API: `{ servers => [...], meta => {...} }`, `{ server => {...}, action => {...} }`,
`{ ssh_keys => [...] }`, `{ locations => [...] }`, `{ server_types => [...] }`.

- A server needs `public_net => { ipv4 => { ip => ... } }` for `->ipv4`; `server_type`, `location`, `image` are `{ name => ... }` hashes.
- Honour the `name` and `label_selector` query params in a fake: `ssh_keys->get_by_name` trusts the server-side `name`
  filter and takes the first element of the answer.
- Paging: `list_all` follows `meta.pagination.next_page` and croaks on a cyclical or non-advancing value and on a `meta` without `pagination`; omit `meta` for a single page.
- Error responses: `HTTPResponse->new( status => 404, content => encode_json({ error => { code => 'not_found', message => '...' } }) )`.
- `wait_for_status` sleeps a real 2 s on every non-matching poll; script a fake whose first answer already matches.
