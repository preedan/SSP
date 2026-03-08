-- ============================================================
-- SSP: Teams & Auth – Schema und RLS
-- Im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- ============================================================

-- 1) Spalte user_id in players (Verbindung zu Supabase Auth)
ALTER TABLE players
ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE;

CREATE UNIQUE INDEX IF NOT EXISTS players_user_id_key ON players(user_id);

COMMENT ON COLUMN players.user_id IS 'Supabase Auth User – ein Nutzer = ein Spieler';

-- 2) RLS aktivieren
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

-- 3) Policies: players (nur eigener Spieler)
DROP POLICY IF EXISTS "Users can read own player" ON players;
CREATE POLICY "Users can read own player" ON players
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own player" ON players;
CREATE POLICY "Users can insert own player" ON players
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own player" ON players;
CREATE POLICY "Users can update own player" ON players
  FOR UPDATE USING (auth.uid() = user_id);

-- 4) Policies: team_members (lesen/schreiben nur für eigene Beteiligung bzw. Team-Erstellung)
DROP POLICY IF EXISTS "Users can read own team_members" ON team_members;
CREATE POLICY "Users can read own team_members" ON team_members
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM players p
      WHERE p.id = team_members.player_id AND p.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own team_members" ON team_members;
CREATE POLICY "Users can insert own team_members" ON team_members
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM players p
      WHERE p.id = team_members.player_id AND p.user_id = auth.uid()
    )
  );

-- 5) Policies: teams (lesen nur, wenn man Mitglied ist; erstellen erlauben für angemeldete Nutzer)
DROP POLICY IF EXISTS "Users can read teams they belong to" ON teams;
CREATE POLICY "Users can read teams they belong to" ON teams
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM team_members tm
      JOIN players p ON p.id = tm.player_id AND p.user_id = auth.uid()
      WHERE tm.team_id = teams.id
    )
  );

DROP POLICY IF EXISTS "Authenticated users can create teams" ON teams;
CREATE POLICY "Authenticated users can create teams" ON teams
  FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Optional: teams aktualisieren nur, wenn Mitglied (für später: Team-Name ändern etc.)
DROP POLICY IF EXISTS "Users can update teams they belong to" ON teams;
CREATE POLICY "Users can update teams they belong to" ON teams
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM team_members tm
      JOIN players p ON p.id = tm.player_id AND p.user_id = auth.uid()
      WHERE tm.team_id = teams.id
    )
  );
