-- ============================================================
-- winner_player_id komplett durch loser_player_id ersetzen
-- In Supabase SQL Editor ausführen (nach supabase-rpc-create-team.sql).
-- ============================================================

ALTER TABLE public.rounds
  ADD COLUMN IF NOT EXISTS loser_player_id uuid REFERENCES public.players(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_rounds_loser ON public.rounds(loser_player_id);

DROP INDEX IF EXISTS public.idx_rounds_winner;
ALTER TABLE public.rounds DROP COLUMN IF EXISTS winner_player_id;

DROP FUNCTION IF EXISTS public.add_winner(uuid, uuid, uuid, text);

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
