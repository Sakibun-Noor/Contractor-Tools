/* ═══════════════════════════════════════════════════════════
   Shared filter data + logic for the CTD search/results pages.
   Single source of truth for category names and the derived
   division/master-trade mappings — these were previously copy-
   pasted into 3 separate <script> blocks with drifting values
   (e.g. estimating-takeoff's divisions differed across pages).
   Include after tools-data.js.
   ═══════════════════════════════════════════════════════════ */
window.CTD_FILTERS = (function () {
  // Category names — 2026-09-19: Deryck retired "Specialty Solutions" (the
  // former 13th category) and redistributed its subcategories into these 12;
  // 5 got renamed in the process. Slugs (the URL/filter keys) are unchanged
  // by his own instruction, confirmed via his own ChatGPT check — only the
  // on-screen label moves. See specs/product-db-site-integration-2026-09-19.md §3a.
  var CM = {
    'accounting-payroll': 'Finance & Payroll',
    'crm-sales': 'CRM & Sales',
    'construction-leads': 'Leads & Bids',
    'estimating-takeoff': 'Estimating & Takeoff',
    'project-management': 'Project Management',
    'field-service-dispatch': 'Field Operations',
    'safety-compliance': 'Safety & Compliance',
    'fleet-equipment': 'Fleet & Equipment',
    'marketing-reputation': 'Marketing & Reputation',
    'ai-automation': 'AI & Automation',
    'document-management': 'BIM & Documents',
    'procurement-purchasing': 'Procurement'
  };

  // Every vendor now carries its own real, multi-valued classification from
  // the merged vendor/product database (build/import-vendors.ps1):
  // t.c (categories), t.subs (subcategories), t.mt (Master Groups), t.dv
  // (Divisions), t.trd (real CSI-coded Trades), t.mkt (Market Sector), and
  // t.products (the vendor's actual product list). t.tr (the old
  // "contractor type" values — GC / Commercial / Residential / Specialty
  // Trades) is still imported but deliberately never shown, per the
  // 2026-09-18 decision — t.trd replaces it as the displayed "Trades" data.

  function avail(sz) {
    var r = ['Cloud-Based'];
    if (/Enterprise|Mid/i.test(sz || '')) r.push('Mobile App (iOS/Android)');
    else r.push('Web Access');
    if (/Enterprise/i.test(sz || '')) r.push('API Available');
    return r;
  }

  // Counts occurrences of every value in an array-valued field across all
  // tools, sorted by count descending. Used for every multi-valued facet
  // (categories, subcategories, master groups, divisions, trades, products,
  // market sectors) now that a vendor can carry more than one of each.
  function countArrayField(tools, field) {
    var counts = {};
    tools.forEach(function (t) { (t[field] || []).forEach(function (v) { if (v) counts[v] = (counts[v] || 0) + 1; }); });
    return counts;
  }
  function toSortedList(counts, labelFn) {
    return Object.keys(counts).map(function (v) {
      return { value: v, label: labelFn ? labelFn(v) : v, count: counts[v] };
    }).sort(function (a, b) { return b.count - a.count; });
  }

  // Builds the real, data-derived vocabulary for every filter
  // dimension from the live tools array. Called once per page load.
  function build(tools) {
    tools = tools || [];
    var TAX = (typeof window !== 'undefined' && window.CTD_TAXONOMY) || null;

    var catCounts = countArrayField(tools, 'c');
    var categories = Object.keys(catCounts).map(function (slug) {
      return { value: slug, label: CM[slug] || slug, count: catCounts[slug] };
    }).sort(function (a, b) { return b.count - a.count; });

    // SUBCATEGORIES — t.subs is now multi-valued (a vendor's real product
    // subcategories), not the single t.sub placeholder it used to be.
    var subcategories = toSortedList(countArrayField(tools, 'subs'));

    // PRODUCTS — real per-vendor product names from the merged database
    // (build/import-vendors.ps1), replacing the old fake "<subcategory>
    // Software" placeholder. t.products is an array of {n, u} objects (not
    // plain strings), so it's counted directly rather than through
    // countArrayField.
    var prodCounts = {};
    tools.forEach(function (t) { (t.products || []).forEach(function (p) { if (p && p.n) prodCounts[p.n] = (prodCounts[p.n] || 0) + 1; }); });
    var products = toSortedList(prodCounts);

    // t.tr (old contractor-type data) is imported but never surfaced as a
    // facet — see the 2026-09-18 decision. Kept out of the returned vocab
    // entirely so nothing can accidentally render it.

    // DIVISIONS — the vendor's own classification (t.dv, real CSI-coded
    // divisions from the merged database, e.g. "26 00 00 – Electrical").
    // Multi-valued per vendor now.
    var dvCounts = countArrayField(tools, 'dv');
    var divisions;
    if (TAX && TAX.divisions && TAX.divisions.length) {
      // Complete canonical list (including the ALL DIVISIONS wildcard row),
      // so an unused division still shows (disabled at 0) instead of
      // vanishing from the vocabulary.
      divisions = TAX.divisions.map(function (d) {
        var label = d.number + ' – ' + d.name;
        return { value: label, label: label, count: dvCounts[label] || 0 };
      });
    } else {
      divisions = toSortedList(dvCounts);
    }

    // MASTER GROUPS (field key still `mt`) — the client's 12 validated
    // groups plus the ALL MASTER GROUPS wildcard, complete canonical list
    // like Divisions above. Multi-valued per vendor now.
    var mtCounts = countArrayField(tools, 'mt');
    var masterTrades;
    if (TAX && TAX.masterGroups && TAX.masterGroups.length) {
      masterTrades = TAX.masterGroups.map(function (m) {
        var count = mtCounts[m.name] || 0;
        return { value: m.name, label: m.name, count: count, pending: count === 0 };
      });
    } else {
      masterTrades = toSortedList(mtCounts);
    }

    // TRADES (field key `trd`) — real CSI-coded trades, brand new
    // 2026-09-19. 425 possible values is too many for a fixed always-shown
    // list (unlike Divisions/Master Groups' ~12–51), so this facet is built
    // from live data only, same as Divisions/Master Groups were before the
    // client's hierarchy data arrived.
    var trades = toSortedList(countArrayField(tools, 'trd'));

    // MARKET SECTOR (field key `mkt`) — brand new 2026-09-19, replaces the
    // "MARKETS SERVED" stub that rendered invented values at a fixed 0
    // count on Search/Results and Advanced Search.
    var mktCounts = countArrayField(tools, 'mkt');
    var marketSectors;
    if (TAX && TAX.marketSectors && TAX.marketSectors.length) {
      marketSectors = TAX.marketSectors.map(function (m) {
        var count = mktCounts[m.name] || 0;
        return { value: m.name, label: m.name, count: count, pending: count === 0 };
      });
    } else {
      marketSectors = toSortedList(mktCounts);
    }

    var availCounts = {};
    tools.forEach(function (t) { avail(t.sz).forEach(function (a) { availCounts[a] = (availCounts[a] || 0) + 1; }); });
    var availableOn = Object.keys(availCounts).map(function (a) {
      return { value: a, label: a, count: availCounts[a] };
    }).sort(function (a, b) { return b.count - a.count; });

    var szCounts = {};
    tools.forEach(function (t) { if (t.sz) szCounts[t.sz] = (szCounts[t.sz] || 0) + 1; });
    var sizes = Object.keys(szCounts).map(function (s) {
      return { value: s, label: s, count: szCounts[s] };
    }).sort(function (a, b) { return b.count - a.count; });

    return {
      categories: categories, subcategories: subcategories, products: products,
      trades: trades, divisions: divisions, masterTrades: masterTrades,
      marketSectors: marketSectors, availableOn: availableOn, sizes: sizes,
      CM: CM
    };
  }

  // Every classification field is now multi-valued (a vendor can carry more
  // than one category, subcategory, master group, division, trade or
  // product) — so filtering means "does the active selection intersect the
  // vendor's array", same test already used for cat/tr.
  function hasAny(arr, selected) {
    return (arr || []).some(function (v) { return selected.indexOf(v) > -1; });
  }

  // filters: { q, cat:[], sub:[], prod:[], div:[], mt:[], trd:[], mkt:[], avail:[], sz:[] }
  // tr (old contractor-type data) is intentionally not a filterable
  // dimension — imported but never surfaced, per the 2026-09-18 decision.
  function apply(tools, filters, vocab) {
    filters = filters || {};
    var q = (filters.q || '').trim().toLowerCase();
    return (tools || []).filter(function (t) {
      if (q) {
        var prodNames = (t.products || []).map(function (p) { return p.n; }).join(' ');
        var hay = ((t.n || '') + ' ' + (t.x || '') + ' ' + (t.subs || []).join(' ') + ' ' +
          prodNames + ' ' + (t.c || []).join(' ')).toLowerCase();
        if (hay.indexOf(q) === -1) return false;
      }
      if (filters.cat && filters.cat.length && !hasAny(t.c, filters.cat)) return false;
      if (filters.sub && filters.sub.length && !hasAny(t.subs, filters.sub)) return false;
      if (filters.prod && filters.prod.length) {
        var names = (t.products || []).map(function (p) { return p.n; });
        if (!hasAny(names, filters.prod)) return false;
      }
      // All four read the vendor's own real classification from the merged
      // database now, not a guess made from its software category.
      if (filters.div && filters.div.length && !hasAny(t.dv, filters.div)) return false;
      if (filters.mt && filters.mt.length && !hasAny(t.mt, filters.mt)) return false;
      if (filters.trd && filters.trd.length && !hasAny(t.trd, filters.trd)) return false;
      if (filters.mkt && filters.mkt.length && !hasAny(t.mkt, filters.mkt)) return false;
      if (filters.avail && filters.avail.length) {
        var av = avail(t.sz);
        if (!filters.avail.some(function (a) { return av.indexOf(a) > -1; })) return false;
      }
      if (filters.sz && filters.sz.length && filters.sz.indexOf(t.sz) === -1) return false;
      return true;
    });
  }

  // Reads repeated query-string keys (?cat=a&cat=b) into arrays. `tr` stays
  // readable so an old shared/bookmarked URL doesn't error out, even though
  // it's no longer applied as a filter (2026-09-18 decision).
  function readParams(search) {
    var sp = new URLSearchParams(search);
    return {
      q: sp.get('q') || '',
      cat: sp.getAll('cat'),
      sub: sp.getAll('sub'),
      prod: sp.getAll('prod'),
      tr: sp.getAll('tr'),
      div: sp.getAll('div'),
      mt: sp.getAll('mt'),
      trd: sp.getAll('trd'),
      mkt: sp.getAll('mkt'),
      avail: sp.getAll('avail'),
      sz: sp.getAll('sz')
    };
  }

  function toParams(filters) {
    var sp = new URLSearchParams();
    if (filters.q) sp.set('q', filters.q);
    ['cat', 'sub', 'prod', 'tr', 'div', 'mt', 'trd', 'mkt', 'avail', 'sz'].forEach(function (k) {
      (filters[k] || []).forEach(function (v) { sp.append(k, v); });
    });
    return sp;
  }

  return { CM: CM, avail: avail, build: build, apply: apply, readParams: readParams, toParams: toParams };
})();
