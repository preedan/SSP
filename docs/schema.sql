-- =========================================
-- SSP DATABASE SCHEMA
-- =========================================
-- Referenz für Cursor/Entwicklung. In Supabase bereits angelegt.
-- Ergänzungen (profiles, players.user_id): siehe supabase-teams-setup.sql

-- =========================================
-- 1️⃣ VARIANTS
-- =========================================
create table public.variants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null,
  image_url text,
  video_url text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);


-- =========================================
-- 2️⃣ TEAMS
-- =========================================
create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_by uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);


-- =========================================
-- 3️⃣ TEAM MEMBERS (user_id = Auth-Nutzer, nicht player_id)
-- =========================================
create table public.team_members (
  team_id uuid not null references public.teams(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  primary key (team_id, user_id)
);


-- =========================================
-- 4️⃣ PLAYERS (pro Team; name = Anzeigename im Team)
-- =========================================
create table public.players (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

-- Ergänzung: Verknüpfung Spieler ↔ Auth-User (ein User = ein Spieler pro Team)
-- ALTER TABLE public.players ADD COLUMN IF NOT EXISTS user_id uuid references auth.users(id) on delete cascade;
-- CREATE UNIQUE INDEX IF NOT EXISTS players_team_user_key ON public.players(team_id, user_id);


-- =========================================
-- 5️⃣ SESSIONS
-- =========================================
create table public.sessions (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  title text not null,
  started_at timestamptz not null default now(),
  ended_at timestamptz
);


-- =========================================
-- 6️⃣ ROUNDS
-- =========================================
create table public.rounds (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions(id) on delete cascade,
  variant_id uuid not null references public.variants(id),
  winner_player_id uuid references public.players(id),
  symbol text check (symbol in ('rock','paper','scissors') or symbol is null),
  note text,
  played_at timestamptz not null default now()
);


-- =========================================
-- INDEXES (Performance)
-- =========================================
create index idx_players_team on public.players(team_id);
create index idx_sessions_team on public.sessions(team_id);
create index idx_rounds_session on public.rounds(session_id);
create index idx_rounds_variant on public.rounds(variant_id);
create index idx_rounds_winner on public.rounds(winner_player_id);


-- =========================================
-- ERGÄNZUNGEN (Migrationen für Auth + Name)
-- =========================================
-- 1) Profiles: globaler Anzeigename pro User (jeder User braucht einen Namen)
-- create table public.profiles (
--   user_id uuid primary key references auth.users(id) on delete cascade,
--   display_name text not null,
--   created_at timestamptz not null default now()
-- );

-- 2) players.user_id: welcher Auth-User ist dieser Spieler (für Runden/Gewinner)
-- alter table public.players add column if not exists user_id uuid references auth.users(id) on delete cascade;
-- create unique index if not exists players_team_user_key on public.players(team_id, user_id);
