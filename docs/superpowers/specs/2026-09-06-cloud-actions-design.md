# Design: Cloud Actions

- Ticket: karr #2 (board `WWW-Hetzner`)
- Date: 2026-09-06
- Status: approved, implementation plan pending

## Problem

The Hetzner Cloud API answers every mutating call with an action —
an asynchronous operation with its own status. `WWW::Hetzner` currently throws this
information away or passes it through unprocessed:

- `Cloud/API/Servers.pm:208` returns only `$result->{server}`; `action` and
  `next_actions` get dropped.
- `Cloud/API/Servers.pm:234` and the remaining 37 action methods pass the raw
  decoded hashref `{action => {...}}` through.
- `Role/HTTP.pm:200` croaks only on HTTP status outside 2xx. A
  failed action, however, arrives as **HTTP 201 with `action.status ==
  "error"`** and so bypasses the error path entirely.

Consequence: a `create` whose action fails cannot be told apart from a successful
one. `CLI/Cmd/Server/Cmd/Poweron.pm:20` prints `"Server powered
on."` before the action has even started.

The only waiting is `wait_for_status` (`Cloud/API/Servers.pm:488`). It polls
the server status, not the action, exists only for servers and says nothing
about why an operation failed.

## Decisions

Four decisions, each with the reason that carried it.

### E1 — The library does not wait unasked

Mutating calls return an `Action` object and do not sleep. Whoever
wants to wait calls `->wait`.

Reason: a library that secretly sleeps in `create` is surprising, and
`wait_for_status` is the precedent for *deliberately requested* waiting.

Rejected alternative: blocking by default with `wait => 0` as opt-out. That
solves the error problem without any effort from the caller, but changes the
timing behavior of every existing call.

Explicitly **not** a deciding factor was the initially cited parity with
`p5-net-async-hetzner`. Checking showed: `Net::Async::Hetzner::Cloud`
does not implement `Role::IO`; it instantiates a
`WWW::Hetzner::Cloud` internally and borrows only `_build_request` and
`_parse_response` from it (`Net/Async/Hetzner/Cloud.pm:100` and `:103`). There are
neither controllers nor entities there — so no object shape that would need to be
kept in parity either.

### E2 — Blocking wait belongs in the CLI

`hcloud.pl` waits by default and offers `--no-wait`. That is where the user sits
who wants to see the result; the library stays honest.

### E3 — `create` keeps returning the entity

The entity carries the creating action as attribute `action`, the follow-up actions
as `next_actions`. Existing `create` calls do not break.

Rejected: a separate `Result` object with `->server`/`->action` (breaks every
`create` call across all resources) and a `wantarray` return
(context-dependent returns are a source of bugs you regret later).

### E4 — Injectable sleeper

The client gets a `sleeper` attribute, default `sub { sleep $_[0] }`. Tests
push a counting closure in.

Reason: interval **and** timeout paths become testable without a wall clock, and the
number of polls can be checked. A timeout test that needs real seconds is
a flaky test.

### E5 — Action methods with sidecar data: the action carries it

According to `cloud.spec.json`, five server action methods return payload *next to*
`action` that would be lost in a blanket switch to
verloren gingen:

| Method | Sidecar |
|---|---|
| `enable_rescue`, `rebuild`, `reset_password` | `root_password` |
| `request_console` | `password`, `wss_url` |
| `create_image` | `image` (endpoint not yet implemented in this distribution — gets `result` automatically once the controller method is added) |

Decision (maintainer, 2026-09-07): these methods keep returning an
`Action` that carries the sidecar fields. The `Action` gets an
attribute `result` (hashref, default `{}`) with the extra fields, plus typed
convenience readers (`root_password`, `image`, `wss_url`, `password`) that
read from `result` and return `undef` when the field is missing.

Reason: the uniform action return contract stays (every mutating call
returns an `Action`), nothing gets lost, and the sidecar data can be found on the
object. Rejected: a separate result object with `->action` (like
E3) — conceptually clean, but its own return shape per method and more code,
with no gain over the `result` attribute.

Consequence: the CLI commands that display this data (`server rescue`,
`reset-password`, `rebuild`, `create-image`) read it through the new accessor
(`$action->root_password` or `$action->result`). This also fixes karr #6.

## Architecture

### New classes

**`WWW::Hetzner::Cloud::Action`** — entity following the pattern of
`WWW::Hetzner::Cloud::Server`: `client` as `weak_ref`, plus the attributes
`id`, `command`, `status`, `progress`, `started`, `finished`, `resources`,
`error`.

| Method | Behavior |
|---|---|
| `is_running` / `is_success` / `is_error` | Status predicates |
| `error_message` | `error.message` or `undef` |
| `refresh` | Reload via `poll_path` |
| `wait(%opts)` | Polls until a final state |
| `data` | Raw data, as with the other entities |

`wait` takes `interval` (default 1) and `timeout` (default 120, consistent with
`wait_for_status`). It croaks on `status eq 'error'` with the API message and
on timeout with the action id and command.

**`WWW::Hetzner::Cloud::API::Actions`** — controller with `get($id)` and
`list(%params)`.

### The poll path

The `Action` receives its poll path from the creating controller as attribute
`poll_path`. `refresh` appends `/$id` to it.

The default is the global path `/actions` (clarified: not deprecated, see "Clarified
before implementation"). `poll_path` stays as an attribute anyway:
it turns the resource variant `/{resource}/actions/{id}` into one
line per controller instead of a rework, should it ever be needed.

### New roles

**`WWW::Hetzner::Cloud::Role::HasActions`** — provides `_wrap_action`, consumed
by the 8 controllers that create actions. Additive; the existing
`_wrap`/`_wrap_list` in the controllers stay untouched.

**`WWW::Hetzner::Cloud::Role::HasAction`** — gives entities the attributes
`action` and `next_actions`.

Consumed by **eight** entities whose `create` response, according to the official
`cloud.spec.json`, contains a singular `action`: `Certificate`, `FloatingIP`,
`LoadBalancer`, `PrimaryIP`, `Server`, `Volume`, `PlacementGroup`, `Zone`.

The earlier count of "exactly six" came from the existing fixtures, not
from the real contract: the `create` fixtures of `PlacementGroup` and `Zone`
are outdated and do not contain the action the real API returns. For
`PlacementGroup`, `action` is nullable (only a *managed* placement group triggers
one) — `HasAction` must handle the `undef` case. See "Clarified before
implementation".

`Firewall` is the special case: `create` returns **`actions` in the plural** (a
list), not a single `action`. `Firewall` therefore does **not** consume
`HasAction`; it gets its own attribute `actions` (arrayref of
`Action` objects). The wrap helper in `HasActions` covers both shapes.

Not consumed by `Network`, `RRSet`, `SSHKey` — according to the spec their `create` response
contains no action.

`action` is the state at creation time — a snapshot. It is
`ro` and is not touched by the entity's `->refresh`, so it stays as the
(then possibly outdated) creation snapshot. The POD says so.

(Correction 2026-09-07: the original draft said "`undef` after `->refresh`".
That was an unimplemented over-specification; a retained
snapshot is harmless and more useful than nulling it. The POD documents the
actual behavior.)

**`WWW::Hetzner::CLI::Role::WaitsForAction`** — provides the option `--no-wait`
and a `handle_action` helper. There is no CLI base class; every command
is standalone `MooX::Cmd` plus `MooX::Options`, and `MooX::Options` allows
providing options from a role.

### Sleeper

`sleeper` goes on `WWW::Hetzner::Role::HTTP`, not on `Cloud` —
additive, and `Robot` inherits it for the later `boot` polling from karr #4.

`is => 'rw'` with default `sub { sleep $_[0] }`, so tests can set it after construction
and `mock_cloud` does not have to be rebuilt.

## Affected code

| Location | Change | Scope |
|---|---|---|
| `Cloud/API/*.pm` | Action methods return `Action` instead of hashref | 38 methods, 8 files |
| `Cloud/*.pm` (entities) | mirrored action methods likewise | 28 methods, 8 files |
| `Cloud/*.pm` (entities) | consume `HasAction` (singular `action`) | 8 files |
| `Cloud/Firewall.pm` | `actions` attribute (plural list) | 1 file |
| `t/fixtures/*_create.json` | align outdated fixtures with the real API | placement_groups, zones, volumes |
| `Cloud.pm` | `actions` attribute for the new controller | 1 |
| `CLI/Cmd/**` | consume `WaitsForAction` | mutating subcommands |
| `Role/HTTP.pm` | `sleeper` attribute | 1 |
| `t/cloud_*.t` | `$result->{action}{command}` becomes `$result->action->command` | approx. 6 files |

`wait_for_status` stays unchanged; its POD additionally points to `->wait`.

### Breaking change

The 66 action methods return an `Action` object instead of `{action => {...}}`.
Acceptable at version 0.100, but it belongs in `Changes` as such.

The CLI is not affected: it discards the return values today
anyway (`CLI/Cmd/Server/Cmd/Poweron.pm:18`).

## Tests

New `t/cloud_actions.t`, against the mock fixture harness, without network:

1. Entity attributes and predicates from the fixture
2. `refresh` reloads
3. `wait` success path: `running` → `running` → `success`
4. `wait` error path: croaks with the message from `action.error.message`
5. `wait` timeout: croaks with action id and command
6. Poll count via the injected sleeper, **without a single real second**
7. `Firewall` `create` returns `actions` (plural) as an arrayref of `Action`
8. `PlacementGroup` `create` with nullable `action`: the `undef` case holds cleanly
9. `Volume` `create` carries `next_actions` from the aligned fixture

New fixtures `actions_get.json` and `actions_list.json` in the states
`running`, `success` and `error`. Action fixtures for resources already
exist (`networks_action.json`, `firewalls_action.json` and more).

The mock harness stays unchanged: `Test::WWW::Hetzner::MockIO` already accepts
coderef handlers (`t/lib/Test/WWW/Hetzner/Mock.pm:56`), which can model a
sequence of changing responses for the same path.

## Out of scope

- Robot resources (karr #4), Storage Boxes (karr #5), read-only controllers
  (karr #3)
- `_build_request` and `_parse_response` are **not touched in
  their shape**. That leaves `p5-net-async-hetzner` untouched, and no
  ticket on its board is needed. Should that turn out differently while building: stop and
  open a ticket there — never a silent cross-repo edit.
- No release. The maintainer decides that separately.

## Clarified before implementation

Both points checked on 2026-09-07 against the official `cloud.spec.json`
(`https://docs.hetzner.cloud/cloud.spec.json`), not guessed:

1. **Poll endpoint.** The global `GET /actions/{id}` is **not deprecated**
   (`deprecated: false`), nor is `GET /{resource}/actions/{id}`. Only the old
   nested form `/{resource}/{id}/actions/{action_id}` is deprecated. →
   `poll_path` defaults to the global path `/actions`; `refresh` appends
   `/$id`. The controller can override the value if ever needed, but
   the global path is safe.
2. **Which `create` returns an action** (fixture vs. real API):

   | Resource | Fixture | Real API |
   |---|---|---|
   | Server, FloatingIP, LoadBalancer, PrimaryIP, Certificate | `action` | `action` |
   | Volume | `action` | `action` + `next_actions` |
   | Firewall | `actions` | `actions` (plural list) |
   | PlacementGroup | — | `action` (nullable) |
   | Zone | — | `action` |
   | Network, RRSet, SSHKey | — | — |

   Consequence (confirmed by the maintainer, 2026-09-07): correct to the real
   API. `HasAction` on eight entities, `Firewall` with plural `actions`,
   and align the outdated fixtures `placement_groups_create.json`,
   `zones_create.json` as well as the missing `next_actions` in
   `volumes_create.json` with the real API.
