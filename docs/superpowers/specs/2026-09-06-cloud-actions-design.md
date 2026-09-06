# Design: Cloud Actions

- Ticket: karr #2 (Board `WWW-Hetzner`)
- Datum: 2026-09-06
- Status: genehmigt, Implementierungsplan ausstehend

## Problem

Die Hetzner Cloud API antwortet auf jeden mutierenden Aufruf mit einer Action —
einem asynchronen Vorgang mit eigenem Status. `WWW::Hetzner` wirft diese
Information heute weg oder reicht sie unbearbeitet durch:

- `Cloud/API/Servers.pm:208` gibt nur `$result->{server}` zurück; `action` und
  `next_actions` fallen unter den Tisch.
- `Cloud/API/Servers.pm:234` und die übrigen 37 Aktionsmethoden geben den rohen
  dekodierten Hashref `{action => {...}}` durch.
- `Role/HTTP.pm:200` croakt ausschliesslich bei HTTP-Status ausserhalb 2xx. Eine
  fehlgeschlagene Action kommt aber als **HTTP 201 mit `action.status ==
  "error"`** und läuft damit vollständig am Fehlerpfad vorbei.

Folge: Ein `create`, dessen Action scheitert, ist von einem erfolgreichen nicht
zu unterscheiden. `CLI/Cmd/Server/Cmd/Poweron.pm:20` druckt `"Server powered
on."`, bevor die Action überhaupt begonnen hat.

Das einzige Warten ist `wait_for_status` (`Cloud/API/Servers.pm:488`). Es pollt
den Server-Status, nicht die Action, existiert nur für Server und sagt nichts
darüber, warum ein Vorgang scheiterte.

## Entscheidungen

Vier Festlegungen, jeweils mit dem Grund, der sie getragen hat.

### E1 — Die Bibliothek wartet nicht ungefragt

Mutierende Aufrufe geben ein `Action`-Objekt zurück und schlafen nicht. Wer
warten will, ruft `->wait`.

Grund: Eine Bibliothek, die in `create` heimlich schläft, ist überraschend, und
`wait_for_status` ist der Präzedenzfall für *bewusst angefordertes* Warten.

Verworfene Alternative: blockierend per Default mit `wait => 0` als Opt-out. Das
löst das Fehlerproblem zwar ohne Zutun des Aufrufers, ändert aber das
Zeitverhalten jedes bestehenden Aufrufs.

Ausdrücklich **nicht** tragend war die anfangs angeführte Parität mit
`p5-net-async-hetzner`. Die Prüfung ergab: `Net::Async::Hetzner::Cloud`
implementiert `Role::IO` nicht, sondern instanziiert intern ein
`WWW::Hetzner::Cloud` und borgt sich daraus nur `_build_request` und
`_parse_response` (`Net/Async/Hetzner/Cloud.pm:100` und `:103`). Es gibt dort
weder Controller noch Entities — also auch keine Objektform, die in Parität zu
halten wäre.

### E2 — Das blockierende Warten gehört in die CLI

`hcloud.pl` wartet per Default und bietet `--no-wait`. Dort sitzt der Anwender,
der das Ergebnis sehen will; die Bibliothek bleibt ehrlich.

### E3 — `create` gibt weiterhin das Entity zurück

Das Entity trägt die erzeugende Action als Attribut `action`, die Folgeaktionen
als `next_actions`. Bestehende `create`-Aufrufe brechen nicht.

Verworfen: ein eigenes `Result`-Objekt mit `->server`/`->action` (bricht jeden
`create`-Aufruf über alle Ressourcen hinweg) und eine `wantarray`-Rückgabe
(kontextabhängige Rückgaben sind eine Fehlerquelle, die man später bereut).

### E4 — Injizierbarer Sleeper

Der Client bekommt ein `sleeper`-Attribut, Default `sub { sleep $_[0] }`. Tests
schieben eine Zähl-Closure hinein.

Grund: Intervall- **und** Timeout-Pfad werden ohne Wanduhr testbar, und die
Anzahl der Polls ist prüfbar. Ein Timeout-Test, der echte Sekunden braucht, ist
ein flaky Test.

## Architektur

### Neue Klassen

**`WWW::Hetzner::Cloud::Action`** — Entity nach dem Muster von
`WWW::Hetzner::Cloud::Server`: `client` als `weak_ref`, dazu die Attribute
`id`, `command`, `status`, `progress`, `started`, `finished`, `resources`,
`error`.

| Methode | Verhalten |
|---|---|
| `is_running` / `is_success` / `is_error` | Status-Prädikate |
| `error_message` | `error.message` oder `undef` |
| `refresh` | Neu laden über `poll_path` |
| `wait(%opts)` | Pollt bis Endzustand |
| `data` | Rohdaten, wie bei den übrigen Entities |

`wait` nimmt `interval` (Default 1) und `timeout` (Default 120, konsistent zu
`wait_for_status`). Es croakt bei `status eq 'error'` mit der API-Meldung und
bei Zeitüberschreitung mit Action-Id und Kommando.

**`WWW::Hetzner::Cloud::API::Actions`** — Controller mit `get($id)` und
`list(%params)`.

### Der Poll-Pfad

Die `Action` erhält ihren Poll-Pfad vom erzeugenden Controller als Attribut
`poll_path`. `refresh` hängt `/$id` daran.

Das ist bewusst so gebaut, weil **ungeklärt ist, ob Hetzner den globalen
Endpunkt `/actions/{id}` zugunsten der ressourcenspezifischen
(`/servers/actions/{id}`) abgekündigt hat**. Siehe Abschnitt „Vor der
Implementierung zu klären". Mit `poll_path` ist die Antwort eine Zeile pro
Controller statt eines Umbaus.

### Neue Rollen

**`WWW::Hetzner::Cloud::Role::HasActions`** — liefert `_wrap_action`, konsumiert
von den 8 Controllern, die Actions erzeugen. Additiv; die bestehenden
`_wrap`/`_wrap_list` in den Controllern bleiben unangetastet.

**`WWW::Hetzner::Cloud::Role::HasAction`** — liefert Entities die Attribute
`action` und `next_actions`.

Konsumiert von genau **sechs** Entities, nämlich denen, deren
`create`-Antwort laut Fixture eine Action enthält: `Certificate`, `FloatingIP`,
`LoadBalancer`, `PrimaryIP`, `Server`, `Volume`.

Nicht konsumiert von `Firewall`, `Network`, `PlacementGroup`, `RRSet`, `Zone` —
deren `create`-Fixtures enthalten keine Action. Für `Firewall` ist das vor der
Implementierung gegenzuprüfen (siehe unten).

`action` ist der Zustand zum Zeitpunkt der Erzeugung. Nach `->refresh` ist es
`undef`. Das steht so in der POD.

**`WWW::Hetzner::CLI::Role::WaitsForAction`** — liefert die Option `--no-wait`
und einen `handle_action`-Helfer. Es gibt keine CLI-Basisklasse; jedes Kommando
ist eigenständig `MooX::Cmd` plus `MooX::Options`, und `MooX::Options` erlaubt
das Bereitstellen von Optionen aus einer Rolle.

### Sleeper

`sleeper` wird auf `WWW::Hetzner::Role::HTTP` gelegt, nicht auf `Cloud` —
additiv, und `Robot` erbt es für das spätere `boot`-Polling aus karr #4.

`is => 'rw'` mit Default `sub { sleep $_[0] }`, damit Tests es nach dem Bau
setzen können und `mock_cloud` nicht umgebaut werden muss.

## Betroffener Bestand

| Ort | Änderung | Umfang |
|---|---|---|
| `Cloud/API/*.pm` | Aktionsmethoden geben `Action` statt Hashref | 38 Methoden, 8 Dateien |
| `Cloud/*.pm` (Entities) | gespiegelte Aktionsmethoden ebenso | 28 Methoden, 8 Dateien |
| `Cloud/*.pm` (Entities) | `HasAction` konsumieren | 6 Dateien |
| `Cloud.pm` | `actions`-Attribut für den neuen Controller | 1 |
| `CLI/Cmd/**` | `WaitsForAction` konsumieren | mutierende Subcommands |
| `Role/HTTP.pm` | `sleeper`-Attribut | 1 |
| `t/cloud_*.t` | `$result->{action}{command}` wird `$result->action->command` | ca. 6 Dateien |

`wait_for_status` bleibt unverändert; seine POD verweist zusätzlich auf `->wait`.

### Brechende Änderung

Die 66 Aktionsmethoden geben statt `{action => {...}}` ein `Action`-Objekt
zurück. Bei Version 0.100 vertretbar, gehört aber als solche in `Changes`.

Die CLI ist davon nicht betroffen: sie verwirft die Rückgabewerte heute
ohnehin (`CLI/Cmd/Server/Cmd/Poweron.pm:18`).

## Tests

Neu `t/cloud_actions.t`, gegen die Mock-Fixture-Harness, ohne Netz:

1. Entity-Attribute und Prädikate aus der Fixture
2. `refresh` lädt neu
3. `wait` Erfolgspfad: `running` → `running` → `success`
4. `wait` Fehlerpfad: croakt mit der Meldung aus `action.error.message`
5. `wait` Timeout: croakt mit Action-Id und Kommando
6. Poll-Anzahl über den injizierten Sleeper, **ohne eine echte Sekunde**

Neue Fixtures `actions_get.json` und `actions_list.json` in den Zuständen
`running`, `success` und `error`. Aktions-Fixtures für Ressourcen existieren
bereits (`networks_action.json`, `firewalls_action.json` und weitere).

Die Mock-Harness bleibt unverändert: `Test::WWW::Hetzner::MockIO` akzeptiert
schon Coderef-Handler (`t/lib/Test/WWW/Hetzner/Mock.pm:56`), womit sich eine
Folge wechselnder Antworten für denselben Pfad abbilden lässt.

## Nicht im Umfang

- Robot-Ressourcen (karr #4), Storage Boxes (karr #5), read-only Controller
  (karr #3)
- `_build_request` und `_parse_response` werden **in ihrer Form nicht
  angefasst**. Damit bleibt `p5-net-async-hetzner` unberührt und es braucht kein
  Ticket auf dessen Board. Sollte sich das beim Bauen doch ergeben: anhalten und
  dort ein Ticket anlegen — niemals ein stiller Cross-Repo-Edit.
- Kein Release. Das entscheidet der Maintainer gesondert.

## Vor der Implementierung zu klären

Zwei Punkte, die gegen die aktuelle Hetzner-API-Dokumentation zu prüfen sind und
die hier bewusst nicht geraten werden:

1. **Poll-Endpunkt.** Ist der globale `/actions/{id}` noch aktuell, oder gilt
   nur noch `/{resource}/actions/{id}`? Bestimmt die `poll_path`-Werte.
2. **Firewall-`create`.** Die Fixture enthält keine Action, die echte API
   antwortet nach meiner Erinnerung aber mit `actions` im Plural. Falls ja,
   bekommt `Firewall` eine eigene Behandlung statt `HasAction`.
