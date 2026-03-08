/**
 * Gemeinsame Supabase-Konfiguration für die SSP-App.
 * Wird von allen Seiten geladen, die Supabase oder Auth brauchen.
 */
(function () {
    const SUPABASE_URL = "https://zprhyizekhtfdjexabie.supabase.co";
    const SUPABASE_PUBLISHABLE_KEY = "sb_publishable_UUS0NTM7cTY5_bcEGGjLeA_3H5ZlGFO";

    let _client = null;

    function getSupabase() {
        if (typeof supabase === "undefined") throw new Error("Supabase SDK nicht geladen.");
        if (!_client) _client = supabase.createClient(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY);
        return _client;
    }

    window.SUPABASE_URL = SUPABASE_URL;
    window.SUPABASE_PUBLISHABLE_KEY = SUPABASE_PUBLISHABLE_KEY;
    window.getSupabase = getSupabase;
})();
