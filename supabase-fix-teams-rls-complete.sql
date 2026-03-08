-- ============================================================
-- Teams RLS komplett setzen (einmal im SQL Editor ausführen)
-- Entfernt alle bestehenden Policies auf teams und legt die richtigen neu an.
-- ============================================================

-- RLS aktivieren
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;

-- Alle bestehenden Policies auf teams löschen (Namen können variieren)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (SELECT policyname FROM pg_policies WHERE schemaname = 'public' AND tablename = 'teams')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.teams', r.policyname);
  END LOOP;
END $$;

-- SELECT: User sieht nur Teams, in denen er Mitglied ist
CREATE POLICY "teams_select_member"
  ON public.teams FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.team_members tm
      WHERE tm.team_id = teams.id AND tm.user_id = auth.uid()
    )
  );

-- INSERT: Nur Zeilen erlauben, bei denen created_by = aktueller User
CREATE POLICY "teams_insert_own"
  ON public.teams FOR INSERT
  WITH CHECK (created_by = auth.uid());

-- UPDATE: Nur wenn User Mitglied des Teams ist
CREATE POLICY "teams_update_member"
  ON public.teams FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.team_members tm
      WHERE tm.team_id = teams.id AND tm.user_id = auth.uid()
    )
  );
