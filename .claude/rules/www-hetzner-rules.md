# WWW::Hetzner House Rules

The shared house rules come from skilletor — bundle `getty-cpan-dist@getty`: engineering
discipline, the delegation lock, the publish gate, karr coordination, CPAN release. They load
as `.claude/rules/.local.*.md`; if they are missing, run `skilletor sync` and publish nothing
until they load. This file adds what is true only here, and wins where it differs.

## What this repo is

Perl client for the Hetzner APIs (Cloud, Storage, Robot). Read first: the neighbouring
controller, the entity it returns and the transport seam you are about to use.

## Agent team

| Task | Agent |
|---|---|
| Implement / refactor / debug behavior-relevant code | `www-hetzner-worker` (default) |
| Write/extend tests | `www-hetzner-test-writer` |
| Write/maintain POD | `www-hetzner-doc-writer` |
| Commits, `Changes`, card → done, pre-release audit | `www-hetzner-release-manager` |
| Read-only research, audit, gap analysis | `www-hetzner-worker` ("read-only, change nothing") |

Behavior-relevant = runtime behavior, the public API, the IO transport seam, the
request/response contract, error handling, tests, the CLI surface. Pure prose docs and README
are not.

## Hazards

- **The IO seam is load-bearing.** Every request goes `_build_request` → `io->call` →
  `_parse_response`; never call LWP directly from a controller.
- **The seam has a consumer.** `p5-net-async-hetzner` reuses `_build_request` /
  `_parse_response`; a change to their shape is a ticket on that repo's board, never a silent
  cross-repo edit.
- **Tests must never hit the network.** Extend a fixture instead — a live check against a real
  account can create or destroy real infrastructure.

## Perl / Moo / release specifics — reference, don't restate

Moo class and role patterns, the architecture, the `[@Author::GETTY]` POD and release
conventions live in skills `getty-perl-moo`, `www-hetzner-core`,
`getty-perl-release-author-getty`, `perl-release-dist-ini` (force-loaded for `www-hetzner-*`
agents).
