# Design: Storage Boxes (api.hetzner.com)

- Ticket: karr #5 (Board `WWW-Hetzner`)
- Datum: 2026-09-08
- Status: Entwurf, wartet auf Freigabe des Maintainers

## Problem

Die Distribution verspricht Storage-Unterstützung an drei Stellen und liefert sie
an keiner:

- `WWW/Hetzner.pm:3` — `# ABSTRACT: Perl client for Hetzner APIs (Cloud, Storage, Robot)`.
  Der ABSTRACT wird von PodWeaver zur NAME-Sektion und landet so auf der
  CPAN-Übersichtsseite.
- `WWW/Hetzner.pm:53` — die DESCRIPTION listet `B<Hetzner API> - api.hetzner.com
  (Storage Boxes, not yet implemented)` gleichrangig neben Cloud und Robot.
- `WWW/Hetzner.pm:84` — der Zugang dazu ist ein auskommentierter Block:

      # TODO: Storage API not yet implemented
      # has storage => (
      #     is      => 'lazy',
      #     builder => sub { WWW::Hetzner::Storage->new },
      # );

Es existiert also weder `WWW::Hetzner::Storage` noch irgendein Controller, Entity,
CLI-Kommando oder Fixture für den dritten Host. `WWW::Hetzner::Role::HTTP` kennt
genau zwei Konsumenten (`Cloud.pm:172`, `Robot.pm:118`), und beide binden ihre
`base_url` fest an ihren jeweiligen Host (`Cloud.pm:154`,
`Robot.pm:107`).

Das ist kein kosmetisches Doku-Problem: `api.hetzner.com` ist ein eigener Host mit
eigenem Pfadbaum, den die vorhandene Cloud-Klasse konstruktiv nicht erreichen kann
(siehe E3).

## Die API — geprüft, nicht geraten

Grundlage ist die offizielle OpenAPI-Beschreibung
`https://docs.hetzner.cloud/hetzner.spec.json` (OpenAPI 3.1.2, `info.title` =
"Hetzner API", `servers[0].url` = `https://api.hetzner.com/v1`), abgerufen am
2026-09-08. Sie ist das Gegenstück zur `cloud.spec.json`, gegen die schon karr #2
geprüft wurde.

### Authentifizierung

`components.securitySchemes.APIToken` ist `{ "type": "http", "scheme": "bearer" }`
— identisch zur `cloud.spec.json`. Der Header ist `Authorization: Bearer <token>`.

Die Beschaffungsanweisung ist in beiden Spezifikationen **wortgleich**: "switch
into the Hetzner Console, choose a Project, go to `Security` → `API Tokens`, and
generate a new token". Es ist also derselbe projektgebundene Token wie für die
Cloud API, nur gegen einen anderen Host geschickt. Bestätigt wird das unabhängig
durch Hetzners eigenes Ansible-Modul `hetzner.hcloud.storage_box`: es
authentifiziert mit demselben `api_token` / `HCLOUD_TOKEN` wie alle anderen
`hetzner.hcloud`-Module und hat lediglich einen zusätzlichen Parameter
`api_endpoint_hetzner` (Env `HETZNER_ENDPOINT`, Default `https://api.hetzner.com/v1`)
für den abweichenden Host.

Robots Basic Auth ist hier also nicht im Spiel; `Role::HTTP`s Default-`_set_auth`
(`Role/HTTP.pm:138`) passt unverändert.

### Ressourcen und Endpunkte

Der gesamte Pfadbaum der Spezifikation, vollständig:

| Pfad | Methoden | Antwort |
|---|---|---|
| `/storage_boxes` | GET, POST | `{storage_boxes, meta}` · `{storage_box, action}` |
| `/storage_boxes/{id}` | GET, PUT, DELETE | `{storage_box}` · `{storage_box}` · `{action}` |
| `/storage_boxes/{id}/folders` | GET | `{folders: [String]}` |
| `/storage_boxes/actions` | GET | `{actions, meta}` |
| `/storage_boxes/actions/{id}` | GET | `{action}` |
| `/storage_boxes/{id}/actions` | GET | `{actions, meta}` |
| `/storage_boxes/{id}/actions/{action_id}` | GET | `{action}` — **deprecated** |
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

Genau eine Operation trägt `deprecated: true`:
`GET /storage_boxes/{id}/actions/{action_id}`, mit Verweis auf den Changelog-Eintrag
`2026-04-30-deprecate-get-resource-action-endpoints`. Der nicht abgekündigte
Poll-Pfad ist `/storage_boxes/actions/{id}`. Das ist dieselbe Abkündigungslage wie
in der Cloud API (karr #2, "Vor der Implementierung geklärt", Punkt 1) — nur dass
es hier **keinen** globalen `/actions`-Pfad gibt: der Poll-Pfad ist
ressourcenpräfigiert.

Entity-Felder laut Spezifikation:

- `storage_box`: `id`, `name`, `storage_box_type`, `location`, `access_settings`,
  `snapshot_plan` (nullable), `protection`, `labels`, `status`, `username`
  (nullable), `server` (nullable), `system` (nullable), `stats`, `created`
- `subaccount`: `id`, `storage_box`, `name`, `home_directory`, `access_settings`,
  `description`, `labels`, `username`, `server`, `created`
- `snapshot`: `id`, `storage_box`, `name`, `description`, `labels`, `stats`,
  `is_automatic`, `created`
- `storage_box_type`: `id`, `name`, `description`, `snapshot_limit` (nullable),
  `automatic_snapshot_limit` (nullable), `subaccounts_limit`, `size`, `prices`,
  `deprecation` (nullable)

Pflichtfelder beim Anlegen: `POST /storage_boxes` verlangt `storage_box_type`,
`location`, `name`, `password`; `POST .../subaccounts` verlangt `home_directory`
und `password`; `POST .../snapshots` verlangt nichts.

### Actions

Das Action-Objekt ist **feldgleich** zur Cloud-Action. Der inline definierte
`ActionResponse`-Schema-Titel führt `id`, `command`, `status`
(`running`/`success`/`error`), `progress`, `started`, `finished` (nullable),
`resources` (`[{id, type}]`) und `error` (nullable `{code, message}`) — alle acht
als `required`. Es gibt keine Storage-spezifischen Zusatzfelder.

Wichtige Abweichungen zur Cloud-Seite, die den Entwurf beeinflussen:

1. **`action` bei `create` ist nicht nullable.** `POST /storage_boxes`,
   `POST .../subaccounts` und `POST .../snapshots` führen die Action jeweils als
   `required` neben der Ressource. Der `undef`-Fall, den `HasAction` wegen der
   unmanaged Placement Group tragen muss, tritt hier nicht auf — schadet aber auch
   nicht.
2. **Kein `next_actions`.** Keine Storage-Operation liefert eine Folgeaktionsliste.
3. **Keine Sidecar-Daten.** Insbesondere geben `reset_password` und
   `reset_subaccount_password` **kein** Passwort zurück — das Passwort ist
   Eingabe (`requestBody.password`, `required`), nicht Ausgabe. Das `result`-Attribut
   aus karr #2 / E5 bleibt für Storage also leer.
4. **`DELETE` liefert eine Action, kein 204.** Alle drei Delete-Operationen
   antworten mit HTTP 201 und `{action}`.
5. **Es gibt keine Plural-`actions`-Antwort** wie bei `Firewall`-`create`.

### Paginierung und Fehlerform

Fehlerform ist identisch zur Cloud API: `{"error": {"code", "message", "details"}}`,
mit derselben Code-Tabelle (`invalid_input`, `not_found`, `locked`, `protected`,
`rate_limit_exceeded` …). `Role/HTTP.pm:219` liest bereits genau
`$data->{error}{message}` — kein Anpassungsbedarf.

Paginierung ist identisch zur Cloud API: Query-Parameter `page` und `per_page`
(Default 25, Maximum 50), Antwort mit `meta.pagination`
(`page`, `per_page`, `previous_page`, `next_page`, `last_page`, `total_entries`)
plus `Link`-Header. Sie gilt für `/storage_boxes`, `/storage_box_types` und die
beiden Action-Listen — **nicht** für `/storage_boxes/{id}/subaccounts` und
`/storage_boxes/{id}/snapshots`: deren Parameterliste kennt kein `page`/`per_page`,
und ihre Antwort hat kein `meta`.

Anmerkung: Der Prosa-Abschnitt "Query Parameters" der Spezifikation zeigt ein
Beispiel mit `page_size=12`. Die maschinenlesbare Parameterliste kennt
ausschliesslich `per_page`. Dieselbe Inkonsistenz steht wortgleich in der
`cloud.spec.json`; es ist ein Doku-Fehler auf Hetzner-Seite. Massgeblich ist
`per_page`.

Rate Limit: 3600 Requests/Stunde und Projekt, `RateLimit-*`-Header. Ob dieses
Kontingent mit dem der Cloud API geteilt wird, sagt keine der beiden
Spezifikationen — siehe "Offene Fragen".

## Entscheidungen

Sieben Festlegungen, jeweils mit dem Grund und der verworfenen Alternative.

### E1 — Storage wird eine eigene Top-Level-Klasse, kein Cloud-Anbau

`WWW::Hetzner::Storage` als Geschwister von `WWW::Hetzner::Cloud` und
`WWW::Hetzner::Robot`, erreichbar über `$hetzner->storage` (der auskommentierte
Block `WWW/Hetzner.pm:84` wird genau so aktiviert, wie er dort steht).

Grund — und der ist konstruktiv, nicht ästhetisch: `Role::HTTP` baut jede URL als
`$self->base_url . $path` (`Role/HTTP.pm:166`). Es gibt **eine** `base_url` pro
Client und keinen Seam für einen abweichenden Host pro Request. Ein
`$cloud->storage_boxes`-Controller müsste daher entweder die `base_url` seines
Clients umbiegen (ein `ro`-Attribut, `Cloud.pm:154`, und ein Zustandswechsel
mitten in einem geteilten Objekt) oder an `_build_request` vorbei eine eigene URL
bauen — genau der Griff an der IO-Naht vorbei, den die Hausregeln verbieten und
der Mock-Harness wie `Net::Async::Hetzner` gleichzeitig stillschweigend bricht.

`Robot.pm` ist der Präzedenzfall für die saubere Variante: eigener Client, eigene
`base_url` (`Robot.pm:107`), eigenes `_set_auth` (`Robot.pm:127`), eigener
Controller- und Entity-Namensraum, eigener CLI-Zweig. Storage ist derselbe Fall,
nur mit weniger Abweichung (die Auth ist sogar die Cloud-Auth).

Verworfene Alternative A: Eingliederung in `WWW::Hetzner::Cloud` als
`$cloud->storage_boxes`. Ergonomisch attraktiv (ein Objekt, ein Token) und
oberflächlich durch den geteilten Token gerechtfertigt — scheitert aber an der
Ein-Host-Bindung oben. Die Ergonomie lässt sich billiger haben: `WWW::Hetzner`
reicht denselben Token an beide Clients (E2).

Verworfene Alternative B: ein generischer `WWW::Hetzner::API`-Client, der den Host
pro Aufruf bekommt. Das wäre eine Umgestaltung der Naht für einen einzigen neuen
Host und ein Bruch für `p5-net-async-hetzner`, das `_build_request` erbt.

Namensrisiko, bewusst in Kauf genommen: Der Host heisst offiziell "Hetzner API",
nicht "Storage API" — Hetzner kann dort später Nicht-Storage-Ressourcen
anbieten. `WWW::Hetzner::Storage` ist trotzdem der richtige Name: er ist der, den
der ABSTRACT (`WWW/Hetzner.pm:3`) und der auskommentierte Block bereits versprechen,
und heute enthält der Host ausschliesslich Storage Boxes. Sollte er wachsen, ist
ein zweiter Geschwister-Client für den dann neuen Ressourcenbereich billiger als
ein heute vorsorglich abstrakt benannter.

### E2 — Derselbe Token, dieselbe Umgebungsvariable, überschreibbare `base_url`

    has token    => ( is => 'ro', default => sub { $ENV{HETZNER_API_TOKEN} } );
    has base_url => ( is => 'ro', default => 'https://api.hetzner.com/v1' );

Grund: Es *ist* derselbe Token (siehe "Authentifizierung"). Eine eigene Variable
`HETZNER_STORAGE_TOKEN` würde eine Trennung suggerieren, die es nicht gibt, und
den Normalfall — ein Projekt, ein Token — mit doppelter Konfiguration bestrafen.
`Cloud.pm:132` liest `HETZNER_API_TOKEN`; Storage liest dieselbe Variable.

`WWW::Hetzner` baut beide Clients aus derselben Quelle; `$hetzner->storage` und
`$hetzner->cloud` sind dann konsistent konfiguriert, ohne dass eine Klasse von der
anderen weiss.

`base_url` bleibt wie bei Cloud und Robot ein überschreibbares Attribut — das
deckt denselben Bedarf ab, den Hetzners Ansible-Modul mit `HETZNER_ENDPOINT`
abdeckt (Testinstanzen, Proxies). Eine eigene Env-Variable dafür wird **nicht**
eingeführt: Cloud und Robot haben auch keine.

Storage bekommt ein `_check_auth` nach dem Muster `Cloud.pm:151` (`around _request`,
`Cloud.pm:174`) mit auf Storage angepasstem Hinweistext. Grund: die hilfreiche
Fehlermeldung bei fehlendem Token ist in dieser Distribution etablierte Praxis,
und `Role::HTTP`s generisches `croak "No API token configured"`
(`Role/HTTP.pm:240`) sagt dem Anwender nicht, wo er einen bekommt.

Verworfen: eigener Env-Name; Token-Weiterreichung durch `$cloud->storage` (macht
Cloud von Storage abhängig, ohne dass Cloud etwas davon hätte).

### E3 — `Role::HTTP` und `Role::IO` unverändert wiederverwenden

Storage konsumiert `WWW::Hetzner::Role::HTTP` genau so, wie Cloud es tut. Keine
Parametrisierung, kein zweites Rollenpaar, keine Änderung an `Role::IO`.

Geprüft wurde, was die Rolle an Cloud-Annahmen fest verdrahtet hat:

| Aspekt | Ort | Cloud-spezifisch? |
|---|---|---|
| Base-URL | `requires 'base_url'` (`:51`), Verwendung `:166` | nein — Attribut des Konsumenten |
| Auth-Header | `_set_auth` (`:138`), Bearer | nein — Storage braucht exakt das; Robot überschreibt bereits |
| Fehlerform | `_parse_response` (`:219`), `error.message` | nein — api.hetzner.com hat dieselbe Form |
| Paginierung | — | gibt es nicht; `meta` wird von den Controllern schlicht ignoriert |
| Query-Parameter | `_build_request` (`:171`) | nein, aber lückenhaft (siehe unten) |

Es ist **kein Cloud-Spezifikum** in der Rolle. Sie ist bereits das gemeinsame
HTTP-Verhalten zweier sehr unterschiedlicher APIs; Storage ist der leichteste der
drei Fälle.

Konsequenz für das Schwesterprojekt: `Role::IO`s `call($req)` und die Form von
`_build_request`/`_parse_response` werden **nicht angefasst**. `p5-net-async-hetzner`
ist von dieser Änderung nicht betroffen, es braucht **kein** Cross-Repo-Ticket.
Sollte sich beim Bauen doch ein Formänderungsbedarf ergeben: anhalten, auf dem
dortigen Board ein Ticket anlegen — niemals ein stiller Cross-Repo-Edit.

Bekannte Lücke, die Storage sichtbarer macht als Cloud, aber nicht verursacht:
`_build_request` baut Query-Strings aus einem flachen Hash (`Role/HTTP.pm:171`),
ohne URI-Kodierung und ohne Mehrfachwerte. Damit sind `label_selector=key%3Dvalue`
und wiederholtes `sort=a&sort=b` nicht darstellbar — beides ist in der
Storage-API (und in der Cloud-API) vorgesehen. Das ist eine bestehende Schwäche
der Cloud-Seite, kein Storage-Problem, und gehört in ein **eigenes Ticket**, nicht
in diese Implementierung.

Verworfene Alternative A: `Role::HTTP` parametrisieren (etwa
`MooX::Role::Parameterized` mit Auth-Strategie und Fehlerpfad). Löst ein Problem,
das nicht existiert, und macht die meistgelesene Datei der Distribution schwerer
lesbar.

Verworfene Alternative B: ein zweites Rollenpaar `Storage::Role::HTTP`/`::IO`.
Verdoppelt die tragende Naht — und damit den Ort, an dem der Mock und der
Async-Client andocken. Genau die Divergenz, die die Hausregeln als Hauptgefahr
dieser Distribution benennen.

### E4 — Die Action wandert aus dem Cloud-Namensraum heraus

Das ist die schwerste Entscheidung dieser Spec; hier die Lage im Detail.

**Was existiert.** karr #2 hat `WWW::Hetzner::Cloud::Action` gebaut
(`Cloud/Action.pm`), dazu `Cloud::Role::HasAction` (Entity-Seite) und
`Cloud::Role::HasActions` (Controller-Seite, `_wrap_action`, `_wrap_actions`,
`_wrap_action_result`).

**Was davon Cloud-spezifisch ist: nichts.** Die Klasse verlangt von ihrem Client
genau zwei Dinge — `get($path)` und `sleeper` (`Cloud/Action.pm:220` und `:248`),
beide aus `Role::HTTP`. Der einzige API-abhängige Wert ist `poll_path`
(`Cloud/Action.pm:45`, Default `/actions`), und der ist bereits als
überschreibbares Attribut angelegt — karr #2 hat diesen Fall ausdrücklich
vorgesehen ("macht die Ressourcen-Variante zu einer Zeile pro Controller"). Für
Storage ist der Wert `/storage_boxes/actions`. Die Klasse ist, so wie sie ist,
sofort verwendbar; nur ihr Name lügt dann.

**Was der Zeitpunkt hergibt.** `Cloud::Action` steht in `Changes` unter
`{{$NEXT}}`, nicht unter `0.100`. Die letzte Version auf CPAN ist `0.100`
(Git-Tag `0.100`). Die Klasse wurde **nie ausgeliefert**. Ein Umbenennen kostet
heute keinen einzigen CPAN-Konsumenten; nach dem nächsten Release kostet es eine
Kompatibilitätsschicht auf Dauer.

**Festlegung.** Die drei Bausteine wandern in den neutralen Namensraum:

| vorher | nachher |
|---|---|
| `WWW::Hetzner::Cloud::Action` | `WWW::Hetzner::Action` |
| `WWW::Hetzner::Cloud::Role::HasAction` | `WWW::Hetzner::Role::HasAction` |
| `WWW::Hetzner::Cloud::Role::HasActions` | `WWW::Hetzner::Role::HasActions` |

Ohne Rückwärts-Alias, weil es nichts gibt, wozu rückwärts-kompatibel zu sein wäre.
`WWW::Hetzner::Cloud::API::Actions` bleibt, wo es ist: der Controller *ist*
Cloud-spezifisch (Pfad `/actions`), Storage bekommt sein eigenes
`WWW::Hetzner::Storage::API::Actions` mit Pfad `/storage_boxes/actions`.

Der `Changes`-Eintrag unter `{{$NEXT}}` wird auf die neuen Namen korrigiert —
er beschreibt eine unveröffentlichte Änderung, keine ausgelieferte.

Grund: Ein `WWW::Hetzner::Storage::StorageBox`, dessen `->action` ein
`WWW::Hetzner::Cloud::Action` ist, ist eine Lüge, die auf ewig in der POD stehen
bliebe. Und das Zeitfenster, in dem die Korrektur gratis ist, schliesst sich mit
dem nächsten Release.

Verworfene Alternative A: Storage benutzt `WWW::Hetzner::Cloud::Action` über die
Namensraumgrenze hinweg. Technisch funktioniert es heute, ohne jede Änderung an
`Cloud/**` — der billigste denkbare Weg. Verworfen, weil die Ersparnis einmalig
ist und der Preis dauerhaft: jede Storage-POD müsste den Cloud-Namen erklären, und
die nächste API (Hetzner hat drei Hosts, nicht zwei) erbt dieselbe Verrenkung.

Verworfene Alternative B: eigene `WWW::Hetzner::Storage::Action` mit eigener
`wait`/`refresh`-Implementierung. Dupliziert rund 250 Zeilen samt Timeout- und
Fehlerpfad; jeder künftige Fix am Polling müsste zweimal gemacht und zweimal
getestet werden. Der einzige echte Unterschied zwischen den beiden wäre der
Default von `poll_path` — ein Argument, kein Grund für eine zweite Klasse.

Verworfene Alternative C: Verschiebung erst später, wenn ein dritter Nutzer
auftaucht. Das ist der Standardrat gegen verfrühte Abstraktion, hier aber falsch
herum: die Abstraktion existiert schon, es geht nur um ihren Ort, und "später"
heisst hier "nach dem Release, also mit Alias-Altlast".

**Reihenfolge und Kollisionsgefahr.** Die Verschiebung berührt rund zwanzig
Dateien unter `lib/WWW/Hetzner/Cloud/**` — acht Entities, acht Controller, die
beiden Rollen, `Cloud.pm`, dazu `CLI/Role/WaitsForAction.pm` und die Tests. An
`lib/WWW/Hetzner/Cloud/**` und `lib/WWW/Hetzner/CLI/**` arbeiten derzeit andere
Tickets. Die Verschiebung gehört deshalb in ein **eigenes, vorgelagertes Ticket**,
das läuft, wenn der Cloud-Baum ruhig ist — nicht in die Storage-Implementierung.
Solange es nicht gelaufen ist, ist Storage blockiert (oder fällt, wenn der
Maintainer E4 ablehnt, auf Alternative A zurück).

### E5 — CLI: `hcloud.pl storage-box`, kein eigenes Binary

Storage bekommt einen Subcommand-Baum unter dem bestehenden `hcloud.pl`, keinen
dritten Einstiegspunkt neben `hcloud.pl` und `hrobot.pl`.

Grund: `WWW::Hetzner::CLI` erklärt sich in seiner eigenen POD zum "B<1:1 replica>
of the official C<hcloud> CLI from Hetzner" (`CLI.pm`, DESCRIPTION), und das
offizielle `hcloud` hat Storage Boxes seit 1.61.0 als `hcloud storage-box` mit den
Unterkommandos `list`, `describe`, `create`, `update`, `delete`, `change-type`,
`reset-password`, `enable-protection`, `disable-protection`,
`enable-snapshot-plan`, `disable-snapshot-plan`, `rollback-snapshot`,
`update-access-settings`, `folders`, `add-label`, `remove-label` sowie den
Untergruppen `snapshot` und `subaccount`. Ein `hstorage.pl` würde die erklärte
Leitlinie brechen und den Anwender zwingen, sich zu merken, dass Hetzners eine
CLI hier zwei ist.

Der Robot-Zweig ist **kein** Gegenargument, sondern die Bestätigung der Regel: er
hat ein eigenes Binary, weil das offizielle `hcloud` keine dedizierten Server
kennt. Wo Hetzners CLI trennt, trennt diese Distribution; wo sie zusammenfasst,
fasst sie zusammen.

Mechanik: `WWW::Hetzner::CLI::Cmd::StorageBox` plus `StorageBox/Cmd/*.pm`, dem
Muster von `CLI/Cmd/Volume.pm` und `CLI/Cmd/Volume/Cmd/` folgend. Perl-Pakete
kennen keine Bindestriche, also kommen die Namen in die vorhandene Alias-Tabelle
`bin/hcloud.pl:11` (`'storage-box' => 'storagebox'`, `'change-type' =>
'changetype'`, `'reset-password' => 'resetpassword'` und die übrigen) — genau so,
wie `'floating-ip'` und `'add-rule'` es dort schon tun. `hcloud.pl` bekommt
ausserdem einen `%custom_help`-Eintrag (`bin/hcloud.pl:34`), weil `storage-box`
hyphenisierte Unterkommandos hat.

`WWW::Hetzner::CLI` bekommt ein `storage`-Attribut nach dem Muster von
`has cloud` (`CLI.pm:127`), gebaut aus derselben `--token`-Option. Die mutierenden
Unterkommandos konsumieren `WWW::Hetzner::CLI::Role::WaitsForAction` — die Rolle
prüft nur auf `blessed($action) && $action->can('wait')` und funktioniert mit der
verschobenen Action-Klasse unverändert.

Verworfen: eigenes `bin/hstorage.pl` (bricht die 1:1-Leitlinie, dritte Binary für
denselben Token); Eingliederung als flaches `hcloud.pl storagebox` ohne
Bindestrich (weicht ohne Not vom offiziellen Kommandonamen ab, wo die
Alias-Tabelle das Problem längst gelöst hat).

### E6 — Test-Harness: `mock_storage`, Fixtures mit Ressourcen-Präfix

`t/lib/Test/WWW/Hetzner/Mock.pm` bekommt eine dritte Fabrik neben `mock_cloud`
(`:103`) und `mock_robot` (`:117`):

    sub mock_storage {
        my (%routes) = @_;
        my $io = Test::WWW::Hetzner::MockIO->new(
            routes   => \%routes,
            base_url => 'https://api.hetzner.com/v1',
        );
        return WWW::Hetzner::Storage->new( token => 'test-token', io => $io );
    }

plus der Export-Zeile in `import` (`Mock.pm:88`) und dem `use` am Dateikopf.

Das ist alles. `MockIO` selbst bleibt **unverändert**: es streift die `base_url`
seiner Instanz vom Request-URL ab (`Mock.pm:19`) und ist damit host-agnostisch —
jeder Client bringt sein eigenes MockIO mit eigener `base_url` mit, Routen
verschiedener Hosts können sich nicht überschneiden. Ein Test, der Cloud und
Storage gleichzeitig braucht, baut zwei Clients; das ist heute schon der Fall für
Cloud und Robot.

Fixture-Layout unter `t/fixtures/`, nach der bestehenden Konvention
"Ressourcenwurzel + Operation" (`volumes_list.json`, `servers_create.json`):

| Datei | Inhalt |
|---|---|
| `storage_boxes_list.json` | `{storage_boxes: [...], meta: {pagination}}` |
| `storage_boxes_get.json` | `{storage_box: {...}}` |
| `storage_boxes_create.json` | `{storage_box: {...}, action: {...}}` |
| `storage_boxes_action.json` | `{action: {...}}` — Antwort der POST-Actions und von DELETE |
| `storage_boxes_folders.json` | `{folders: [...]}` |
| `storage_box_actions_get.json` | `{action: {...}}` — Poll-Antwort |
| `storage_box_actions_list.json` | `{actions: [...], meta: {pagination}}` |
| `storage_box_types_list.json` | `{storage_box_types: [...], meta: {pagination}}` |
| `storage_box_types_get.json` | `{storage_box_type: {...}}` |

Die Präfixe kollidieren mit nichts: `robot_*` ist für Robot reserviert, alles
Präfixlose ist Cloud, `storage_box*` ist neu. Alle Fixtures werden aus den
`examples`-Werten der `hetzner.spec.json` abgeleitet, nicht erfunden — das ist
die Lehre aus karr #2, wo veraltete Fixtures eine falsche Zählung getragen haben.

Verworfen: ein Unterverzeichnis `t/fixtures/storage/` (bricht `load_fixture`
(`Mock.pm:97`), das flach im Fixture-Verzeichnis sucht); ein generisches
`mock_client($class, $base_url, %routes)` (macht drei knappe Fabriken zu einer
umständlichen und ändert die Aufrufform aller bestehenden Tests).

### E7 — Schnitt der ersten Runde

**In der ersten Runde (dieses Ticket):**

- `WWW::Hetzner::Storage` (Token, `base_url`, `_check_auth`, `Role::HTTP`)
- `WWW::Hetzner::Storage::API::StorageBoxes` — `list`, `get`, `create`, `update`,
  `delete`, `folders` und die sieben Box-Actions (`change_protection`,
  `change_type`, `reset_password`, `update_access_settings`, `rollback_snapshot`,
  `enable_snapshot_plan`, `disable_snapshot_plan`)
- `WWW::Hetzner::Storage::API::StorageBoxTypes` — `list`, `get`, `get_by_name`
  (letzteres nach dem Muster `Cloud/API/ServerTypes.pm:93`)
- `WWW::Hetzner::Storage::API::Actions` — `get`, `list`, Poll-Pfad
  `/storage_boxes/actions`
- Entities `WWW::Hetzner::Storage::StorageBox` und
  `WWW::Hetzner::Storage::StorageBoxType`
- `$hetzner->storage` in `WWW/Hetzner.pm` (der Block bei `:84` wird aktiviert),
  ABSTRACT und DESCRIPTION-Liste entsprechend korrigiert
- CLI-Zweig `hcloud.pl storage-box` mit `list`, `describe`, `create`, `update`,
  `delete`, `change-type`, `reset-password`, `enable-protection`,
  `disable-protection`, `enable-snapshot-plan`, `disable-snapshot-plan`,
  `rollback-snapshot`, `update-access-settings`, `folders`
- `mock_storage` und die Fixtures aus E6
- Tests `t/storage_boxes.t`, `t/storage_box_types.t`, `t/storage_actions.t`

**Bewusst vertagt, je ein eigenes Ticket:**

1. **Subaccounts** — Controller `Storage::API::Subaccounts` (mit
   `storage_box_id`-Attribut nach dem Muster `Cloud/API/RRSets.pm:67`), Entity
   `Storage::Subaccount`, Zugriff `$box->subaccounts` (Muster `Zone.pm:160`),
   CLI-Untergruppe `storage-box subaccount`, dazu die drei Subaccount-Actions.
2. **Snapshots** — dieselbe Struktur, `$box->snapshots`, CLI-Untergruppe
   `storage-box snapshot`. `rollback-snapshot` ist trotzdem schon in Runde 1
   nutzbar: es nimmt nur eine Snapshot-Id.
3. **`add-label` / `remove-label`** — das offizielle `hcloud` hat sie für
   Storage Boxes, diese Distribution hat sie für **keine** Ressource. Sie
   nachzuziehen ist ein CLI-weites Thema, kein Storage-Thema.
4. **Query-String-Lücke in `_build_request`** — URI-Kodierung und Mehrfachwerte
   (`sort`, `label_selector`), siehe E3. Betrifft Cloud und Storage gleichermassen.
5. **Paginierung über die erste Seite hinaus** — die Distribution wertet
   `meta.pagination` bis heute nirgends aus; Listen liefern die erste Seite.
   Storage erbt dieses Verhalten unverändert. Eine Änderung wäre eine
   API-weite Entscheidung.
6. **`Net::Async::Hetzner`-Unterstützung für Storage** — nur auf ausdrücklichen
   Wunsch, und dann als Ticket auf dem Board von `p5-net-async-hetzner`. Diese
   Spec ändert den Request/Response-Vertrag nicht (E3) und erzwingt dort nichts.

Grund für diesen Schnitt: Runde 1 ist eine vollständige, in sich sinnvolle
Ressource — man kann eine Storage Box anlegen, beschreiben, umtypisieren,
schützen, ihr Passwort setzen, Snapshot-Pläne steuern und sie löschen. Die beiden
Untergruppen verdoppeln den Aufwand (je Controller, Entity, CLI-Baum, Fixtures,
Test) und bringen bis dahin keinen der Grundpfade zum Laufen. Und ein Ticket, das
"Cloud-Namensraum-Umbau plus drei Ressourcen plus zwei CLI-Ebenen" heisst, ist
nicht mehr reviewbar.

## Architektur

### Neue Module

```
lib/WWW/Hetzner/Storage.pm                       # Client, base_url api.hetzner.com/v1
lib/WWW/Hetzner/Storage/API/StorageBoxes.pm      # Controller
lib/WWW/Hetzner/Storage/API/StorageBoxTypes.pm   # Controller (read-only)
lib/WWW/Hetzner/Storage/API/Actions.pm           # Controller, poll_path /storage_boxes/actions
lib/WWW/Hetzner/Storage/StorageBox.pm            # Entity
lib/WWW/Hetzner/Storage/StorageBoxType.pm        # Entity
lib/WWW/Hetzner/CLI/Cmd/StorageBox.pm            # CLI-Zweig
lib/WWW/Hetzner/CLI/Cmd/StorageBox/Cmd/*.pm      # 14 Subcommands
```

Aus E4, in einem vorgelagerten Ticket:

```
lib/WWW/Hetzner/Action.pm                        # ex Cloud/Action.pm
lib/WWW/Hetzner/Role/HasAction.pm                # ex Cloud/Role/HasAction.pm
lib/WWW/Hetzner/Role/HasActions.pm               # ex Cloud/Role/HasActions.pm
```

### Namensgebung im Mesh

Die Distribution bildet Ressourcenwurzel, Accessor, Controller, Entity und
Fixture eins zu eins aufeinander ab (`/floating_ips` → `$cloud->floating_ips` →
`API::FloatingIPs` → `FloatingIP` → `floating_ips_list.json`). Storage folgt dem
ohne Ausnahme:

| Ressourcenwurzel | Accessor | Controller | Entity |
|---|---|---|---|
| `storage_boxes` | `$storage->storage_boxes` | `API::StorageBoxes` | `StorageBox` |
| `storage_box_types` | `$storage->storage_box_types` | `API::StorageBoxTypes` | `StorageBoxType` |
| `storage_boxes/actions` | `$storage->actions` | `API::Actions` | `WWW::Hetzner::Action` |
| (vertagt) `subaccounts` | `$box->subaccounts` | `API::Subaccounts` | `Subaccount` |
| (vertagt) `snapshots` | `$box->snapshots` | `API::Snapshots` | `Snapshot` |

Verworfen: das kürzere `$storage->boxes` / `API::Boxes` / `Storage::Box`. Liest
sich besser, bricht aber die Eins-zu-eins-Abbildung, die das Mesh vorhersagbar
macht — und damit die Regel, nach der man von einem Pfad auf den Klassennamen und
den Fixture-Namen schliessen kann.

### Actions in Storage

Jede mutierende Storage-Operation gibt ein `WWW::Hetzner::Action` zurück, wie in
Cloud (karr #2, E1: die Bibliothek wartet nicht ungefragt). `create` gibt weiter
das Entity zurück, das die erzeugende Action als `->action` trägt (karr #2, E3);
`->next_actions` bleibt leer, weil die API keine liefert.

`Storage::API::StorageBoxes` konsumiert `WWW::Hetzner::Role::HasActions` und setzt
beim Wrappen `poll_path => '/storage_boxes/actions'`. `Storage::StorageBox`
konsumiert `WWW::Hetzner::Role::HasAction`.

Das ist die einzige Stelle, an der Storage vom Cloud-Verhalten abweicht — und sie
ist ein Attributwert, keine Sonderbehandlung.

## Betroffener Bestand

| Ort | Änderung | Umfang |
|---|---|---|
| `lib/WWW/Hetzner.pm` | `storage`-Attribut aktivieren (`:84`), DESCRIPTION (`:53`), Klassenlisten | 1 Datei |
| `lib/WWW/Hetzner/Storage*` | neu | 6 Dateien |
| `lib/WWW/Hetzner/CLI.pm` | `storage`-Attribut, Kommandoliste in `execute` und POD | 1 Datei |
| `lib/WWW/Hetzner/CLI/Cmd/StorageBox*` | neu | 15 Dateien |
| `bin/hcloud.pl` | Alias-Tabelle (`:11`), `%custom_help` (`:34`), POD | 1 Datei |
| `t/lib/Test/WWW/Hetzner/Mock.pm` | `mock_storage` plus Export | 1 Datei |
| `t/fixtures/storage_box*` | neu | 9 Dateien |
| `t/*.t` | neu | 3 Dateien |
| `Changes` | Storage-Eintrag unter `{{$NEXT}}` | 1 |

Aus dem vorgelagerten E4-Ticket zusätzlich: Verschiebung dreier Dateien und
Anpassung ihrer Konsumenten (8 Entities, 8 Controller, `Cloud.pm`,
`CLI/Role/WaitsForAction.pm`, `t/cloud_actions.t` und die betroffenen
`t/cloud_*.t`), sowie die Korrektur der Klassennamen im `{{$NEXT}}`-Block von
`Changes`.

Keine brechende Änderung an der öffentlichen API gegenüber `0.100`: Storage ist
rein additiv, und die Action-Verschiebung betrifft ausschliesslich
unveröffentlichten Code.

## Tests

Neu, gegen die Mock-Fixture-Harness, ohne Netz:

`t/storage_boxes.t`

1. `list` liefert `StorageBox`-Objekte aus `storage_boxes_list.json`
2. `get` liefert ein Objekt; Attribute inklusive der nullable Felder
   (`snapshot_plan`, `username`, `server`, `system`) tragen `undef` sauber
3. `create` schickt die vier Pflichtfelder im Body (Coderef-Route prüft
   `$opts{body}`) und gibt ein Entity zurück, dessen `->action` gesetzt ist
4. `delete` gibt eine Action zurück, nicht `undef` — die API antwortet mit 201
   plus `{action}`, nicht mit 204
5. je eine Runde für die sieben Box-Actions: richtiger Pfad, richtiger Body,
   `Action`-Rückgabe
6. `folders` gibt ein Arrayref von Strings zurück, keine Objekte
7. `_check_auth`: ein Client ohne Token stirbt mit dem Storage-Hinweistext,
   bevor irgendein Request gebaut wird

`t/storage_box_types.t`

8. `list`, `get`, `get_by_name`; `deprecation` als nullable Feld

`t/storage_actions.t`

9. `poll_path` ist `/storage_boxes/actions` — `refresh` fragt diesen Pfad ab und
   **nicht** den abgekündigten `/storage_boxes/{id}/actions/{action_id}`
10. `wait` Erfolgspfad `running` → `success` über den injizierten `sleeper`,
    ohne eine echte Sekunde
11. `wait` Fehlerpfad croakt mit `action.error.message`
12. `$storage->actions->get($id)` und `->list`

Ausserdem in `t/basic.t`: die neuen Module laden.

Die Fixture-Werte stammen aus den `examples` der `hetzner.spec.json`.

## Nicht im Umfang

- Robot-Ressourcen (karr #4), read-only Cloud-Controller (karr #3)
- Object Storage (S3) — anderer Dienst, andere Schnittstelle, nicht Teil von
  `api.hetzner.com`
- Änderungen an `_build_request`/`_parse_response`-Form und damit an
  `p5-net-async-hetzner`
- Kein Release. Das entscheidet der Maintainer gesondert.

## Offene Fragen für den Maintainer

1. **E4, Verschiebung von `Action` aus dem Cloud-Namensraum.** Die Empfehlung ist
   ja, und zwar jetzt, weil die Klasse unveröffentlicht ist. Sie berührt aber
   rund zwanzig Dateien in einem Baum, an dem parallel gearbeitet wird, und
   braucht ein eigenes vorgelagertes Ticket. Fällt die Entscheidung gegen die
   Verschiebung, benutzt Storage `WWW::Hetzner::Cloud::Action` über die
   Namensraumgrenze — das ist die einzige Stelle, an der diese Spec eine
   Alternative wirklich offenhält.
2. **E7, Schnitt.** Subaccounts und Snapshots in Runde 1 oder als Folgetickets?
   Die Empfehlung ist Folgetickets; wenn Storage in einem Zug fertig sein soll,
   verdreifacht sich der Umfang.
3. **E5, CLI-Ort.** `hcloud.pl storage-box` folgt der 1:1-Leitlinie in
   `CLI.pm`. Falls diese Leitlinie inzwischen anders gemeint ist als sie
   dasteht, wäre `bin/hstorage.pl` die Alternative — dann bitte vor der
   Implementierung sagen, es hängt der ganze CLI-Zweig daran.
4. **E2, Env-Variable.** `HETZNER_API_TOKEN` auch für Storage. Belegt ist, dass
   es derselbe Token ist; nicht belegbar ist, ob je ein Anwender getrennte Tokens
   für die beiden Hosts *will*.
5. **Rate Limit.** Beide Spezifikationen nennen 3600 Requests/Stunde und Projekt,
   keine sagt, ob Cloud und `api.hetzner.com` sich dieses Kontingent teilen. Für
   diese Implementierung folgenlos (es wird kein Backoff gebaut), aber es
   bedeutet, dass ein Storage-Poll im Zweifel Cloud-Budget verbraucht. Nicht
   geraten, hier festgehalten.
6. **Kein Zugriff auf eine echte Storage Box zur Gegenprobe.** Alles oben stammt
   aus der offiziellen Spezifikation, nichts aus einem Live-Aufruf — Tests dürfen
   das Netz nicht anfassen, und ein "kurzer Live-Check" gegen einen echten
   Account kann echte Infrastruktur anlegen. Falls der Maintainer eine
   Test-Storage-Box hat, wäre eine einmalige Gegenprobe der `create`-Antwort
   wertvoll; nötig ist sie nicht.
