# Design: Storage Boxes (api.hetzner.com)

- Ticket: karr #5 (board `WWW-Hetzner`)
- Date: 2026-09-08
- Status: approved on 2026-09-08, full scope
- Prerequisites: action namespace #10; HTTP fixes #11/#13; additive pagination #12

## Problem and goal

`WWW::Hetzner` promises Cloud, Storage and Robot, but so far offers no
client for `api.hetzner.com`. A dedicated Storage client adds the missing
host and covers its Storage Box resources completely: boxes, types,
actions, subaccounts and snapshots, including CLI, mock fixtures and POD.

The maintainer explicitly extended the originally proposed first-round scope:
subaccounts, snapshot management and storage label commands are
**not postponed**. Pagination stays compatible: `list()` returns one page,
`list_all()` is added additively; CLI lists and complete local name lookups
use `list_all()`.

## API basis

Official OpenAPI description, checked in the original draft on 2026-09-08:
`https://docs.hetzner.cloud/hetzner.spec.json`, OpenAPI 3.1.2, title "Hetzner API",
server `https://api.hetzner.com/v1`. Before implementation, concrete
request fields and CLI options must be checked again against these official sources.
No cross-check against real infrastructure.

### Authentication and errors

Bearer token from a Hetzner Console project, obtained under Security → API
Tokens. The cloud specification carries the same instructions; Hetzner's
Ansible module `hetzner.hcloud.storage_box` also uses the same
`api_token`/`HCLOUD_TOKEN` and a separate `api_endpoint_hetzner`.

In line with its existing Cloud convention, the distribution uses
`HETZNER_API_TOKEN`, not `HCLOUD_TOKEN` and no new Storage variable.
Robot's Basic Auth is not involved here.

Error shape: `{"error":{"code","message","details"}}`, like Cloud. The existing
`Role::HTTP::_parse_response` is to be reused.

### Endpoints

| Path | Methods | Response |
|---|---|---|
| `/storage_boxes` | GET, POST | `{storage_boxes, meta}` · `{storage_box, action}` |
| `/storage_boxes/{id}` | GET, PUT, DELETE | `{storage_box}` · `{storage_box}` · `{action}` |
| `/storage_boxes/{id}/folders` | GET | `{folders: [String]}` |
| `/storage_boxes/actions` | GET | `{actions, meta}` |
| `/storage_boxes/actions/{id}` | GET | `{action}` |
| `/storage_boxes/{id}/actions` | GET | `{actions, meta}` |
| `/storage_boxes/{id}/actions/{action_id}` | GET | `{action}`, deprecated; do not use for polling |
| `/storage_boxes/{id}/actions/change_protection` | POST | `{action}` |
| `/storage_boxes/{id}/actions/change_type` | POST | `{action}` |
| `/storage_boxes/{id}/actions/reset_password` | POST | `{action}` |
| `/storage_boxes/{id}/actions/update_access_settings` | POST | `{action}` |
| `/storage_boxes/{id}/actions/rollback_snapshot` | POST | `{action}` |
| `/storage_boxes/{id}/actions/enable_snapshot_plan` | POST | `{action}` |
| `/storage_boxes/{id}/actions/disable_snapshot_plan` | POST | `{action}` |
| `/storage_boxes/{id}/subaccounts` | GET, POST | `{subaccounts}` · `{subaccount, action}` |
| `/storage_boxes/{id}/subaccounts/{sid}` | GET, PUT, DELETE | `{subaccount}` · `{subaccount}` · `{action}` |
| `/storage_boxes/{id}/subaccounts/{sid}/actions/change_home_directory` | POST | `{action}` |
| `/storage_boxes/{id}/subaccounts/{sid}/actions/reset_subaccount_password` | POST | `{action}` |
| `/storage_boxes/{id}/subaccounts/{sid}/actions/update_access_settings` | POST | `{action}` |
| `/storage_boxes/{id}/snapshots` | GET, POST | `{snapshots}` · `{snapshot, action}` |
| `/storage_boxes/{id}/snapshots/{sid}` | GET, PUT, DELETE | `{snapshot}` · `{snapshot}` · `{action}` |
| `/storage_box_types` | GET | `{storage_box_types, meta}` |
| `/storage_box_types/{id}` | GET | `{storage_box_type}` |

According to the specification, the deprecated single-action path was deprecated on
2026-04-30. Polling always uses `/storage_boxes/actions/{id}`; a global
`/actions/{id}` does not exist for this host.

### Entity fields and required fields

- StorageBox: `id`, `name`, `storage_box_type`, `location`, `access_settings`,
  `snapshot_plan` (nullable), `protection`, `labels`, `status`, `username`
  (nullable), `server` (nullable), `system` (nullable), `stats`, `created`.
- Subaccount: `id`, `storage_box`, `name`, `home_directory`, `access_settings`,
  `description`, `labels`, `username`, `server`, `created`.
- Snapshot: `id`, `storage_box`, `name`, `description`, `labels`, `stats`,
  `is_automatic`, `created`.
- StorageBoxType: `id`, `name`, `description`, `snapshot_limit` (nullable),
  `automatic_snapshot_limit` (nullable), `subaccounts_limit`, `size`, `prices`,
  `deprecation` (nullable).

Required create fields: box `storage_box_type`, `location`, `name`, `password`;
subaccount `home_directory`, `password`; snapshot no required fields.
Nullable values stay `undef`; data representation and accessors follow the
existing Cloud entities, including complete raw data via `data()`.

### Actions and return contract

The action schema matches Cloud: `id`, `command`, `status`, `progress`,
`started`, `finished` (nullable), `resources`, `error` (nullable with code/message).
Status: running/success/error.

- Create returns the entity with a required `->action`.
- Update returns the entity, **no invented action**.
- Delete returns an action; the API answers HTTP 201 with `{action}`, not 204.
- POST action endpoints return `WWW::Hetzner::Action`.
- No Storage operation returns `next_actions`, plural `actions` on create
  or sidecar data. Existing optional shared attributes may stay empty.
- Password resets take the password as input; they return none.
- The library does not wait automatically. The CLI waits following the existing pattern;
  `--no-wait` turns this off.

### Pagination and rate limit

`page`/`per_page` and `meta.pagination` match Cloud. Default 25, maximum 50;
metadata: page, per_page, previous_page, next_page, last_page, total_entries,
plus Link headers. The prose mention of `page_size` in the API docs contradicts
the machine-readable parameters; `per_page` is authoritative.

Pagination applies to boxes, types and both action lists. According to the specification,
subaccounts and snapshots have neither such parameters nor `meta`.

`list()` stays a single-page fetch. `list_all()` uses the shared helper from #12:
start at the first or explicitly set `page`, `per_page` as page size,
filters/sorting unchanged on every following page, no mutation of the call parameters.
Missing metadata means a complete single response; repeated or
invalid following pages and errors on later pages are reported loudly.
Non-paginated sublists get no invented query parameters.

Both APIs state 3600 requests/hour per project. Whether they share the quota
is not documented. No speculative backoff or rate-limit rework.

## Decisions

### E1 — A dedicated Storage client

`WWW::Hetzner::Storage` becomes a sibling of Cloud and Robot, reachable via
`$hetzner->storage`. A client owns one `base_url`; an add-on to Cloud would have to
bend it or bypass the IO seam. Both are avoided. No generic
multi-host client and no precautionary abstraction for possible further services.

### E2 — Shared env default, explicit client configuration

Storage uses `token` with default `$ENV{HETZNER_API_TOKEN}` and an overridable
`base_url` with default `https://api.hetzner.com/v1`. No new env variable.
The umbrella class gets no additional token attribute: its clients each read
the existing env default. Individual tokens can be set on the respective client.
The CLI builds Cloud and Storage from its existing `--token` option.

As with Cloud, missing authentication is rejected early with a helpful Storage hint,
before the request is executed.

### E3 — Keep the shared HTTP/IO seam

Storage consumes `Role::HTTP`; the path stays `_build_request` → `io->call`
→ `_parse_response`. No Storage HTTP role and no direct LWP access.

The separate tickets #11/#13 fix form encoding for Robot and URI encoding
for all clients. Storage uses their JSON/Bearer default unchanged. The
request/response signatures and object shapes are preserved. Async follow-up tickets
on the seam regression are maintained on the sister board, without editing its code
here. An async Storage extension is not part of this project.

### E4 — Neutral action building blocks

Approved and implemented beforehand in #10:

| before | after |
|---|---|
| `WWW::Hetzner::Cloud::Action` | `WWW::Hetzner::Action` |
| `WWW::Hetzner::Cloud::Role::HasAction` | `WWW::Hetzner::Role::HasAction` |
| `WWW::Hetzner::Cloud::Role::HasActions` | `WWW::Hetzner::Role::HasActions` |

No backward aliases: these classes were never released. Cloud::API::Actions
stays Cloud-specific. No second action class and no duplicated poll logic.

In #5 the shared wrappers get an overridable poll path:
Cloud `/actions`, Storage `/storage_boxes/actions`. This applies to directly returned
actions and the create actions of boxes, subaccounts and snapshots.

### E5 — CLI under hcloud.pl storage-box

No third binary. `WWW::Hetzner::CLI` follows the official hcloud CLI, whose
storage-box branch has existed since 1.61.0. The separate Robot entry point stays untouched.

Box commands: list, describe, create, update, delete, change-type, reset-password,
enable-protection, disable-protection, enable-snapshot-plan, disable-snapshot-plan,
rollback-snapshot, update-access-settings, folders, add-label, remove-label.
Plus subgroups snapshot and subaccount for their CRUD and action operations;
align concrete option names with the official CLI documentation.
Storage label changes preserve all other labels; no label rework for all
Cloud resources.

Mechanics: `CLI::Cmd::StorageBox`, `StorageBox::Cmd::*`, subtrees for snapshot and
subaccount, the existing alias table and custom_help in `bin/hcloud.pl`, a dedicated
storage accessor in `CLI.pm`. Mutating action paths use `WaitsForAction`.

### E6 — MockIO and flat fixtures

`t/lib/Test/WWW/Hetzner/Mock.pm` gets `mock_storage` after `mock_cloud`/`mock_robot`,
with its own base_url and test token. The MockIO interface extended in #11/#13
is reused: query inspection, content-type-correct bodies and original
requests for independent RAW assertions. No redesign into a generic
factory; different hosts get separate MockIO instances.

Flat fixtures under `t/fixtures/`, values from the official API examples:
`storage_boxes_{list,get,create,action,folders}.json`,
`storage_box_actions_{get,list}.json`, `storage_box_types_{get,list}.json`,
the corresponding `storage_box_subaccounts_*` and `storage_box_snapshots_*`.
No invented response fields and no new fixture subdirectory.

### E7 — Full scope of this implementation

- Storage client, boxes, types, actions.
- Subaccounts with CRUD and the three documented actions.
- Snapshots with CRUD; snapshot plan/rollback stay box actions.
- The complete corresponding CLI tree including storage labels.
- Fixtures, API/entity/CLI tests, POD and navigation.
- Pagination and query encoding via the standalone tickets #12/#13.

No postponing of the subresources into new tickets. Not included: S3/Object
Storage, async Storage, speculative additional API resources, release.

## Architecture and affected code

New modules under `lib/WWW/Hetzner/`:

- `Storage.pm`.
- `Storage/API/{StorageBoxes,StorageBoxTypes,Actions,Subaccounts,Snapshots}.pm`.
- `Storage/{StorageBox,StorageBoxType,Subaccount,Snapshot}.pm`.
- `CLI/Cmd/StorageBox.pm`, `CLI/Cmd/StorageBox/Cmd/*.pm` and the subtrees.

Mesh following the existing one-to-one convention:

| Resource root | Accessor | Controller | Entity |
|---|---|---|---|
| storage_boxes | `$storage->storage_boxes` | API::StorageBoxes | StorageBox |
| storage_box_types | `$storage->storage_box_types` | API::StorageBoxTypes | StorageBoxType |
| storage_boxes/actions | `$storage->actions` | API::Actions | WWW::Hetzner::Action |
| storage_boxes/{id}/actions | `$box->actions` | API::Actions (storage_box_id set) | WWW::Hetzner::Action |
| subaccounts | `$box->subaccounts` | API::Subaccounts | Subaccount |
| snapshots | `$box->snapshots` | API::Snapshots | Snapshot |

Subresource controllers carry storage_box_id following `Cloud/API/RRSets.pm`;
entity access follows `Cloud/Zone.pm`. The actions controller uses the same
pattern: an optional storage_box_id binds only list/list_all to the box;
get($action_id) and polling use the global supported path there as well.
No additional wrapper for the deprecated single-action path is introduced.
Shorter invented names such as `$storage->boxes` are not introduced.

Existing files: `lib/WWW/Hetzner.pm`, `lib/WWW/Hetzner/CLI.pm`,
`lib/WWW/Hetzner/Role/HasActions.pm`, `bin/hcloud.pl`,
`t/lib/Test/WWW/Hetzner/Mock.pm`, `t/basic.t`, `Changes`, README and POD navigation.
All new modules must be reachable via L<> from WWW::Hetzner.

## Acceptance and tests

Network-free mock tests only; inject the sleeper, no real waiting.

- Client: correct host, Bearer auth, explicit tokens/URL and missing token.
- Boxes/types: list/get/list_all/get_by_name, complete and nullable attributes,
  required create fields, update entity, delete action, folders as a string arrayref.
- All seven box actions: path, body and action return.
- Subaccounts: CRUD, all three actions, correct box/subaccount ID, password as
  input, create action and delete action.
- Snapshots: CRUD, optional create fields, correct nested IDs,
  create action and delete action; box snapshot plan and rollback separately.
- Action polling for all return paths against `/storage_boxes/actions/{id}`,
  never global `/actions` or deprecated paths; running → success, API error,
  action error and timeout.
- Pagination for boxes, types and action lists with several pages;
  subresources without invented pagination.
- CLI: every new real execute(), valid options and request passing,
  JSON decodable, tables via accessors, label preservation, default wait and
  `--no-wait`, error passing. Check aliases/help including subgroups.
- Fixtures from official examples; check RAW requests independently of the mock decoder
  where the encoding carries the contract.
- Load new modules, POD syntax and complete link graph, full suite,
  `dzil build` and `dzil test`. Report skipped live integration explicitly.

`Changes` under `{{$NEXT}}` describes the actual new scope. Do not derive
any version/release action from this specification.
