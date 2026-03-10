/**
 * Gemeinsame Navigation inkl. User-Profil-Dropdown.
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
        if (path.indexOf("eintragen") !== -1) return "eintragen";
        return null;
    }

    function link(href, label, pageKey) {
        var current = getCurrentPage();
        var cls = "app-nav-link" + (current === pageKey ? " app-nav-current" : "");
        return "<a href=\"" + href + "\" class=\"" + cls + "\">" + label + "</a>";
    }

    function escapeHtml(s) {
        if (!s) return "";
        var div = document.createElement("div");
        div.textContent = s;
        return div.innerHTML;
    }

    function getInitial(displayName, email) {
        if (displayName && displayName.trim()) return displayName.trim().charAt(0).toUpperCase();
        if (email && email.trim()) return email.trim().charAt(0).toUpperCase();
        return "?";
    }

    function render(session, displayName, email) {
        displayName = (displayName || "").trim();
        email = (session && session.user && session.user.email) ? session.user.email : (email || "");

        var left = link("index.html", "🏠 Home", "start") + " | " + link("statistik.html", "🏆 Ranking", "statistik");

        var initial = getInitial(displayName, email);
        var right = "<div class=\"app-nav-profile-wrap\">" +
            "<button type=\"button\" class=\"app-nav-profile-trigger\" id=\"app-nav-profile-trigger\" aria-haspopup=\"true\" aria-expanded=\"false\" title=\"Menü\">" +
            "<span class=\"app-nav-profile-circle\">" + escapeHtml(initial) + "</span></button>" +
            "<div class=\"app-nav-dropdown\" id=\"app-nav-dropdown\" hidden>" +
            (session
                ? "<div class=\"app-nav-dropdown-info\"><strong>" + escapeHtml(displayName || "Nutzer") + "</strong></div>" +
                  "<div class=\"app-nav-dropdown-info app-nav-dropdown-email\">" + escapeHtml(email) + "</div>" +
                  "<a href=\"teams.html\" class=\"app-nav-dropdown-item\">Meine Teams</a>" +
                  "<a href=\"uebersicht.html\" class=\"app-nav-dropdown-item\">Meine Varianten</a>" +
                  "<button type=\"button\" class=\"app-nav-dropdown-item app-nav-dropdown-btn\" id=\"app-nav-signout\">Abmelden</button>"
                : "<a href=\"login.html\" class=\"app-nav-dropdown-item\">Anmelden</a>") +
            "</div></div>";

        navEl.innerHTML = "<div class=\"app-nav-inner\"><div class=\"app-nav-left\">" + left + "</div><div class=\"app-nav-right\">" + right + "</div></div>";

        var trigger = document.getElementById("app-nav-profile-trigger");
        var dropdown = document.getElementById("app-nav-dropdown");
        if (trigger && dropdown) {
            trigger.addEventListener("click", function (e) {
                e.stopPropagation();
                var open = dropdown.getAttribute("hidden") === null;
                dropdown.toggleAttribute("hidden", open);
                trigger.setAttribute("aria-expanded", !open);
            });
            document.addEventListener("click", function () {
                dropdown.setAttribute("hidden", "");
                trigger.setAttribute("aria-expanded", "false");
            });
        }
        var signOutBtn = document.getElementById("app-nav-signout");
        if (signOutBtn && typeof getSupabase === "function") {
            signOutBtn.addEventListener("click", function () {
                getSupabase().auth.signOut();
            });
        }
    }

    var style = document.createElement("style");
    style.textContent = [
        "#app-nav.app-nav { font-family: 'Baloo 2', cursive; background: #267bb5; color: #fff; padding: 10px 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); position: relative; }",
        "#app-nav.app-nav .app-nav-link { color: #fff; }",
        "#app-nav .app-nav-inner { max-width: 900px; margin: 0 auto; display: flex; flex-wrap: nowrap; justify-content: space-between; align-items: center; gap: 8px; }",
        "#app-nav .app-nav-left, #app-nav .app-nav-right { display: flex; flex-wrap: nowrap; align-items: center; gap: 6px; }",
        "#app-nav .app-nav-link { color: #fff; text-decoration: none; padding: 10px 12px; min-height: 44px; box-sizing: border-box; display: inline-flex; align-items: center; border-radius: 6px; font-size: 1em; white-space: nowrap; }",
        "#app-nav .app-nav-link:hover { background: rgba(255,255,255,0.2); }",
        "#app-nav .app-nav-link.app-nav-current { background: rgba(255,255,255,0.3); font-weight: 700; }",
        ".app-nav-profile-wrap { position: relative; }",
        ".app-nav-profile-trigger { background: none; border: none; cursor: pointer; padding: 0; color: #fff; display: flex; align-items: center; justify-content: center; border-radius: 50%; }",
        ".app-nav-profile-trigger:hover { opacity: 0.9; }",
        ".app-nav-profile-trigger:focus { outline: 3px solid #90c2ff; outline-offset: 2px; }",
        ".app-nav-profile-circle { width: 44px; height: 44px; min-width: 44px; min-height: 44px; border-radius: 50%; background: rgba(255,255,255,0.35); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.2em; }",
        ".app-nav-dropdown { position: absolute; right: 0; top: 100%; margin-top: 8px; min-width: 220px; background: #fff; color: #333; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); padding: 12px 0; z-index: 1000; }",
        ".app-nav-dropdown[hidden] { display: none !important; }",
        ".app-nav-dropdown-info { padding: 6px 16px; font-size: 0.95em; color: #555; }",
        ".app-nav-dropdown-info strong { color: #333; }",
        ".app-nav-dropdown-email { font-size: 0.85em; color: #666; word-break: break-all; }",
        ".app-nav-dropdown-item { display: block; width: 100%; padding: 10px 16px; text-align: left; color: #267bb5; text-decoration: none; font-family: inherit; font-size: 1em; background: none; border: none; cursor: pointer; box-sizing: border-box; }",
        ".app-nav-dropdown-item:hover { background: #f0f4f8; }",
        ".app-nav-dropdown-btn { color: #c33; }",
        ".app-nav-dropdown-btn:hover { background: #fee; }",
        "@media (max-width: 400px) { #app-nav.app-nav { padding: 8px 12px; } #app-nav .app-nav-link { padding: 8px 10px; font-size: 0.95em; } .app-nav-profile-circle { width: 40px; height: 40px; min-width: 40px; min-height: 40px; font-size: 1.1em; } }"
    ].join("\n");
    document.head.appendChild(style);

    function updateNav() {
        if (typeof getSupabase !== "function") {
            render(null);
            return;
        }
        getSupabase().auth.getSession().then(function (r) {
            var session = r.data.session;
            if (!session) {
                render(null);
                return;
            }
            getSupabase().from("profiles").select("display_name").eq("user_id", session.user.id).maybeSingle().then(function (res) {
                var displayName = (res.data && res.data.display_name) ? res.data.display_name : "";
                render(session, displayName, session.user.email);
            }).catch(function () {
                render(session, "", session.user.email);
            });
        });
    }

    getSupabase().auth.onAuthStateChange(function () { updateNav(); });
    updateNav();
})();
