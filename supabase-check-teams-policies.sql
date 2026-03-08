-- ============================================================
-- In Supabase: SQL Editor → New query → einfügen → Run
-- Zeigt: Ist RLS an? Welche Policies gibt es auf public.teams?
-- ============================================================

-- 1) Ist RLS für public.teams aktiv?
SELECT relname AS table_name, relrowsecurity AS rls_enabled
FROM pg_class
WHERE relname = 'teams' AND relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

-- 2) Alle Policies auf public.teams (Name, Kommando, Bedingung)
SELECT policyname, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'teams' AND schemaname = 'public';
