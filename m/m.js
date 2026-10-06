/* CTD portrait (phone) version: shared helpers. Standalone; reads (never edits) the shared data/logic
   files assets/tools-data.js, taxonomy-data.js, filters.js, actions.js. */
(function () {
  var P = {
    search: '<circle cx="11" cy="11" r="7"/><path d="m20.5 20.5-4.2-4.2"/>',
    menu: '<path d="M4 6h16M4 12h16M4 18h16"/>',
    chevd: '<path d="m6 9 6 6 6-6"/>', chevu: '<path d="m6 15 6-6 6 6"/>',
    chevl: '<path d="m15 6-6 6 6 6"/>', chevr: '<path d="m9 6 6 6-6 6"/>',
    dchevl: '<path d="m11 6-6 6 6 6M19 6l-6 6 6 6"/>', dchevr: '<path d="m13 6 6 6-6 6M5 6l6 6-6 6"/>',
    bookmark: '<path d="M6 3h12v18l-6-4-6 4z"/>',
    star: '<path d="m12 3 2.7 5.6 6.1.9-4.4 4.3 1 6.1L12 17l-5.4 2.9 1-6.1L3.2 9.5l6.1-.9z"/>',
    download: '<path d="M12 3v12m-4.5-4.5L12 15l4.5-4.5M4 20h16"/>',
    share: '<circle cx="18" cy="5" r="2.6"/><circle cx="6" cy="12" r="2.6"/><circle cx="18" cy="19" r="2.6"/><path d="m8.3 10.8 7.4-4.3M8.3 13.2l7.4 4.3"/>',
    globe: '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.6 2.6 3.8 5.6 3.8 9S14.6 18.4 12 21c-2.6-2.6-3.8-5.6-3.8-9S9.4 5.6 12 3z"/>',
    monitor: '<rect x="3" y="4" width="18" height="12" rx="1.5"/><path d="M8 20h8M12 16v4"/>',
    calendar: '<rect x="3.5" y="5" width="17" height="15" rx="2"/><path d="M3.5 10h17M8 3v4M16 3v4M8 14h.01M12 14h.01M16 14h.01"/>',
    pin: '<path d="M12 21s7-6.2 7-11.5A7 7 0 0 0 5 9.5C5 14.8 12 21 12 21z"/><circle cx="12" cy="9.5" r="2.5"/>',
    users: '<circle cx="9" cy="8" r="3.2"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/><path d="M16 5.2a3.2 3.2 0 0 1 0 5.6M18 14.4c1.8.8 3 2.6 3 4.6"/>',
    cloud: '<path d="M7 18a4.5 4.5 0 0 1-.5-9A6 6 0 0 1 18 9.5 4.3 4.3 0 0 1 17.5 18z"/>',
    info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 7.5h.01"/>',
    alert: '<circle cx="12" cy="12" r="9"/><path d="M12 7v6M12 16.5h.01"/>',
    doc: '<path d="M6 3h8l5 5v13H6z"/><path d="M14 3v5h5M9 13h7M9 17h7"/>',
    cube: '<path d="m12 3 8 4.5v9L12 21l-8-4.5v-9z"/><path d="m4 7.5 8 4.5 8-4.5M12 12v9"/>',
    layers: '<path d="m12 3 9 5-9 5-9-5z"/><path d="m3 12.5 9 5 9-5M3 16.5l9 5 9-5"/>',
    tag: '<path d="M3 12V4h8l10 10-8 8z"/><circle cx="7.5" cy="8.5" r="1.3"/>',
    wrench: '<path d="M14.5 6.5a4 4 0 0 0-5 5L3 18l3 3 6.5-6.5a4 4 0 0 0 5-5l-2.8 2.8-2.4-.6-.6-2.4z"/>',
    funnel: '<path d="M3 4h18l-7 8.5V20l-4-2v-5.5z"/>',
    phone: '<path d="M5 3h3.5l1.7 4.3-2 1.3a11 11 0 0 0 5.2 5.2l1.3-2 4.3 1.7V17a3 3 0 0 1-3 3A15 15 0 0 1 3 6a3 3 0 0 1 2-3z"/>',
    mail: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3.5 7 8.5 6 8.5-6"/>',
    building: '<path d="M5 21V4a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v17M15 9h3a1 1 0 0 1 1 1v11M3 21h18M8.5 7.5h3M8.5 11h3M8.5 14.5h3"/>',
    sitemap: '<rect x="9" y="3" width="6" height="5" rx="1"/><rect x="2.5" y="16" width="6" height="5" rx="1"/><rect x="15.5" y="16" width="6" height="5" rx="1"/><path d="M12 8v4M5.5 12h13v4"/>',
    reset: '<path d="M4 4v6h6"/><path d="M4.5 14a8 8 0 1 0 1.6-8.2L4 10"/>',
    sort: '<path d="M7 20V5m-3.5 3.5L7 5l3.5 3.5M17 4v15m-3.5-3.5L17 19l3.5-3.5"/>',
    grid: '<rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/>',
    home: '<path d="M3 11.5 12 4l9 7.5M5.5 10v10h13V10M10 20v-6h4v6"/>',
    book: '<path d="M12 6c-2-1.5-5-2-8-2v14c3 0 6 .5 8 2 2-1.5 5-2 8-2V4c-3 0-6 .5-8 2zM12 6v14"/>',
    list: '<path d="M9 6h11M9 12h11M9 18h11M4.5 6h.01M4.5 12h.01M4.5 18h.01"/>',
    cap: '<path d="m2 9 10-5 10 5-10 5z"/><path d="M6 11.5V16c0 1.5 2.7 3 6 3s6-1.5 6-3v-4.5M22 9v6"/>',
    bulb: '<path d="M9 18h6M10 21h4M12 3a6 6 0 0 0-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0 0 12 3z"/>',
    flower: '<path d="M12 3v18M4.2 7.5l15.6 9M19.8 7.5l-15.6 9"/><circle cx="12" cy="12" r="2.2" fill="currentColor"/>',
    check: '<path d="m5 12.5 4.5 4.5L19 7.5"/>'
  };
  var M = window.M = {};
  M.icon = function (n, cls) {
    return '<svg class="ic' + (cls ? ' ' + cls : '') + '" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' + (P[n] || '') + '</svg>';
  };
  M.esc = function (s) { return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;'); };

  // ---- data (read-only use of the shared files) ----
  var TOOLS = window.TOOLS || [];
  M.tools = TOOLS.slice().sort(function (a, b) { return (a.rk || 999) - (b.rk || 999); });
  M.vocab = window.CTD_FILTERS.build(TOOLS);
  M.CM = M.vocab.CM;
  M.strip = window.CTD_FILTERS.stripCode;
  M.allDv = M.vocab.divisions.map(function (d) { return d.value; });
  M.allMt = M.vocab.masterTrades.map(function (m) { return m.value; });
  M.allTr = M.vocab.trades.map(function (r) { return r.value; });
  M.params = function () { return window.CTD_FILTERS.readParams(location.search); };
  M.toQS = function (f) { return window.CTD_FILTERS.toParams(f).toString(); };
  M.apply = function (f) { return window.CTD_FILTERS.apply(M.tools, f, M.vocab); };
  M.bySlug = function (s) { return TOOLS.filter(function (t) { return t.s === s; })[0]; };
  // expanded, display-ready values per field (same rules as landscape: ALL-wildcard expands, CSI codes hidden)
  M.vals = {
    cat: function (t) { return (t.c || []).map(function (s) { return { v: s, l: M.CM[s] || s }; }); },
    sub: function (t) { return (t.subs || []).map(function (s) { return { v: s, l: s }; }); },
    prod: function (t) { return (t.products || []).map(function (p) { return { v: p.n, l: p.n }; }); },
    mt: function (t) { return window.CTD_FILTERS.expandAll(t.mt || [], M.allMt).map(function (s) { return { v: s, l: s }; }); },
    div: function (t) { return window.CTD_FILTERS.expandAll(t.dv || [], M.allDv).map(function (s) { return { v: s, l: M.strip(s) }; }); },
    trd: function (t) { return window.CTD_FILTERS.expandAll(t.trd || [], M.allTr).map(function (s) { return { v: s, l: M.strip(s) }; }); }
  };
  M.NAME = { cat: 'Category', sub: 'Subcategory', prod: 'Product', mt: 'Master Group', div: 'Divisions', trd: 'Trades' };
  M.avail = window.CTD_FILTERS.avail;
  M.logo = function (t, sq) {
    var l = M.esc((t.n || '?').charAt(0).toUpperCase());
    var fb = '<span class="m-logofb' + (sq ? ' sq' : '') + '"' + (t.d ? ' style="display:none"' : '') + '>' + l + '</span>';
    var im = t.d ? '<img class="m-logoimg' + (sq ? ' sq' : '') + '" src="../assets/icons/' + M.esc(t.d) + '.ico" alt="" loading="lazy" onerror="this.style.display=\'none\';this.nextElementSibling.style.display=\'\'">' : '';
    return im + fb;
  };

  // ---- shell: header, menu, bottom nav ----
  var TABS = [['home', 'Home', 'index.html', 'home'], ['search', 'Search', 'search.html', 'search'], ['directory', 'Directory', 'advanced-search.html', 'grid'],
    ['vendors', 'Vendors', 'results.html', 'building'], ['content', 'Content', '#', 'book']];
  M.toast = function (msg) {
    var d = document.createElement('div'); d.className = 'm-toast'; d.textContent = msg; document.body.appendChild(d);
    setTimeout(function () { d.remove(); }, 1800);
  };
  M.shell = function (o) {
    var h = document.getElementById('m-hdr');
    if (h) h.outerHTML = '<header class="m-hdr"><a class="m-logo" href="index.html"><img src="../assets/ctd/logo.png" alt="The Construction Technology Directory"></a>' +
      '<form class="m-hsearch" role="search" action="search.html" method="get"><span class="m-hs-ic">' + M.icon('search') + '</span>' +
      '<input id="hdr-q" name="q" type="search" autocomplete="off" placeholder="' + M.esc(o.placeholder) + '" aria-label="Search"></form>' +
      '<button class="m-burger" type="button" aria-label="Menu" aria-expanded="false">' + M.icon('menu') + '</button></header>' +
      '<nav class="m-menu" id="m-menu" hidden><a href="#">About Us</a><a href="#">Contact Us</a><a href="#">Update Info</a><a href="index.html">Home</a></nav>';
    var n = document.getElementById('m-nav');
    if (n) n.outerHTML = '<nav class="m-nav" aria-label="Primary">' + TABS.map(function (t) {
      return '<a href="' + t[2] + '" data-tab="' + t[0] + '"' + (t[0] === o.active ? ' class="on"' : '') + '>' + M.icon(t[3]) + '<span>' + t[1] + '</span></a>';
    }).join('') + '</nav>';
    var b = document.querySelector('.m-burger'), menu = document.getElementById('m-menu');
    b.addEventListener('click', function () {
      var open = menu.hidden; menu.hidden = !open; b.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
    document.addEventListener('click', function (e) { if (!menu.hidden && !e.target.closest('.m-burger,#m-menu')) menu.hidden = true; });
    document.querySelector('a[data-tab="content"]').addEventListener('click', function (e) { e.preventDefault(); M.toast('Content is coming soon'); });
    var q = M.params().q; if (q) document.getElementById('hdr-q').value = q;
    M.suggest(document.getElementById('hdr-q'));
  };

  // ---- autosuggest (portrait copy: links go to /m/ pages) ----
  M.suggest = function (input) {
    var idx = null, items = [], act = -1, box = document.createElement('div');
    box.className = 'm-suggest'; box.hidden = true; input.parentNode.appendChild(box);
    var COL = { Vendor: '#1B5FD0', Product: '#158526', Category: '#E8600F' };
    function build() {
      var o = [], seen = {};
      TOOLS.forEach(function (t) {
        o.push({ t: 'Vendor', l: t.n, s: t.d || '', go: 'vendor.html?s=' + encodeURIComponent(t.s) });
        (t.products || []).forEach(function (p) { if (p.n && !seen[p.n]) { seen[p.n] = 1; o.push({ t: 'Product', l: p.n, s: '', go: 'search.html?prod=' + encodeURIComponent(p.n) }); } });
      });
      Object.keys(M.CM).forEach(function (s) { o.push({ t: 'Category', l: M.CM[s], s: '', go: 'search.html?cat=' + encodeURIComponent(s) }); });
      return o;
    }
    function match(q) {
      if (!idx) idx = build();
      q = q.trim().toLowerCase(); if (!q) return [];
      var a = [], b = [];
      for (var i = 0; i < idx.length; i++) {
        var p = idx[i].l.toLowerCase().indexOf(q);
        if (p === 0) a.push(idx[i]); else if (p > 0) b.push(idx[i]);
        if (a.length >= 8) break;
      }
      return a.concat(b).slice(0, 8);
    }
    function draw() {
      if (!items.length) { box.hidden = true; box.innerHTML = ''; return; }
      box.innerHTML = items.map(function (it, i) {
        return '<div class="si' + (i === act ? ' on' : '') + '" data-i="' + i + '"><span class="tg" style="color:' + COL[it.t] + '">' + it.t + '</span><span class="lb">' + M.esc(it.l) + '</span>' +
          (it.s ? '<span class="sb">' + M.esc(it.s) + '</span>' : '') + '</div>';
      }).join('');
      box.hidden = false;
    }
    input.addEventListener('input', function () { items = match(input.value); act = -1; draw(); });
    input.addEventListener('keydown', function (e) {
      if (box.hidden) return;
      if (e.key === 'ArrowDown') { e.preventDefault(); act = Math.min(items.length - 1, act + 1); draw(); }
      else if (e.key === 'ArrowUp') { e.preventDefault(); act = Math.max(0, act - 1); draw(); }
      else if (e.key === 'Enter' && act >= 0) { e.preventDefault(); location.href = items[act].go; }
      else if (e.key === 'Escape') { box.hidden = true; }
    });
    box.addEventListener('mousedown', function (e) {
      var s = e.target.closest('.si'); if (!s) return; e.preventDefault(); location.href = items[+s.getAttribute('data-i')].go;
    });
    input.addEventListener('blur', function () { setTimeout(function () { box.hidden = true; }, 150); });
  };

  // ---- shared pieces ----
  M.link = function (page, key, val, label, extra) {
    return '<a class="m-v" href="' + page + '?' + encodeURIComponent(key) + '=' + encodeURIComponent(val) + (extra || '') + '">' + M.esc(label) + '</a>';
  };
  // numbered pager (search page): 1 2 3 … last ›
  M.pagerNums = function (page, pages) {
    var set = {}, out = [];
    [1, 2, 3, page - 1, page, page + 1, pages].forEach(function (p) { if (p >= 1 && p <= pages) set[p] = 1; });
    var ks = Object.keys(set).map(Number).sort(function (a, b) { return a - b; }), prev = 0;
    ks.forEach(function (p) {
      if (prev && p - prev > 1) out.push('<span class="dots">…</span>');
      out.push('<button type="button" data-p="' + p + '"' + (p === page ? ' class="on"' : '') + '>' + p + '</button>'); prev = p;
    });
    out.push('<button type="button" data-p="' + Math.min(pages, page + 1) + '" aria-label="Next"' + (page >= pages ? ' disabled' : '') + '>' + M.icon('chevr') + '</button>');
    return out.join('');
  };
  var CUST = { 'All Sizes': 'Construction firms of all sizes', 'Small Business': 'Small construction firms', 'Small / Mid-Market': 'Small to mid-size construction firms',
    'Mid-Market / Enterprise': 'Mid-size to enterprise construction firms', 'Enterprise': 'Enterprise construction firms' };
  M.customers = function (t) { return CUST[t.sz] || t.sz || ''; };
})();
