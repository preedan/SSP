-- ============================================================
-- SSP: Team-Mitglieder dürfen Spieler im Team anlegen (ohne user_id)
-- Im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- Voraussetzung: supabase-teams-setup.sql wurde ausgeführt.
-- ============================================================
-- Ermöglicht den Button "Spieler anlegen und hinzufügen" in teams.html:
-- Jedes Team-Mitglied kann in seinen Teams weitere Spieler (nur Name, user_id = null) anlegen.

drop policy if exists "Users can insert own player in team" on public.players;
create policy "Users can insert own player in team" on public.players
  for insert with check (
    auth.uid() = user_id
    or exists (
      select 1 from public.team_members tm
      where tm.team_id = players.team_id and tm.user_id = auth.uid()
    )
  );
