# User Flow – Schere, Stein, Papier (SSP)

Übersicht aller Nutzerpfade und Entscheidungspunkte. Basis für UX und Implementierung.

---

## 1. Einstieg

```
                    ┌─────────────────┐
                    │   Startseite     │
                    │   (index.html)   │
                    └────────┬────────┘
                             │
         ┌───────────────────┼───────────────────┐
         ▼                   ▼                   ▼
  Varianten            Varianten            Anmelden /
  Übersicht            ermitteln            Meine Teams
  (uebersicht.html)    (ermitteln.html)     (login / teams)
```

- **Startseite:** Alle sehen „Varianten Übersicht“, „Varianten ermitteln“, plus bei Login „Meine Teams“ und „Abmelden“.
- **Varianten:** Ohne Anmeldung nutzbar (nur Lesen / Zufallsauswahl).
- **Teams & Spielen:** Nur für angemeldete Nutzer mit gesetztem Profil (Anzeigename).

---

## 2. Anmeldung & Onboarding

| Schritt | Seite / Aktion | Bedingung |
|--------|----------------|-----------|
| 1 | **Anmelden** (login.html) | Klick auf „Anmelden“ (z. B. von Startseite oder vor Team-Beitritt). |
| 2 | E-Mail eingeben → Magic Link per E-Mail | – |
| 3 | Link öffnen → eingeloggt | Session in Supabase Auth. |
| 4 | **Profil** (profil.html) | Wenn noch kein `display_name` in `profiles`: Redirect von teams / team-beitreten. |
| 5 | Anzeigename setzen → speichern | Danach: Zugriff auf Teams und Spielen. |

**Redirect-Kette:**  
`login.html?redirect=…` → nach Login zu `redirect`.  
`profil.html?redirect=teams.html` → nach Profil-Speichern zu `redirect`.

---

## 3. Teams

### 3.1 Meine Teams (teams.html)

- **Voraussetzung:** Eingeloggt + Profil mit Anzeigename.
- **Inhalt:**
  - Liste aller Teams, in denen der User Mitglied ist.
  - Pro Team: Name, **Owner** (wer es angelegt hat), „Einladungslink kopieren“, ggf. „Team löschen“ (nur für Owner).
- **Aktionen:**
  - Neues Team: Name eingeben → „Team erstellen“ (RPC `create_team`).
  - Einladungslink kopieren → Link an andere schicken (team-beitreten.html?team=UUID).

### 3.2 Team beitreten (team-beitreten.html)

- **Einstieg:** Einladungslink mit `?team=UUID`.
- **Ablauf:**
  1. Kein Login → Redirect zu login.html?redirect=team-beitreten.html?team=UUID.
  2. Login → zurück zu team-beitreten mit gleichem `team`.
  3. Kein Profil (kein Anzeigename) → Redirect zu profil.html?redirect=… .
  4. Profil vorhanden → Beitritt: Insert in `team_members` + `players` (Name aus Profil).
  5. Erfolg: „Du bist dem Team beigetreten“ / „Du bist bereits Mitglied“ → Link „Zu Meine Teams“.

---

## 4. Spielen (geplant)

Noch nicht umgesetzt; Flow als Zielbild:

| Schritt | Beschreibung |
|--------|--------------|
| 1 | **Team wählen** | Aus „Meine Teams“ oder von einer zentralen „Spielen“-Seite. Entweder Link „Mit diesem Team spielen“ (z. B. spielen.html?team=UUID) oder Merken des aktuellen Teams (z. B. localStorage). |
| 2 | **Session starten** | Titel eingeben (z. B. „Stammtisch 08.03.“) → Session in DB anlegen (`sessions`: team_id, title, started_at). |
| 3 | **Runden spielen** | Pro Runde: Variante wählen, Gewinner wählen (aus Team-Spielern), optional Symbol/Notiz → Insert in `rounds`. |
| 4 | **Session beenden** | Button „Session beenden“ → `sessions.ended_at` setzen. |
| 5 | **Statistik (später)** | Pro Team/Session: Siege pro Spieler, gespielte Varianten. |

---

## 5. Übersicht: Seiten & Zugriff

| Seite | URL | Ohne Login | Mit Login (ohne Profil) | Mit Profil |
|-------|-----|------------|--------------------------|------------|
| Startseite | index.html | ✅ | ✅ | ✅ |
| Varianten Übersicht | uebersicht.html | ✅ | ✅ | ✅ |
| Varianten ermitteln | ermitteln.html | ✅ | ✅ | ✅ |
| Anmelden | login.html | ✅ (Einstieg) | – | – |
| Profil | profil.html | Redirect → Login | ✅ (Anzeigename setzen) | ✅ |
| Meine Teams | teams.html | Redirect → Login | Redirect → Profil | ✅ |
| Team beitreten | team-beitreten.html?team=… | Redirect → Login | Redirect → Profil | ✅ |
| Spielen (geplant) | spielen.html?team=… | Redirect → Login | Redirect → Profil | ✅ |

---

## 6. Offene Punkte / Entscheidungen (Stand: UX-Entscheidungen)

- **Spielen:** ✅ **Dedizierte Seite** `spielen.html?team=UUID`. Von „Meine Teams“ aus pro Team: „Mit diesem Team spielen“ → diese Seite.
- **Aktuelles Team:** ✅ **Optional** in localStorage speichern; Startseite kann „Weiterspielen mit [Teamname]“ anbieten.
- **Session-Liste:** ✅ **Später.** MVP: nur Session starten → Runden eintragen → Session beenden.
- **Rollen:** ✅ Vorerst nur „Owner darf Team löschen“. Sessions starten dürfen alle Team-Mitglieder.

Details und weitere UI/UX-Empfehlungen: **docs/ux-analyse.md**.
