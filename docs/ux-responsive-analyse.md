# UI/UX: Responsive & User-Flow-Optimierung

## 1. Responsive – aktuelle Schwächen

| Bereich | Problem | Empfehlung |
|--------|--------|------------|
| **Navigation** | Viele Links (Start \| Übersicht \| Ermitteln \| Meine Teams \| Statistik \| Abmelden), kleine Klickflächen (padding 4px 8px). | Touch-Ziele mind. 44px; auf schmalen Screens Nav-Inhalt größer/gestapelt oder Hamburger. |
| **Teams – Pro Team** | 3 Buttons nebeneinander (Heute dieses Team, Einladungslink, Löschen) → auf Smartphone gedrängt, kleine Trefferfläche. | Auf schmalen Screens Buttons untereinander (flex-wrap + volle Breite), klare Reihenfolge: 1. Heute dieses Team, 2. Einladung, 3. Löschen. |
| **Statistik** | Tabellen können auf schmalen Screens überlaufen. | Container mit overflow-x: auto; Tabellen min-width oder Zellen umbrechen. |
| **Formulare (Sieger, Login, Profil)** | Inputs < 16px können auf iOS Zoomen auslösen. | font-size mind. 16px für inputs/selects. |
| **Allgemein** | Kein einheitlicher „safe area“ / Abstand zum Rand. | padding mit max() oder env(safe-area-inset) für Notch-Geräte. |

---

## 2. User-Flow – braucht es alle Buttons?

### Startseite
- **Gast:** Varianten Übersicht, Varianten ermitteln, Anmelden → sinnvoll.
- **Eingeloggt:** Zusätzlich Meine Teams, ggf. „Heute: X“ + Sieger eintragen. Redundanz: „Sieger eintragen“ ist nur sinnvoll, wenn ein Team gewählt ist; dann reicht ein klarer CTA. **Kein Überfluss.**

### Meine Teams (pro Team)
- **„Heute dieses Team“** – Kernaktion für den Spiel-Flow. **Behalten.**
- **„Einladungslink kopieren“** – selten, aber nötig. **Behalten**, aber sekundär (kleiner/Icon oder nach „Heute“).
- **„Team löschen“** – nur für Owner, destruktiv. **Behalten**, klar als Gefahrenaktion (rot).

**Optimierung:** Reihenfolge und Gewichtung: 1. Heute dieses Team (primär), 2. Einladungslink (sekundär), 3. Löschen (nur Owner, zurückhaltend). Auf Mobile: alle drei untereinander, damit nichts „klebt“.

### Navigation
- **Übersicht** und **Ermitteln** sind beide „Varianten“. Optional: ein Eintrag „Varianten“ mit Unterseiten oder Kombination auf einer Seite. Würde die Nav entlasten, ist aber inhaltliche Entscheidung. **Vorschlag:** vorerst so lassen, nur responsive machen; Zusammenlegung später möglich.

### Sieger eintragen
- Team (vorbelegt), Variante, Sieger, Symbol – alles nötig. **Kein Streichen.** Nur Darstellung mobil optimieren (volle Breite, 16px Inputs).

---

## 3. Umgesetzte Anpassungen (Code)

- **nav.js:** Größere Touch-Ziele (padding/min-height), auf kleinen Screens Links mit mehr Abstand/Zeilenumbruch.
- **teams.html:** Media Query: unter ~480px team-item-actions als Spalte (flex-direction: column), Buttons volle Breite; Reihenfolge: Heute → Einladung → Löschen.
- **statistik.html:** overflow-x: auto für Tabellen-Container; Filter-Bereich bricht sauber um.
- **Global:** Input/Select font-size mind. 16px wo nötig; container padding mit Rücksicht auf kleine Screens.

Diese Punkte sind im Code umgesetzt; weitere Wünsche (z. B. Hamburger-Nav, „Varianten“ zusammenführen) können darauf aufbauen.
