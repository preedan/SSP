# Optimierung Schritt für Schritt

Übersicht der UX-Optimierungen als abarbeitbare Schritte. Pro Schritt: klarer Umfang, betroffene Dateien, „fertig wenn …“.

---

## Wie wir vorgehen

- **Ein Schritt = eine Änderungseinheit.** Du sagst z. B. „Schritt 2 umsetzen“, dann setzen wir nur das um.
- Nach jedem Schritt: testen, ggf. commit, dann weiter.
- Optional: Bei jedem Schritt in dieser Datei `[ ]` → `[x]` abhaken.

---

## Schritt 1: Gemeinsame Mini-Navigation ✅

**Ziel:** Auf allen relevanten Seiten dieselbe kleine Nav – Orientierung „Wo bin ich, wo kann ich hin?“.

**Inhalt:**
- Links: **Start** (index.html) | **Varianten** (Übersicht + Ermitteln, z. B. zwei Links oder ein Dropdown) | **Meine Teams** (nur wenn eingeloggt)
- Rechts: **Anmelden** (wenn nicht eingeloggt) bzw. **Profil** + **Abmelden** (wenn eingeloggt)

**Betroffene Dateien:**  
Alle HTML-Seiten außer login.html und profil.html (dort nur „Zurück“ beibehalten). Evtl. eine gemeinsame nav-Snippet-Datei oder gleicher HTML-/JS-Block auf jeder Seite.

**Fertig wenn:** Auf Startseite, Übersicht, Ermitteln, Teams, team-beitreten die gleiche Nav sichtbar ist und alle Links funktionieren.

**Umsetzung:** `nav.js` erstellt (Nav-Bar mit Auth, aktueller Link hervorgehoben); `#app-nav` + `nav.js` auf index, uebersicht, ermitteln, teams, team-beitreten eingebaut; einzelne „Zurück zur Startseite“-Links dort entfernt. Login und Profil unverändert (keine Nav).

---

## Schritt 2: Profil – Kontext bei Redirect

**Ziel:** Wenn jemand per Redirect auf die Profil-Seite kommt, erklären wir kurz warum.

**Inhalt:**
- `profil.html`: Redirect-Parameter auslesen (`?redirect=teams.html` oder `?redirect=team-beitreten.html?team=…`).
- Anzeige: z. B. „Du wolltest zu **Meine Teams** (bzw. **Team beitreten**). Dafür brauchen wir noch deinen Anzeigenamen.“
- Mapping: `teams.html` → „Meine Teams“, `team-beitreten.html` → „Team beitreten“, sonst „weiter“ o. ä.

**Betroffene Dateien:**  
`profil.html` (HTML-Text + ggf. kleines JS für Redirect-Label).

**Fertig wenn:** Aufruf von teams.html ohne Profil → Redirect zu profil.html → Nutzer sieht den Kontextsatz mit „Meine Teams“; bei team-beitreten mit ?team=… entsprechend „Team beitreten“.

---

## Schritt 3: Startseite – Nutzen von Login erklären

**Ziel:** Gäste verstehen, warum sie sich anmelden sollen.

**Inhalt:**
- Unter oder neben dem Bereich mit „Anmelden“ / „Meine Teams“ einen kurzen Satz: z. B. „Teams erstellen, Freunde einladen und Runden festhalten.“

**Betroffene Dateien:**  
`index.html`.

**Fertig wenn:** Als Gast auf der Startseite der Nutzen von Login sichtbar ist; als eingeloggter Nutzer stört der Satz nicht (z. B. nur bei „Anmelden“ anzeigen oder dezent für alle).

---

## Schritt 4: Teams-Seite – „Spielen“ als Hauptaktion vorbereiten

**Ziel:** Klare Hierarchie: Hauptaktion = „Mit diesem Team spielen“ (später), Einladung/Löschen sekundär.

**Inhalt:**
- Pro Team einen Button/Link **„Mit diesem Team spielen“** (zunächst Link zu `spielen.html?team=UUID`; Spielen-Seite kann noch Platzhalter sein).
- Optisch: „Spielen“ als primärer Button (z. B. kräftiger), „Einladungslink kopieren“ und „Team löschen“ als Sekundäraktionen (kleiner oder weniger dominant).

**Betroffene Dateien:**  
`teams.html`. Optional: `spielen.html` als Platzhalter-Seite anlegen („Spielen – kommt demnächst“ oder direkt mit Schritt 5).

**Fertig wenn:** Auf der Teams-Seite pro Team „Mit diesem Team spielen“ sichtbar und klickbar ist; Einladung/Löschen weiter nutzbar, aber visuell nachgeordnet.

---

## Schritt 5: Spielen-Seite (MVP)

**Ziel:** Eine Seite, auf der man für ein Team eine Session starten, Runden eintragen und die Session beenden kann.

**Inhalt:**
- URL: `spielen.html?team=UUID`. Ohne Team oder ungültiges Team: Fehlermeldung / Redirect zu teams.html.
- Session starten: Titel eingeben → Insert in `sessions`.
- Runden: Variante wählen, Gewinner (aus Team-`players`), optional Symbol/Notiz → Insert in `rounds`.
- Session beenden: Button → `sessions.ended_at` setzen.
- Backend: RPCs oder direkte Inserts mit RLS; neue RPCs z. B. `start_session`, `add_round`, `end_session` möglich.

**Betroffene Dateien:**  
Neue Seite `spielen.html`; evtl. neue SQL-RPCs; von teams.html bereits verlinkt (Schritt 4).

**Fertig wenn:** Team wählen → „Spielen“ → Session anlegen → mindestens eine Runde eintragen → Session beenden durchgängig funktioniert.

---

## Schritt 6: Aktuelles Team (optional)

**Ziel:** Beim Klick auf „Spielen“ das gewählte Team in localStorage speichern; Startseite zeigt „Weiterspielen mit [Teamname]“ und verlinkt zu spielen.html?team=UUID.

**Inhalt:**
- Beim Öffnen von spielen.html?team=UUID: `currentTeamId` und ggf. Teamname in localStorage schreiben.
- index.html: Wenn eingeloggt und currentTeamId gesetzt → Button/Link „Weiterspielen mit [Teamname]“ anzeigen, Link zu spielen.html?team=UUID.
- Optional: Auf teams.html „Spielen“ klicken setzt aktuelles Team; evtl. Möglichkeit, aktuelles Team zu clearen.

**Betroffene Dateien:**  
`spielen.html`, `index.html`, ggf. `teams.html`.

**Fertig wenn:** Nach einmal „Spielen“ mit Team X auf der Startseite „Weiterspielen mit X“ erscheint und zum gleichen Team führt.

---

## Schritt 7: Einheitliche „Zurück“-Links (optional)

**Ziel:** „Zurück“-Texte vereinheitlichen und an die Nav anbinden.

**Inhalt:**
- Einheitliche Formulierung (z. B. „Zurück zur Startseite“ oder „Zurück zu Meine Teams“ je nach Kontext) und gleiche Klasse/Stil wie Nav-Links.
- Login/Profil: „Zurück“ beibehalten, aber evtl. „Zurück zur Startseite“ statt nur „Zurück“.

**Betroffene Dateien:**  
Alle Seiten mit Zurück-Link.

**Fertig wenn:** Kein widersprüchlicher „Zurück“-Text mehr; Optik passt zur Nav.

---

## Reihenfolge (Kurz)

| # | Schritt | Abhängigkeit |
|---|--------|--------------|
| 1 | Mini-Navigation | – |
| 2 | Profil-Kontext | – |
| 3 | Startseite Nutzen Login | – |
| 4 | Teams: „Spielen“-Button + Hierarchie | – |
| 5 | Spielen-Seite MVP | Schritt 4 (Link vorhanden) |
| 6 | Aktuelles Team | Schritt 5 |
| 7 | Zurück-Links vereinheitlichen | Schritt 1 |

**Empfehlung:** 1 → 2 → 3 → 4 → 5 → 6 → 7. Du kannst jederzeit sagen: „Lass uns Schritt X umsetzen.“
