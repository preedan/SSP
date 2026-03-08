/**
 * Gemeinsame Mini-Navigation (Schritt 1).
 * Einbinden: <div id="app-nav"></div> + <script src="nav.js"></script> (nach supabase-config.js)
 */
(function () {
    var navEl = document.getElementById("app-nav");
    if (!navEl) return;
    navEl.className = "app-nav";

    function getCurrentPage() {
        var path = window.location.pathname || "";
        var file = path.split("/").pop() || path;
        if (file === "" || file === "index.html" || path.endsWith("/")) return "start";
        if (path.indexOf("uebersicht") !== -1) return "uebersicht";
        if (path.indexOf("ermitteln") !== -1) return "ermitteln";
        if (path.indexOf("teams.html") !== -1 && path.indexOf("team-beitreten") === -1) return "teams";
        if (path.indexOf("statistik") !== -1) return "statistik";
        return null;
    }

    function link(href, label, pageKey) {
        var current = getCurrentPage();
        var cls = "app-nav-link" + (current === pageKey ? " app-nav-current" : "");
        return "<a href=\"" + href + "\" class=\"" + cls + "\">" + label + "</a>";
    }

    function render(session) {
        var left = link("index.html", "Start", "start") +
            " | " + link("uebersicht.html", "Übersicht", "uebersicht") +
            " | " + link("ermitteln.html", "Ermitteln", "ermitteln");
        if (session) {
            left += " | " + link("teams.html", "Meine Teams", "teams") + " | " + link("statistik.html", "Statistik", "statistik");
        }
        var right = session
            ? "<button type=\"button\" class=\"app-nav-link app-nav-btn\" id=\"app-nav-signout\">Abmelden</button>"
            : link("login.html", "Anmelden", null);
        navEl.innerHTML = "<div class=\"app-nav-inner\"><div class=\"app-nav-left\">" + left + "</div><div class=\"app-nav-right\">" + right + "</div></div>";

        var signOutBtn = document.getElementById("app-nav-signout");
        if (signOutBtn && typeof getSupabase === "function") {
            signOutBtn.addEventListener("click", function () {
                getSupabase().auth.signOut();
            });
        }
    }

    var style = document.createElement("style");
    style.textContent = [
        "#app-nav.app-nav { font-family: 'Baloo 2', cursive; background: #267bb5; color: #fff; padding: 10px 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }",
        "#app-nav.app-nav .app-nav-link { color: #fff; }",
        "#app-nav.app-nav .app-nav-btn { color: #fff; }",
        "#app-nav .app-nav-inner { max-width: 900px; margin: 0 auto; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; }",
        "#app-nav .app-nav-left, #app-nav .app-nav-right { display: flex; flex-wrap: wrap; align-items: center; gap: 6px; }",
        "#app-nav .app-nav-link { color: #fff; text-decoration: none; padding: 10px 12px; min-height: 44px; box-sizing: border-box; display: inline-flex; align-items: center; border-radius: 6px; font-size: 1em; }",
        "#app-nav .app-nav-link:hover { background: rgba(255,255,255,0.2); }",
        "#app-nav .app-nav-link.app-nav-current { background: rgba(255,255,255,0.3); font-weight: 700; }",
        "#app-nav .app-nav-btn { background: none; border: none; color: inherit; cursor: pointer; font-family: inherit; font-size: 1em; padding: 10px 12px; min-height: 44px; box-sizing: border-box; border-radius: 6px; }",
        "#app-nav .app-nav-btn:hover { background: rgba(255,255,255,0.2); }",
        "@media (max-width: 600px) { #app-nav .app-nav-left { flex-direction: column; align-items: flex-start; } #app-nav .app-nav-inner { gap: 12px; } }"
    ].join("\n");
    document.head.appendChild(style);

    if (typeof getSupabase !== "function") {
        render(null);
        return;
    }
    getSupabase().auth.getSession().then(function (r) { render(r.data.session); });
    getSupabase().auth.onAuthStateChange(function (e, s) { render(s); });
})();
