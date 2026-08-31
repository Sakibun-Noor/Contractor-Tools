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

  var DIV_MAP = {
    'accounting-payroll': ['00 – General', '01 – General Req.'],
    'crm-sales': ['00 – General'],
    'construction-leads': ['01 – General Req.'],
    'estimating-takeoff': ['03 – Concrete', '04 – Masonry', '05 – Metals', '06 – Wood & Plastics', '09 – Finishes'],
    'project-management': ['01 – General Req.', '03 – Concrete', '04 – Masonry', '05 – Metals'],
    'field-service-dispatch': ['01 – General Req.', '03 – Concrete', '04 – Masonry'],
    'safety-compliance': ['01 – General Req.'],
    'fleet-equipment': ['01 – General Req.', '34 – Transportation'],
    'marketing-reputation': ['00 – General'],
    'ai-automation': ['01 – General Req.'],
    'document-management': ['01 – General Req.'],
    'procurement-purchasing': ['00 – General', '01 – General Req.']
  };

  var MT_MAP = {
    'accounting-payroll': 'General Construction & Project Delivery',
    'crm-sales': 'General Construction & Project Delivery',
    'construction-leads': 'General Construction & Project Delivery',
    'estimating-takeoff': 'General Construction & Project Delivery',
    'project-management': 'General Construction & Project Delivery',
    'field-service-dispatch': 'General Construction & Project Delivery',
    'safety-compliance': 'General Construction & Project Delivery',
    'fleet-equipment': 'Mechanical Trades',
    'marketing-reputation': 'General Construction & Project Delivery',
    'ai-automation': 'All Master Trades',
    'document-management': 'General Construction & Project Delivery',
    'procurement-purchasing': 'General Construction & Project Delivery'
  };

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

    // Divisions/master trades aren't stored per-tool — they're derived
    // from each tool's categories via DIV_MAP/MT_MAP. Reverse-index so
    // a division/master-trade value maps back to the category slugs
    // that produce it, letting us filter tools by category membership.
    var divCats = {};
    Object.keys(DIV_MAP).forEach(function (cat) {
      DIV_MAP[cat].forEach(function (div) {
        divCats[div] = divCats[div] || [];
        if (divCats[div].indexOf(cat) === -1) divCats[div].push(cat);
      });
    });
    var divisions = Object.keys(divCats).map(function (div) {
      var cats = divCats[div];
      var count = tools.filter(function (t) { return (t.c || []).some(function (c) { return cats.indexOf(c) > -1; }); }).length;
      return { value: div, label: div, count: count };
    }).sort(function (a, b) { return b.count - a.count; });

    // MASTER TRADE — sourced from the client's taxonomy (11 groups) when
    // assets/taxonomy-data.js is loaded. The old MT_MAP invented three labels
    // ("Mechanical Trades", "All Master Trades") that don't exist in the real
    // hierarchy, which is what correction DS-02 flagged as "Items Missing".
    //
    // Counts stay at 0 until the client's per-vendor classification lands:
    // deriving Master Trade from software category was explicitly ruled out
    // (an estimating tool may serve electrical OR concrete). Entries with a
    // 0 count render disabled rather than filtering to an empty result.
    var mtCats = {};
    Object.keys(MT_MAP).forEach(function (cat) {
      var mt = MT_MAP[cat];
      mtCats[mt] = mtCats[mt] || [];
      if (mtCats[mt].indexOf(cat) === -1) mtCats[mt].push(cat);
    });

    var masterTrades;
    var TAX = (typeof window !== 'undefined' && window.CTD_TAXONOMY) || null;
    if (TAX && TAX.masterTrades && TAX.masterTrades.length) {
      masterTrades = TAX.masterTrades.map(function (m) {
        var count = tools.filter(function (t) { return t.mt === m.name; }).length;
        return { value: m.name, label: m.name, count: count, pending: count === 0 };
      });
    } else {
      masterTrades = Object.keys(mtCats).map(function (mt) {
        var cats = mtCats[mt];
        var count = tools.filter(function (t) { return (t.c || []).some(function (c) { return cats.indexOf(c) > -1; }); }).length;
        return { value: mt, label: mt, count: count };
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
      divCats: divCats, mtCats: mtCats, CM: CM, DIV_MAP: DIV_MAP, MT_MAP: MT_MAP
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
      if (filters.div && filters.div.length) {
        var okDiv = filters.div.some(function (d) {
          var cats = vocab.divCats[d] || [];
          return (t.c || []).some(function (c) { return cats.indexOf(c) > -1; });
        });
        if (!okDiv) return false;
      }
      if (filters.mt && filters.mt.length) {
        var okMt = filters.mt.some(function (m) {
          var cats = vocab.mtCats[m] || [];
          return (t.c || []).some(function (c) { return cats.indexOf(c) > -1; });
        });
        if (!okMt) return false;
      }
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

  return { CM: CM, DIV_MAP: DIV_MAP, MT_MAP: MT_MAP, avail: avail, build: build, apply: apply, readParams: readParams, toParams: toParams };
})();
