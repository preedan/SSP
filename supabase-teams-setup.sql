-- ============================================================
-- SSP: Auth, Profiles, Teams – Schema-Ergänzungen & RLS
-- Im Supabase Dashboard: SQL Editor → New query → einfügen → Run
-- Voraussetzung: Basis-Schema (variants, teams, team_members, players, sessions, rounds) existiert.
-- ============================================================

-- 1) PROFILES: Jeder User hat einen Anzeigenamen (Pflicht)
create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
create policy "Users can read own profile" on public.profiles
  for select using (auth.uid() = user_id);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
  for update using (auth.uid() = user_id);


-- 2) PLAYERS: user_id ergänzen (welcher Auth-User ist dieser Spieler im Team)
alter table public.players
  add column if not exists user_id uuid references auth.users(id) on delete cascade;

create unique index if not exists players_team_user_key on public.players(team_id, user_id);

comment on column public.players.user_id is 'Auth-User; ein User hat pro Team genau einen Spieler.';
comment on column public.players.name is 'Anzeigename im Team (z. B. aus profiles.display_name).';

alter table public.players enable row level security;

drop policy if exists "Users can read players in their teams" on public.players;
create policy "Users can read players in their teams" on public.players
  for select using (
    auth.uid() = user_id
    or exists (
      select 1 from public.team_members tm
      where tm.team_id = players.team_id and tm.user_id = auth.uid()
    )
  );

drop policy if exists "Users can insert own player in team" on public.players;
create policy "Users can insert own player in team" on public.players
  for insert with check (auth.uid() = user_id);

drop policy if exists "Users can update own player" on public.players;
create policy "Users can update own player" on public.players
  for update using (auth.uid() = user_id);


-- 3) TEAM_MEMBERS: Schema nutzt user_id (nicht player_id)
alter table public.team_members enable row level security;

drop policy if exists "Users can read own team_members" on public.team_members;
create policy "Users can read own team_members" on public.team_members
  for select using (auth.uid() = user_id);

drop policy if exists "Users can insert own team_members" on public.team_members;
create policy "Users can insert own team_members" on public.team_members
  for insert with check (auth.uid() = user_id);


-- 4) TEAMS: created_by setzen; lesen wenn Mitglied
alter table public.teams enable row level security;

drop policy if exists "Users can read teams they belong to" on public.teams;
create policy "Users can read teams they belong to" on public.teams
  for select using (
    exists (
      select 1 from public.team_members tm
      where tm.team_id = teams.id and tm.user_id = auth.uid()
    )
  );

drop policy if exists "Authenticated users can create teams" on public.teams;
create policy "Authenticated users can create teams" on public.teams
  for insert with check (created_by = auth.uid());

drop policy if exists "Users can update teams they belong to" on public.teams;
create policy "Users can update teams they belong to" on public.teams
  for update using (
    exists (
      select 1 from public.team_members tm
      where tm.team_id = teams.id and tm.user_id = auth.uid()
    )
  );
