-- Einmal ausführen: RLS für teams INSERT (erlaubt nur Zeilen mit created_by = aktueller User)
-- Im Supabase Dashboard: SQL Editor → New query → einfügen → Run

DROP POLICY IF EXISTS "Authenticated users can create teams" ON public.teams;
CREATE POLICY "Authenticated users can create teams" ON public.teams
  FOR INSERT WITH CHECK (created_by = auth.uid());
