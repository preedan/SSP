-- ============================================================
-- RPC: create_team – Team erstellen ohne RLS-Problem
-- Die Funktion läuft mit SECURITY DEFINER und setzt created_by aus dem JWT.
-- Einmal im Supabase SQL Editor ausführen.
-- ============================================================

CREATE OR REPLACE FUNCTION public.create_team(team_name text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid;
  disp_name text;
  new_team_id uuid;
BEGIN
  -- User aus JWT oder auth.uid()
  uid := COALESCE((auth.jwt() ->> 'sub')::uuid, auth.uid());
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Anzeigename aus profiles
  SELECT display_name INTO disp_name FROM public.profiles WHERE user_id = uid;
  disp_name := COALESCE(disp_name, 'Spieler');

  INSERT INTO public.teams (name, created_by) VALUES (team_name, uid) RETURNING id INTO new_team_id;
  INSERT INTO public.team_members (team_id, user_id) VALUES (new_team_id, uid);
  INSERT INTO public.players (team_id, user_id, name) VALUES (new_team_id, uid, disp_name);

  RETURN new_team_id;
END;
$$;

-- Ausführung erlauben (anon = mit JWT, authenticated falls verwendet)
GRANT EXECUTE ON FUNCTION public.create_team(text) TO anon;
GRANT EXECUTE ON FUNCTION public.create_team(text) TO authenticated;

-- ============================================================
-- RPC: delete_team – Nur Team-Owner darf löschen
-- ============================================================

CREATE OR REPLACE FUNCTION public.delete_team(team_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid;
  owner_id uuid;
BEGIN
  uid := COALESCE((auth.jwt() ->> 'sub')::uuid, auth.uid());
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT created_by INTO owner_id FROM public.teams WHERE id = team_id;
  IF owner_id IS NULL THEN
    RAISE EXCEPTION 'Team nicht gefunden';
  END IF;
  IF owner_id != uid THEN
    RAISE EXCEPTION 'Nur der Ersteller des Teams darf es löschen';
  END IF;

  DELETE FROM public.teams WHERE id = team_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.delete_team(uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.delete_team(uuid) TO authenticated;

-- ============================================================
-- RPC: get_or_create_today_session – Session für heute (Team) anlegen oder zurückgeben
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_or_create_today_session(p_team_id uuid)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid;
  sid uuid;
  session_title text;
BEGIN
  uid := COALESCE((auth.jwt() ->> 'sub')::uuid, auth.uid());
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = uid) THEN
    RAISE EXCEPTION 'Kein Mitglied dieses Teams';
  END IF;

  SELECT id INTO sid FROM public.sessions
  WHERE team_id = p_team_id AND (started_at AT TIME ZONE 'Europe/Berlin')::date = (now() AT TIME ZONE 'Europe/Berlin')::date
  ORDER BY started_at DESC LIMIT 1;

  IF sid IS NOT NULL THEN
    RETURN sid;
  END IF;

  session_title := 'Spieltag ' || to_char(now() AT TIME ZONE 'Europe/Berlin', 'DD.MM.YYYY');
  INSERT INTO public.sessions (team_id, title) VALUES (p_team_id, session_title) RETURNING id INTO sid;
  RETURN sid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_or_create_today_session(uuid) TO anon;
GRANT EXECUTE ON FUNCTION public.get_or_create_today_session(uuid) TO authenticated;

-- ============================================================
-- RPC: add_loser – Verlierer-Runde eintragen (Team, Variante, Spieler, Symbol)
-- ============================================================

CREATE OR REPLACE FUNCTION public.add_loser(p_team_id uuid, p_variant_id uuid, p_loser_player_id uuid, p_symbol text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  uid uuid;
  sid uuid;
BEGIN
  uid := COALESCE((auth.jwt() ->> 'sub')::uuid, auth.uid());
  IF uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.team_members WHERE team_id = p_team_id AND user_id = uid) THEN
    RAISE EXCEPTION 'Kein Mitglied dieses Teams';
  END IF;
  IF p_symbol IS NOT NULL AND p_symbol NOT IN ('rock','paper','scissors') THEN
    RAISE EXCEPTION 'Symbol muss rock, paper oder scissors sein';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.players WHERE id = p_loser_player_id AND team_id = p_team_id) THEN
    RAISE EXCEPTION 'Spieler gehört nicht zu diesem Team';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM public.variants WHERE id = p_variant_id AND is_active = true) THEN
    RAISE EXCEPTION 'Ungültige oder inaktive Variante';
  END IF;

  sid := public.get_or_create_today_session(p_team_id);

  INSERT INTO public.rounds (session_id, variant_id, loser_player_id, symbol, played_at)
  VALUES (sid, p_variant_id, p_loser_player_id, p_symbol, now());
END;
$$;

GRANT EXECUTE ON FUNCTION public.add_loser(uuid, uuid, uuid, text) TO anon;
GRANT EXECUTE ON FUNCTION public.add_loser(uuid, uuid, uuid, text) TO authenticated;
