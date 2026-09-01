/* ═══════════════════════════════════════════════════════════
   Shared filter data + logic for the CTD search/results pages.
   Single source of truth for category names and the derived
   division/master-trade mappings — these were previously copy-
   pasted into 3 separate <script> blocks with drifting values
   (e.g. estimating-takeoff's divisions differed across pages).
   Include after tools-data.js.
   ═══════════════════════════════════════════════════════════ */
window.CTD_FILTERS = (function () {
  var CM = {
    'accounting-payroll': 'Accounting & Payroll',
    'crm-sales': 'CRM & Sales',
    'construction-leads': 'Leads, Bids & Estimates',
    'estimating-takeoff': 'Estimating & Takeoff',
    'project-management': 'Project Management',
    'field-service-dispatch': 'Field Service & Dispatch',
    'safety-compliance': 'Safety & Compliance',
    'fleet-equipment': 'Fleet & Equipment',
    'marketing-reputation': 'Marketing & Reputation',
    'ai-automation': 'AI & Automation',
    'document-management': 'Document Management',
    'procurement-purchasing': 'Back Office Operations'
  };

  // DIV_MAP / MT_MAP are gone. They guessed a vendor's divisions and master
  // trade from its software category, which is exactly the axis collapse the
  // two-taxonomy rule forbids, and MT_MAP invented two master trades that do
  // not exist in the client's hierarchy. Every vendor now carries its own
  // t.mt and t.dv from the client's classification file — see
  // specs/hierarchy-import.md.

  function avail(sz) {
    var r = ['Cloud-Based'];
    if (/Enterprise|Mid/i.test(sz || '')) r.push('Mobile App (iOS/Android)');
    else r.push('Web Access');
    if (/Enterprise/i.test(sz || '')) r.push('API Available');
    return r;
  }

  // Builds the real, data-derived vocabulary for every filter
  // dimension from the live tools array. Called once per page load.
  function build(tools) {
    tools = tools || [];

    var catCounts = {};
    tools.forEach(function (t) { (t.c || []).forEach(function (c) { catCounts[c] = (catCounts[c] || 0) + 1; }); });
    var categories = Object.keys(catCounts).map(function (slug) {
      return { value: slug, label: CM[slug] || slug, count: catCounts[slug] };
    }).sort(function (a, b) { return b.count - a.count; });

    var subCounts = {};
    tools.forEach(function (t) { if (t.sub) subCounts[t.sub] = (subCounts[t.sub] || 0) + 1; });
    var subcategories = Object.keys(subCounts).map(function (s) {
      return { value: s, label: s, count: subCounts[s] };
    }).sort(function (a, b) { return b.count - a.count; });

    var trCounts = {};
    tools.forEach(function (t) { (t.tr || []).forEach(function (tr) { trCounts[tr] = (trCounts[tr] || 0) + 1; }); });
    var trades = Object.keys(trCounts).map(function (tr) {
      return { value: tr, label: tr, count: trCounts[tr] };
    }).sort(function (a, b) { return b.count - a.count; });

    // TRADE / DIVISION — one facet, not two. The client's taxonomy maps trade
    // to CSI division 1:1 across all 50, so shipping both would put two
    // controls in the sidebar that always return the same rows. t.dv already
    // carries both vocabularies ("01 – General Conditions & Project Services").
    var dvCounts = {};
    tools.forEach(function (t) { if (t.dv) dvCounts[t.dv] = (dvCounts[t.dv] || 0) + 1; });
    var TAX = (typeof window !== 'undefined' && window.CTD_TAXONOMY) || null;
    var divisions;
    if (TAX && TAX.trades && TAX.trades.length) {
      // Ordered by division number and complete, so an unused trade still shows
      // (disabled at 0) rather than vanishing from the vocabulary.
      divisions = TAX.trades.filter(function (t) {
        return t.name.indexOf('Future Scope') === -1;
      }).map(function (t) {
        var label = t.divisionNumber + ' – ' + t.name;
        return { value: label, label: label, count: dvCounts[label] || 0 };
      });
    } else {
      divisions = Object.keys(dvCounts).map(function (d) {
        return { value: d, label: d, count: dvCounts[d] };
      }).sort(function (a, b) { return b.count - a.count; });
    }

    // MASTER TRADE — the client's 11 groups, counted from each vendor's own
    // classification. Groups with no vendors (Fire & Safety, today) render
    // disabled rather than filtering to an empty table.
    var mtCounts = {};
    tools.forEach(function (t) { if (t.mt) mtCounts[t.mt] = (mtCounts[t.mt] || 0) + 1; });
    var masterTrades;
    if (TAX && TAX.masterTrades && TAX.masterTrades.length) {
      masterTrades = TAX.masterTrades.map(function (m) {
        var count = mtCounts[m.name] || 0;
        return { value: m.name, label: m.name, count: count, pending: count === 0 };
      });
    } else {
      masterTrades = Object.keys(mtCounts).map(function (m) {
        return { value: m, label: m, count: mtCounts[m] };
      }).sort(function (a, b) { return b.count - a.count; });
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
      categories: categories, subcategories: subcategories, trades: trades,
      divisions: divisions, masterTrades: masterTrades, availableOn: availableOn, sizes: sizes,
      CM: CM
    };
  }

  // filters: { q, cat:[], sub:[], tr:[], div:[], mt:[], avail:[] }
  function apply(tools, filters, vocab) {
    filters = filters || {};
    var q = (filters.q || '').trim().toLowerCase();
    return (tools || []).filter(function (t) {
      if (q) {
        var hay = ((t.n || '') + ' ' + (t.x || '') + ' ' + (t.sub || '') + ' ' + (t.c || []).join(' ')).toLowerCase();
        if (hay.indexOf(q) === -1) return false;
      }
      if (filters.cat && filters.cat.length && !(t.c || []).some(function (c) { return filters.cat.indexOf(c) > -1; })) return false;
      if (filters.sub && filters.sub.length && filters.sub.indexOf(t.sub) === -1) return false;
      if (filters.tr && filters.tr.length && !(t.tr || []).some(function (tr) { return filters.tr.indexOf(tr) > -1; })) return false;
      // Both read the vendor's own classification now, not a guess made from
      // its software category.
      if (filters.div && filters.div.length && filters.div.indexOf(t.dv) === -1) return false;
      if (filters.mt && filters.mt.length && filters.mt.indexOf(t.mt) === -1) return false;
      if (filters.avail && filters.avail.length) {
        var av = avail(t.sz);
        if (!filters.avail.some(function (a) { return av.indexOf(a) > -1; })) return false;
      }
      if (filters.sz && filters.sz.length && filters.sz.indexOf(t.sz) === -1) return false;
      return true;
    });
  }

  // Reads repeated query-string keys (?cat=a&cat=b) into arrays.
  function readParams(search) {
    var sp = new URLSearchParams(search);
    return {
      q: sp.get('q') || '',
      cat: sp.getAll('cat'),
      sub: sp.getAll('sub'),
      tr: sp.getAll('tr'),
      div: sp.getAll('div'),
      mt: sp.getAll('mt'),
      avail: sp.getAll('avail'),
      sz: sp.getAll('sz')
    };
  }

  function toParams(filters) {
    var sp = new URLSearchParams();
    if (filters.q) sp.set('q', filters.q);
    ['cat', 'sub', 'tr', 'div', 'mt', 'avail', 'sz'].forEach(function (k) {
      (filters[k] || []).forEach(function (v) { sp.append(k, v); });
    });
    return sp;
  }

  return { CM: CM, avail: avail, build: build, apply: apply, readParams: readParams, toParams: toParams };
})();
