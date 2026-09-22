/* ═══════════════════════════════════════════════════════════
   CTD — autosuggest for the main header search bar (client
   round, 2026-09-20 corrections doc: "Install Autosuggestions
   IN THE MAIN SEARCH BAR"). Suggests matching Vendors, Products
   and Categories as the user types, from the live window.TOOLS
   data already loaded on every page. Load after tools-data.js
   (and taxonomy-data.js/filters.js when the page has them) and
   call CTD_AUTOSUGGEST.init('hdr-q') once per page.

   Each page keeps its own Enter/submit behavior (doSearch,
   doHdrSearch, or a plain form submit) — this module only adds
   a dropdown on top and intercepts Enter/click when a suggestion
   is actually highlighted or clicked. Typing free text and
   pressing Enter with nothing highlighted still falls through to
   the page's normal search exactly as before.
   ═══════════════════════════════════════════════════════════ */
window.CTD_AUTOSUGGEST = (function () {
  var MAX_RESULTS = 8;

  function esc(s) {
    return String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  // Built once per page load from window.TOOLS — vendors, their real
  // products, and the 12 categories. Re-reads TOOLS lazily on first use so
  // init() can be called before tools-data.js finishes if ever needed.
  var index = null;
  function buildIndex() {
    var tools = window.TOOLS || [];
    var CM = (window.CTD_FILTERS && window.CTD_FILTERS.build(tools).CM) || {};
    var out = [];
    var seenProd = {};
    tools.forEach(function (t) {
      out.push({ type: 'Vendor', label: t.n, sub: t.d || '', go: 'vendor-profile.html?s=' + encodeURIComponent(t.s) });
      (t.products || []).forEach(function (p) {
        if (!p.n || seenProd[p.n]) return;
        seenProd[p.n] = true;
        out.push({ type: 'Product', label: p.n, sub: '', go: 'results.html?prod=' + encodeURIComponent(p.n) });
      });
    });
    Object.keys(CM).forEach(function (slug) {
      out.push({ type: 'Category', label: CM[slug], sub: '', go: 'results.html?cat=' + encodeURIComponent(slug) });
    });
    return out;
  }

  function match(q) {
    if (!index) index = buildIndex();
    q = q.trim().toLowerCase();
    if (!q) return [];
    var starts = [], contains = [];
    for (var i = 0; i < index.length; i++) {
      var l = index[i].label.toLowerCase();
      var at = l.indexOf(q);
      if (at === 0) starts.push(index[i]);
      else if (at > 0) contains.push(index[i]);
      if (starts.length >= MAX_RESULTS) break;
    }
    return starts.concat(contains).slice(0, MAX_RESULTS);
  }

  var TYPE_COLOR = { Vendor: '#1B5FD0', Product: '#158526', Category: '#E8600F' };

  function init(inputId) {
    var input = document.getElementById(inputId);
    if (!input || input._ctdAutosuggestInit) return;
    input._ctdAutosuggestInit = true;

    var wrap = input.parentElement;
    if (getComputedStyle(wrap).position === 'static') wrap.style.position = 'relative';

    var box = document.createElement('div');
    box.className = 'ctd-suggest-box';
    box.setAttribute('role', 'listbox');
    box.style.cssText = 'display:none;position:absolute;left:0;right:0;top:100%;margin-top:4px;' +
      'background:#fff;border:1px solid #d9e1ee;border-radius:8px;box-shadow:0 8px 24px rgba(15,27,45,.12);' +
      'max-height:340px;overflow-y:auto;z-index:60;text-align:left;';
    wrap.appendChild(box);

    var items = [];
    var activeIdx = -1;

    function itemHtml(it, i) {
      var color = TYPE_COLOR[it.type] || '#6B7793';
      return '<div class="ctd-suggest-item" data-i="' + i + '" role="option" style="display:flex;align-items:center;' +
        'gap:8px;padding:8px 12px;cursor:pointer;font-size:13px;color:#0F1B2D;' +
        (i === activeIdx ? 'background:#eef3fd;' : '') + '">' +
        '<span style="flex:none;font-size:9.5px;font-weight:700;letter-spacing:.03em;text-transform:uppercase;' +
        'color:' + color + ';border:1px solid ' + color + ';border-radius:4px;padding:1px 5px;">' + it.type + '</span>' +
        '<span style="flex:1 1 auto;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + esc(it.label) + '</span>' +
        (it.sub ? '<span style="flex:none;color:#6B7793;font-size:11px;">' + esc(it.sub) + '</span>' : '') +
        '</div>';
    }

    function render() {
      if (!items.length) { close(); return; }
      box.innerHTML = items.map(itemHtml).join('');
      box.style.display = 'block';
      box.querySelectorAll('.ctd-suggest-item').forEach(function (el) {
        el.addEventListener('mousedown', function (e) {
          e.preventDefault();
          go(items[+el.getAttribute('data-i')]);
        });
        el.addEventListener('mouseenter', function () {
          activeIdx = +el.getAttribute('data-i');
          highlight();
        });
      });
    }

    function highlight() {
      box.querySelectorAll('.ctd-suggest-item').forEach(function (el) {
        el.style.background = (+el.getAttribute('data-i') === activeIdx) ? '#eef3fd' : '';
      });
    }

    function close() {
      box.style.display = 'none';
      box.innerHTML = '';
      items = [];
      activeIdx = -1;
    }

    function go(it) {
      if (!it) return;
      close();
      location.href = it.go;
    }

    input.addEventListener('input', function () {
      items = match(input.value);
      activeIdx = -1;
      render();
    });

    input.addEventListener('keydown', function (e) {
      if (box.style.display === 'none' && e.key !== 'ArrowDown') return;
      if (e.key === 'ArrowDown') {
        if (!items.length) { items = match(input.value); render(); }
        if (!items.length) return;
        e.preventDefault();
        activeIdx = Math.min(items.length - 1, activeIdx + 1);
        highlight();
        box.children[activeIdx] && box.children[activeIdx].scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'ArrowUp') {
        e.preventDefault();
        activeIdx = Math.max(0, activeIdx - 1);
        highlight();
        box.children[activeIdx] && box.children[activeIdx].scrollIntoView({ block: 'nearest' });
      } else if (e.key === 'Enter') {
        if (activeIdx >= 0 && items[activeIdx]) {
          e.preventDefault();
          go(items[activeIdx]);
        }
        // else: no suggestion highlighted, let the page's own submit run.
      } else if (e.key === 'Escape') {
        close();
      }
    });

    input.addEventListener('blur', function () {
      // Delay so a mousedown on a suggestion registers before the box closes.
      setTimeout(close, 150);
    });
  }

  return { init: init };
})();
