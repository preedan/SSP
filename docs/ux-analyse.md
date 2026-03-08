# UI/UX-Analyse – Schere, Stein, Papier

Bewertung der aktuellen App und Empfehlungen: Was am User Flow beibehalten werden sollte, was sich verbessern lässt.

---

## 1. Was bereits gut funktioniert

| Aspekt | Bewertung |
|--------|-----------|
| **Klare Trennung Gäste vs. angemeldet** | Varianten ohne Login, Teams/Spielen nur mit Profil – sinnvoll und verständlich. |
| **Redirect-Ketten** | Login → redirect, Profil → redirect verhindern „Land in der Leere“ nach Magic Link / Namensetzung. |
| **Einladungsflow** | team-beitreten.html?team=UUID ist eindeutig; Login/Profil werden sauber vorgeschaltet. |
| **Einheitliche Basis** | Baloo 2, #267bb5, abgerundete Buttons, Karten-Layout – wiedererkennbar. |
| **Owner + Löschen** | Nur Owner sieht „Team löschen“, Reduktion von Fehlklicks und Missverständnissen. |

**Fazit:** Der in der User-Flow-Datei beschriebene Ablauf (Einstieg → Login → Profil → Teams → Spielen) ist **inhaltlich stimmig**. Die folgenden Punkte betreffen vor allem **Darstellung, Navigation und mentale Modelle**, nicht die grundsätzliche Flow-Logik.

---

## 2. Schwächen und Risiken

### 2.1 Navigation: Kein gemeinsamer Anker

- Jede Seite hat einen anderen „Zurück“-Link (Startseite, Zurück, Zurück zur Startseite).
- Es fehlt eine **persistente Orientierung**: Wo bin ich? Wo kann ich hin?
- **Risiko:** Nutzer verlieren sich, besonders nach Team-Beitritt oder beim Wechsel zwischen „Varianten ansehen“ und „mit Team spielen“.

### 2.2 Zwei Welten ohne Brücke

- **Welt 1:** Varianten (Übersicht, Ermitteln) – spielerisch, ohne Account.
- **Welt 2:** Teams & Spielen – accountbasiert.
- Auf der Startseite stehen beide Welten gleichberechtigt nebeneinander; der **Nutzen von „Anmelden“** wird nicht erklärt („Spiele mit Freunden in Teams, halte Sessions fest“).
- **Risiko:** Gäste sehen keinen Grund, sich anzumelden.

### 2.3 Profil-Seite ohne Kontext

- „Wie sollen wir dich nennen?“ erscheint oft durch Redirect (z. B. von teams oder team-beitreten).
- Es fehlt ein kurzer Satz: **„Du wolltest zu [Meine Teams / Team beitreten] – dafür brauchen wir noch deinen Anzeigenamen.“**
- **Risiko:** Nutzer verstehen nicht, warum sie plötzlich einen Namen eingeben sollen.

### 2.4 Teams: Viel auf einer Seite

- „Neues Team erstellen“ und „Deine Teams“ (mit Owner, Einladung, Löschen) stehen auf einer Seite.
- Für „Spielen“ kommt ein weiterer Block hinzu („Mit diesem Team spielen“).
- **Risiko:** Die Seite wird voll; klare Priorität (erst Team wählen, dann spielen) ist nicht visuell geführt.

### 2.5 Kein „aktueller Kontext“ beim Spielen

- User Flow sieht vor: Team wählen → Session → Runden.
- Ohne **gespeichertes aktuelles Team** muss man bei jedem Besuch wieder wählen.
- **Risiko:** Friction, besonders wenn man oft mit demselben Team spielt.

---

## 3. Empfehlung: So die App aufsetzen

### 3.1 User Flow beibehalten – mit klaren Ergänzungen

Der **beschriebene User Flow** (Einstieg → Login → Profil → Teams → Spielen) soll **unverändert die fachliche Basis** bleiben. Darauf aufbauend:

1. **Einen klaren „Hauptpfad“ für eingeloggte Nutzer** definieren:  
   **Startseite → Meine Teams → [Team wählen] → Spielen (Session + Runden).**
2. **Varianten** bleiben der lockere Einstieg für alle; für Eingeloggte kann die Startseite zusätzlich **„Mit Team spielen“** anbieten (z. B. Link zu teams oder direkt zu spielen, wenn ein aktuelles Team gesetzt ist).
3. **Profil** nur beim ersten Mal erzwingen; danach über „Profil“ in der Navigation erreichbar, mit Kontext-Text wenn man per Redirect kommt.

### 3.2 Konkrete UX-Entscheidungen (als Update für user-flow.md)

| Thema | Empfehlung |
|-------|------------|
| **Spielen** | **Dedizierte Seite** `spielen.html?team=UUID`. Von „Meine Teams“ aus pro Team einen Button/Link **„Mit diesem Team spielen“**. Klar getrennt von Team-Verwaltung. |
| **Aktuelles Team** | **Optional** in `localStorage` speichern (z. B. `currentTeamId`). Auf der Startseite dann: „Weiterspielen mit [Teamname]“ → spielen.html?team=UUID. Kein Muss, aber starke UX-Verbesserung. |
| **Session-Liste** | **Später** umsetzen. Für MVP: Nur „Session starten → Runden eintragen → Session beenden“. Liste vergangener Sessions kann Phase 2 sein. |
| **Rollen** | Vorerst **nur** „Owner darf Team löschen“. Session starten dürfen alle Mitglieder. |

### 3.3 Navigation: Leichte Verbesserung ohne großen Aufwand

- **Kleine, einheitliche Navigation** auf allen Seiten (außer Login/Profil als Modalflow):
  - Links: **Start** | **Varianten** (Dropdown oder zwei Links: Übersicht, Ermitteln) | **Meine Teams** (nur wenn eingeloggt)
  - Rechts: **Anmelden** bzw. **Profil** + **Abmelden** wenn eingeloggt
- **„Zurück“-Links** beibehalten, aber einheitlich benennen (z. B. „Zurück zur Startseite“ oder „Zurück zu Meine Teams“) und optisch der gleichen Komponente zuordnen (z. B. gleiche Klasse wie die Nav-Links).
- So bleibt der Flow wie in der User-Flow-Datei, aber mit **einem erkennbaren Ort** für „Wo bin ich / wo kann ich hin?“.

### 3.4 Startseite: Nutzen von Login sichtbar machen

- Unter oder neben „Anmelden“ einen kurzen Hinweis:  
  **„Teams erstellen, Freunde einladen und Runden festhalten.“**
- Wenn eingeloggt: wie jetzt „Meine Teams“ + optional **„Weiterspielen mit [Teamname]“**, falls aktuelles Team gesetzt.

### 3.5 Profil mit Kontext

- Wenn Nutzer per **redirect** auf profil.html kommt:  
  **„Du wolltest zu [Meine Teams / Team beitreten]. Dafür brauchen wir noch deinen Anzeigenamen.“**  
  (Redirect-URL parsen und lesbar machen: z. B. „Meine Teams“ statt „teams.html“.)
- So bleibt der Flow (Redirect → Profil → zurück) gleich, aber mit **Erklärung**.

### 3.6 Teams-Seite entlasten (wenn „Spielen“ kommt)

- **Oberer Bereich:** „Neues Team erstellen“ (wie jetzt).
- **Liste:** Pro Team: Name, Owner, **„Spielen“** (primär), „Einladungslink“, „Löschen“ (nur Owner).
- **Spielen** als Hauptaktion hervorheben (z. B. kräftigerer Button), Einladung/Löschen als Sekundäraktionen (kleiner oder Icon).
- So bleibt der Flow „Team wählen → Spielen“ auf einer Seite klar, ohne die Seite zu überladen.

---

## 4. Kurzfassung: User Flow Datei vs. Aufsetzen der App

| Aspekt | In user-flow.md so lassen? | Anpassung in der App |
|--------|----------------------------|------------------------|
| Einstieg (Startseite, Varianten, Login) | ✅ Ja | Nur: Nutzen von Login erklären, ggf. „Weiterspielen mit …“. |
| Login → Profil → Teams / team-beitreten | ✅ Ja | Profil-Seite: Kontext-Text bei Redirect. |
| Teams (Liste, Owner, Einladung, Löschen) | ✅ Ja | Klare Hierarchie: „Spielen“ vor Einladung/Löschen; evtl. kleine Nav. |
| Spielen (Team → Session → Runden → Ende) | ✅ Ja | Wie im Flow: eigene Seite, Team per URL; optional aktuelles Team speichern. |
| Offene Punkte (Spielen, aktuelles Team, Session-Liste, Rollen) | ✅ Entscheidungen festhalten | Wie in Abschnitt 3.2 umsetzen und in user-flow.md unter „Offene Punkte“ abhaken. |

**Empfehlung:** Die App **genau entlang der User-Flow-Datei** aufsetzen, mit den obigen **UX-Ergänzungen** (Navigation, Kontext bei Profil, Nutzen von Login, klare Hauptaktion „Spielen“, optional aktuelles Team). Dann die getroffenen Entscheidungen in der User-Flow-Datei dokumentieren (inkl. Abschnitt „Offene Punkte“ aktualisieren).

---

## 5. Nächste Schritte (priorisiert)

1. **User-Flow-Datei aktualisieren:** Offene Punkte mit den Empfehlungen aus 3.2 abschließen.
2. **Profil:** Redirect-Kontext anzeigen („Du wolltest zu …“).
3. **Startseite:** Ein Satz zum Nutzen von Login; wenn eingeloggt + aktuelles Team: „Weiterspielen mit [Teamname]“ (optional, kann mit Spielen-Seite kommen).
4. **Gemeinsame Mini-Navigation** (Start | Varianten | Meine Teams | Anmelden/Profil) auf allen relevanten Seiten.
5. **Spielen-Seite** bauen (Team aus URL, Session starten, Runden, Session beenden); von teams.html aus „Mit diesem Team spielen“ verlinken.
6. Optional: **aktuelles Team** in localStorage; Startseite darauf reagieren.

Damit bleibt der User Flow die **einzige Quelle der Wahrheit** für den Ablauf, und die App setzt ihn mit besserer Orientierung und klaren Prioritäten um.
