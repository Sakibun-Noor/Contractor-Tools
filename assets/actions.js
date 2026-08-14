/* ═══════════════════════════════════════════════════════════
   Shared client-side actions: Save Search, Export Results (CSV),
   Share Results (clipboard), Save Vendor. No backend — everything
   persists to localStorage and produces a real file/clipboard write.
   ═══════════════════════════════════════════════════════════ */
window.CTD_ACTIONS = (function () {

  function toast(msg) {
    var el = document.getElementById('ctd-toast');
    if (!el) {
      el = document.createElement('div');
      el.id = 'ctd-toast';
      el.style.cssText = 'position:fixed;left:50%;bottom:28px;transform:translateX(-50%) translateY(20px);' +
        'background:#0F1B2D;color:#fff;padding:11px 20px;border-radius:8px;font:600 13px Inter,system-ui,sans-serif;' +
        'box-shadow:0 8px 24px rgba(0,0,0,.25);z-index:9999;opacity:0;transition:opacity .18s,transform .18s;pointer-events:none;';
      document.body.appendChild(el);
    }
    el.textContent = msg;
    clearTimeout(el._hideTimer);
    requestAnimationFrame(function () {
      el.style.opacity = '1';
      el.style.transform = 'translateX(-50%) translateY(0)';
    });
    el._hideTimer = setTimeout(function () {
      el.style.opacity = '0';
      el.style.transform = 'translateX(-50%) translateY(20px)';
    }, 2200);
  }

  function readList(key) {
    try { return JSON.parse(localStorage.getItem(key) || '[]'); } catch (e) { return []; }
  }
  function writeList(key, list) {
    try { localStorage.setItem(key, JSON.stringify(list)); } catch (e) {}
  }

  // ── Save Search ─────────────────────────────────────────
  function saveSearch(label, url) {
    var list = readList('ctd_saved_searches');
    var existingIdx = list.findIndex(function (s) { return s.url === url; });
    if (existingIdx > -1) {
      list.splice(existingIdx, 1);
      writeList('ctd_saved_searches', list);
      toast('Search removed from Saved Searches');
      return false;
    }
    list.unshift({ label: label, url: url, savedAt: Date.now() });
    if (list.length > 50) list = list.slice(0, 50);
    writeList('ctd_saved_searches', list);
    toast('Search saved (' + list.length + ' saved total)');
    return true;
  }
  function isSearchSaved(url) {
    return readList('ctd_saved_searches').some(function (s) { return s.url === url; });
  }

  // ── Save Vendor ──────────────────────────────────────────
  function toggleSaveVendor(slug, name) {
    var list = readList('ctd_saved_vendors');
    var idx = list.findIndex(function (v) { return v.slug === slug; });
    if (idx > -1) {
      list.splice(idx, 1);
      writeList('ctd_saved_vendors', list);
      toast(name + ' removed from Saved Vendors');
      return false;
    }
    list.unshift({ slug: slug, name: name, savedAt: Date.now() });
    writeList('ctd_saved_vendors', list);
    toast(name + ' saved (' + list.length + ' vendors saved)');
    return true;
  }
  function isVendorSaved(slug) {
    return readList('ctd_saved_vendors').some(function (v) { return v.slug === slug; });
  }

  // ── Export Results (CSV) ────────────────────────────────
  function csvCell(v) {
    v = v == null ? '' : String(v);
    return /[",\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
  }
  function exportCsv(rows, columns, filename) {
    if (!rows.length) { toast('Nothing to export'); return; }
    var lines = [columns.map(function (c) { return csvCell(c.label); }).join(',')];
    rows.forEach(function (row) {
      lines.push(columns.map(function (c) { return csvCell(c.get(row)); }).join(','));
    });
    var blob = new Blob([lines.join('\r\n')], { type: 'text/csv;charset=utf-8;' });
    var url = URL.createObjectURL(blob);
    var a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
    toast('Exported ' + rows.length + ' vendor' + (rows.length === 1 ? '' : 's') + ' to ' + filename);
  }

  // ── Share (clipboard) ────────────────────────────────────
  function shareUrl(url) {
    url = url || window.location.href;
    function done() { toast('Link copied to clipboard'); }
    function fail() {
      var ta = document.createElement('textarea');
      ta.value = url;
      ta.style.cssText = 'position:fixed;opacity:0;left:-9999px;';
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand('copy'); done(); }
      catch (e) { toast('Copy failed — copy this link: ' + url); }
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url).then(done, fail);
    } else {
      fail();
    }
  }

  return {
    toast: toast,
    saveSearch: saveSearch, isSearchSaved: isSearchSaved,
    toggleSaveVendor: toggleSaveVendor, isVendorSaved: isVendorSaved,
    exportCsv: exportCsv, shareUrl: shareUrl
  };
})();
