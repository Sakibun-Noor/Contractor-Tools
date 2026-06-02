/* ============================================================
   Shared site behaviour — The Contractor Technology Directory
   Requires tools-data.js (window.TOOLS) loaded first.
   ============================================================ */
(function () {
  "use strict";
  var TOOLS = window.TOOLS || [];

  /* ---------- taxonomy meta ---------- */
  var CATS = window.CATS = {
    "estimating-takeoff":   { name: "Estimating & Takeoff",   sub: "Estimating · Takeoff · Cost Data",        href: "/estimating-takeoff/" },
    "construction-leads":   { name: "Construction Leads",     sub: "Bid Leads · Permits · Gov Bids",          href: "/construction-leads/" },
    "crm-sales":            { name: "CRM & Sales",            sub: "CRM · Sales · Customer Service",          href: "/crm-sales/" },
    "field-service-dispatch":{ name: "Field Service & Dispatch", sub: "Dispatch · Scheduling · Work Orders",  href: "/field-service-dispatch/" },
    "project-management":   { name: "Project Management",     sub: "Scheduling · Collaboration · Field",      href: "/project-management/" },
    "accounting-payroll":   { name: "Accounting & Payroll",   sub: "Accounting · Payroll · Job Costing",      href: "/accounting-payroll/" },
    "safety-compliance":    { name: "Safety & Compliance",    sub: "Safety · Training · Compliance",          href: "/safety-compliance/" },
    "fleet-equipment":      { name: "Fleet & Equipment",      sub: "Fleet · Equipment · Telematics",          href: "/fleet-equipment/" },
    "marketing-reputation": { name: "Marketing & Reputation", sub: "Marketing · Reviews · Local SEO",         href: "/marketing-reputation/" },
    "ai-automation":        { name: "AI & Automation",        sub: "AI Tools · Automation · Analytics",       href: "/ai-automation/" },
    "document-management":  { name: "Document Management",    sub: "Documents · Forms · eSignatures",         href: "/document-management/" },
    "procurement-purchasing":{ name: "Procurement & Purchasing", sub: "Purchasing · Inventory · Vendors",     href: "/procurement-purchasing/" }
  };

  /* simple line icons (geometric, stroke) keyed by category */
  var I = window.ICONS = {
    "estimating-takeoff": '<path d="M9 2h6a2 2 0 0 1 2 2v16a2 2 0 0 1-2 2H9a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z"/><path d="M9 6h6M9 10h6M9 14h3"/>',
    "construction-leads": '<path d="M3 11l18-8-8 18-2-7-8-3z"/>',
    "crm-sales": '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87M16 3.13A4 4 0 0 1 16 11"/>',
    "field-service-dispatch": '<path d="M3 7h11v8H3z"/><path d="M14 10h4l3 3v2h-7z"/><circle cx="6.5" cy="17.5" r="1.8"/><circle cx="17.5" cy="17.5" r="1.8"/>',
    "project-management": '<rect x="3" y="4" width="18" height="16" rx="2"/><path d="M3 9h18M8 4v16"/>',
    "accounting-payroll": '<rect x="2" y="5" width="20" height="14" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M6 9v6M18 9v6"/>',
    "safety-compliance": '<path d="M12 2l8 4v6c0 5-3.5 8-8 10-4.5-2-8-5-8-10V6z"/><path d="M9 12l2 2 4-4"/>',
    "fleet-equipment": '<path d="M3 7h11v8H3z"/><path d="M14 10h4l3 3v2h-7z"/><circle cx="6.5" cy="17.5" r="1.8"/><circle cx="17.5" cy="17.5" r="1.8"/>',
    "marketing-reputation": '<path d="M3 11l16-6v14L3 13z"/><path d="M3 11v2a2 2 0 0 0 2 2h1"/>',
    "ai-automation": '<rect x="4" y="8" width="16" height="12" rx="2"/><path d="M12 8V4M9 2h6M9 13v2M15 13v2"/>',
    "document-management": '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6M9 13h6M9 17h6"/>',
    "procurement-purchasing": '<circle cx="9" cy="21" r="1.6"/><circle cx="18" cy="21" r="1.6"/><path d="M2 3h3l2.5 13h11l2-9H6"/>'
  };

  var TRADES = window.TRADES = [
    { id: "HVAC", name: "HVAC", href: "/trades/hvac/", ic: '<path d="M4 5h16v9H4z"/><path d="M7 18v2M12 18v2M17 18v2M7 9h.01M11 9h.01M15 9h.01"/>' },
    { id: "Plumbing", name: "Plumbing", href: "/trades/plumbing/", ic: '<path d="M7 3v6a3 3 0 0 0 3 3h4a3 3 0 0 1 3 3v6"/><path d="M5 3h4M15 18h6"/>' },
    { id: "Electrical", name: "Electrical", href: "/trades/electrical/", ic: '<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>' },
    { id: "Mechanical", name: "Mechanical", href: "/trades/mechanical/", ic: '<circle cx="12" cy="12" r="3.2"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3M5 5l2 2M17 17l2 2M19 5l-2 2M7 17l-2 2"/>' },
    { id: "GC", name: "General Contractor", href: "/trades/general-contractor/", ic: '<path d="M3 21h18M5 21V8l7-5 7 5v13M9 21v-6h6v6"/>' },
    { id: "Commercial", name: "Commercial GC", href: "/trades/commercial-gc/", ic: '<path d="M3 21h18M6 21V5h6v16M12 21V9h6v12M9 9h.01M9 13h.01M15 13h.01M15 17h.01"/>' }
  ];

  var PRICE_META = {
    "Free":          { cls: "free", label: "Free" },
    "Under $100/mo": { cls: "low",  label: "Under $100/mo" },
    "$100-$500/mo":  { cls: "mid",  label: "$100–$500/mo" },
    "Enterprise":    { cls: "ent",  label: "Enterprise" }
  };
  window.PRICE_META = PRICE_META;

  /* ---------- helpers ---------- */
  function esc(s){ return String(s||"").replace(/[&<>"]/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); }
  window.escHtml = esc;

  function iconHtml(t, base, cls) {
    base = base || "";
    var letter = esc((t.n||"?").charAt(0).toUpperCase());
    if (!t.d) return '<div class="icon-fallback'+(cls?' '+cls:'')+'">'+letter+'</div>';
    var src = base + "assets/icons/" + t.d + ".ico";
    var dd = "https://icons.duckduckgo.com/ip3/" + t.d + ".ico";
    return '<img src="'+src+'" alt="'+esc(t.n)+' logo" loading="lazy" '+
      'onerror="if(!this.dataset.r){this.dataset.r=1;this.src=\''+dd+'\'}else{this.outerHTML=\'<div class=&quot;icon-fallback '+(cls||'')+'&quot;>'+letter+'</div>\'}">';
  }
  window.iconHtml = iconHtml;

  function toolHref(t){
    if (window.TOOLPATHS && window.TOOLPATHS[t.s]) return "/" + window.TOOLPATHS[t.s];
    if (t.c && t.c[0]) return "/" + t.c[0] + "/";
    return "/categories/";
  }
  window.toolHref = toolHref;

  function tradeLabel(id){ for (var i=0;i<TRADES.length;i++) if (TRADES[i].id===id) return TRADES[i].name; return id; }
  window.tradeLabel = tradeLabel;

  /* render a full tool card */
  window.renderToolCard = function (t, base) {
    base = base || "";
    var pm = PRICE_META[t.p] || PRICE_META["$100-$500/mo"];
    var tags = [];
    (t.tr || []).slice(0,2).forEach(function(tr){ tags.push('<span class="tag">'+esc(tradeLabel(tr))+'</span>'); });
    (t.u || []).slice(0, tags.length ? 1 : 2).forEach(function(u){ tags.push('<span class="tag">'+esc(u.replace(/([a-z])([A-Z])/g,'$1 $2'))+'</span>'); });
    return ''+
    '<a href="'+toolHref(t,base)+'" class="tool-card reveal" data-slug="'+esc(t.s)+'">'+
      '<div class="tool-top">'+
        '<div class="tool-icon">'+iconHtml(t, base)+'</div>'+
        '<div style="min-width:0;flex:1">'+
          '<div class="tool-name">'+esc(t.n)+'</div>'+
          '<div class="tool-domain">'+esc(t.d || "directory listing")+'</div>'+
        '</div>'+
        '<span class="badge-price '+pm.cls+'">'+pm.label+'</span>'+
      '</div>'+
      '<p class="tool-desc">'+esc(t.x)+'</p>'+
      (tags.length ? '<div class="tool-tags">'+tags.join('')+'</div>' : '')+
      '<div class="tool-foot">'+
        '<span class="tool-cta">View details <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"/><path d="M12 5l7 7-7 7"/></svg></span>'+
        '<span style="font-size:.72rem;font-weight:600;color:var(--ink-mute)">'+esc(t.im)+' setup</span>'+
      '</div>'+
    '</a>';
  };

  /* ============================================================
     Header scroll + mobile menu
     ============================================================ */
  var header = document.querySelector(".site-header");
  if (header) {
    var onScroll = function(){ header.classList.toggle("scrolled", window.scrollY > 8); };
    onScroll(); window.addEventListener("scroll", onScroll, { passive: true });
  }
  window.toggleMenu = function (open) {
    var m = document.getElementById("mobileMenu"), s = document.getElementById("mobileScrim");
    if (!m) return;
    var willOpen = (typeof open === "boolean") ? open : !m.classList.contains("open");
    m.classList.toggle("open", willOpen); if (s) s.classList.toggle("open", willOpen);
    document.body.style.overflow = willOpen ? "hidden" : "";
  };

  /* ============================================================
     Global instant search
     ============================================================ */
  function highlight(text, q){ var i=text.toLowerCase().indexOf(q.toLowerCase()); return i<0?esc(text):esc(text.slice(0,i))+'<mark>'+esc(text.slice(i,i+q.length))+'</mark>'+esc(text.slice(i+q.length)); }

  window.initSearch = function (wrapperId, base) {
    base = base || "";
    var wrap = document.getElementById(wrapperId); if (!wrap) return;
    var input = wrap.querySelector(".search-input");
    var dd = wrap.querySelector(".search-dropdown");
    var active = -1, results = [];

    function render(list, q) {
      results = list;
      if (!q) { dd.classList.remove("open"); dd.innerHTML=""; return; }
      if (!list.length) { dd.innerHTML = '<div class="search-empty">No tools match “'+esc(q)+'”.</div>'; dd.classList.add("open"); return; }
      var html = '<div class="search-section-label">'+list.length+' result'+(list.length>1?'s':'')+'</div>';
      html += list.slice(0,9).map(function(t,i){
        var cat = (t.c && t.c[0] && CATS[t.c[0]]) ? CATS[t.c[0]].name.split(" ")[0] : "Tool";
        return '<a href="'+toolHref(t,base)+'" class="search-item'+(i===active?' active':'')+'" data-i="'+i+'">'+
          '<div class="search-item-icon">'+iconHtml(t, base)+'</div>'+
          '<div class="search-item-info"><div class="search-item-name">'+highlight(t.n,q)+'</div>'+
          '<div class="search-item-desc">'+esc(t.x.slice(0,64))+(t.x.length>64?'…':'')+'</div></div>'+
          '<span class="search-item-cat">'+esc(cat)+'</span></a>';
      }).join("");
      if (list.length>9) html += '<div class="search-more">+ '+(list.length-9)+' more — press Enter</div>';
      dd.innerHTML = html; dd.classList.add("open");
    }
    function run(q){
      if (!q) { active=-1; render([], ""); return; }
      var ql=q.toLowerCase();
      var m = TOOLS.filter(function(t){ return t.n.toLowerCase().indexOf(ql)>-1 || (t.x||"").toLowerCase().indexOf(ql)>-1 || (t.d||"").toLowerCase().indexOf(ql)>-1; });
      m.sort(function(a,b){ var A=a.n.toLowerCase().indexOf(ql)===0?0:1, B=b.n.toLowerCase().indexOf(ql)===0?0:1; return A-B || a.n.localeCompare(b.n); });
      active=-1; render(m,q);
    }
    input.addEventListener("input", function(){ run(input.value.trim()); });
    input.addEventListener("focus", function(){ if(input.value.trim()) run(input.value.trim()); });
    input.addEventListener("keydown", function(e){
      var items = dd.querySelectorAll(".search-item");
      if (e.key==="ArrowDown"){ e.preventDefault(); active=Math.min(active+1, items.length-1); upd(items); }
      else if (e.key==="ArrowUp"){ e.preventDefault(); active=Math.max(active-1,-1); upd(items); }
      else if (e.key==="Enter"){ if(active>=0&&items[active]) { e.preventDefault(); items[active].click(); } }
      else if (e.key==="Escape"){ dd.classList.remove("open"); input.blur(); }
    });
    function upd(items){ items.forEach(function(el,i){ el.classList.toggle("active", i===active); }); if(active>=0&&items[active]) items[active].scrollIntoView({block:"nearest"}); }
    document.addEventListener("click", function(e){ if(!wrap.contains(e.target)) dd.classList.remove("open"); });
    document.addEventListener("keydown", function(e){
      if (e.key==="/" && document.activeElement!==input && !/^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement.tagName)) { e.preventDefault(); input.focus(); }
    });
  };

  /* ============================================================
     Scroll reveal
     ============================================================ */
  window.initReveal = function () {
    var els = document.querySelectorAll(".reveal");
    if (!("IntersectionObserver" in window) || matchMedia("(prefers-reduced-motion: reduce)").matches) {
      els.forEach(function(e){ e.classList.add("in"); }); return;
    }
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){ if(en.isIntersecting){ en.target.classList.add("in"); io.unobserve(en.target); } });
    }, { threshold: 0.08, rootMargin: "0px 0px -8% 0px" });
    els.forEach(function(e){ io.observe(e); });
  };
  window.observeReveal = function (el) {
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) { el.classList.add("in"); return; }
    var io = new IntersectionObserver(function(en){ en.forEach(function(x){ if(x.isIntersecting){ x.target.classList.add("in"); io.unobserve(x.target); } }); }, { threshold: 0.08 });
    io.observe(el);
  };

  /* ============================================================
     Animated counters
     ============================================================ */
  window.initCounters = function () {
    var nodes = document.querySelectorAll("[data-count]");
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) { nodes.forEach(function(n){ n.textContent = fmt(+n.dataset.count, n.dataset.suffix); }); return; }
    function fmt(v, suf){ return Math.round(v).toLocaleString() + (suf||""); }
    var io = new IntersectionObserver(function(entries){
      entries.forEach(function(en){
        if (!en.isIntersecting) return; io.unobserve(en.target);
        var node = en.target, target = +node.dataset.count, suf = node.dataset.suffix||"", dur = 1200, start = performance.now();
        function tick(now){ var p = Math.min((now-start)/dur,1); var e = 1-Math.pow(1-p,3); node.textContent = fmt(target*e, suf); if(p<1) requestAnimationFrame(tick); }
        requestAnimationFrame(tick);
      });
    }, { threshold: 0.4 });
    nodes.forEach(function(n){ io.observe(n); });
  };

  /* ============================================================
     Hero parallax
     ============================================================ */
  window.initParallax = function () {
    var layer = document.querySelector(".hero-bg-layer");
    if (!layer || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    var ticking = false;
    window.addEventListener("scroll", function(){
      if (ticking) return; ticking = true;
      requestAnimationFrame(function(){ var y = window.scrollY; if (y < window.innerHeight) layer.style.transform = "translateY(" + (y*0.18) + "px) scale(1.06)"; ticking = false; });
    }, { passive: true });
  };

  /* ============================================================
     Typed placeholder for hero search
     ============================================================ */
  window.initTyper = function (inputId, words) {
    var input = document.getElementById(inputId);
    if (!input || matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    var wi=0, ci=0, deleting=false, base="Search ";
    function loop(){
      var w = words[wi];
      input.setAttribute("placeholder", base + w.slice(0,ci) + (ci<=w.length ? "▎" : ""));
      if (!deleting && ci<w.length) { ci++; setTimeout(loop, 70); }
      else if (!deleting && ci===w.length) { deleting=true; setTimeout(loop, 1500); }
      else if (deleting && ci>0) { ci--; setTimeout(loop, 35); }
      else { deleting=false; wi=(wi+1)%words.length; setTimeout(loop, 300); }
    }
    if (document.activeElement!==input) loop();
  };

})();
