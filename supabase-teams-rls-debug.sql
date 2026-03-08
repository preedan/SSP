-- ============================================================
-- DEBUG: Nacheinander in Supabase SQL Editor ausführen
-- ============================================================

-- Schritt 1: Aktuelle Policies auf teams anzeigen
SELECT policyname, cmd, with_check FROM pg_policies WHERE schemaname = 'public' AND tablename = 'teams';

-- Schritt 2: INSERT-Policy TEMPORÄR sehr offen machen (nur zum Testen!)
-- Wenn Team-Erstellen DANACH funktioniert, liegt es an auth.uid() (wird nicht mitgeschickt).
DROP POLICY IF EXISTS "teams_insert_own" ON public.teams;
CREATE POLICY "teams_insert_own" ON public.teams FOR INSERT WITH CHECK (true);

-- Nach dem Test wieder die sichere Version setzen:
-- DROP POLICY IF EXISTS "teams_insert_own" ON public.teams;
-- CREATE POLICY "teams_insert_own" ON public.teams FOR INSERT WITH CHECK (created_by = auth.uid());
