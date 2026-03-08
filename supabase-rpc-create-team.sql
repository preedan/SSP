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
