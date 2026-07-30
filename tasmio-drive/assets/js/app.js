/* ===== Tasmio Drive — front-end explorer ===== */
(function () {
  "use strict";
  const API = "api.php";
  const CSRF = window.TASMIO.csrf;

  const $ = (s, r = document) => r.querySelector(s);
  const state = {
    path: "",            // current folder relative to user's home
    items: [],
    selected: null,      // selected item object
    view: localStorage.getItem("tasmio_view") || "grid",
    searching: false,
  };

  const els = {
    files: $("#files"), empty: $("#empty"), loading: $("#loading"),
    breadcrumbs: $("#breadcrumbs"), statusCount: $("#statusCount"),
    statusSel: $("#statusSel"), ctx: $("#ctxmenu"), quota: $("#quota"),
    dropzone: $("#dropzone"), main: $(".main"), sidebar: $(".sidebar"),
  };

  /* ---------- helpers ---------- */
  function toast(msg, isErr) {
    const t = $("#toast");
    t.textContent = msg; t.className = "toast" + (isErr ? " error" : "");
    t.hidden = false;
    clearTimeout(t._h); t._h = setTimeout(() => (t.hidden = true), 3200);
  }
  function iconFor(it) {
    if (it.is_folder) return "📁";
    const ext = (it.name.split(".").pop() || "").toLowerCase();
    const map = {
      pdf:"📕", doc:"📘", docx:"📘", xls:"📗", xlsx:"📗", ppt:"📙", pptx:"📙",
      png:"🖼️", jpg:"🖼️", jpeg:"🖼️", gif:"🖼️", webp:"🖼️", svg:"🖼️", bmp:"🖼️",
      mp4:"🎬", mov:"🎬", webm:"🎬", avi:"🎬", mkv:"🎬",
      mp3:"🎵", wav:"🎵", flac:"🎵", ogg:"🎵", m4a:"🎵",
      zip:"🗜️", rar:"🗜️", "7z":"🗜️", tar:"🗜️", gz:"🗜️",
      txt:"📄", md:"📄", csv:"📊", json:"🧩", xml:"🧩",
      js:"📜", ts:"📜", php:"📜", py:"📜", html:"🌐", css:"🎨",
    };
    return map[ext] || "📄";
  }
  function fmtSize(b) {
    if (!b) return "";
    const u = ["B","KB","MB","GB","TB"]; let i = 0; b = +b;
    while (b >= 1024 && i < u.length - 1) { b /= 1024; i++; }
    return (i ? b.toFixed(1) : b) + " " + u[i];
  }
  function fmtDate(s) {
    if (!s) return "";
    try { return new Date(s).toLocaleDateString(undefined,{year:"numeric",month:"short",day:"numeric"}); }
    catch (e) { return ""; }
  }

  async function api(action, opts = {}) {
    const isPost = !!opts.body;
    let url = API + "?action=" + encodeURIComponent(action);
    if (opts.query) url += "&" + new URLSearchParams(opts.query).toString();
    const res = await fetch(url, {
      method: isPost ? "POST" : "GET",
      body: opts.body || undefined,
    });
    const data = await res.json().catch(() => ({ ok:false, error:"Bad server response" }));
    if (!data.ok) throw new Error(data.error || ("HTTP " + res.status));
    return data;
  }

  /* ---------- rendering ---------- */
  function setView(v) {
    state.view = v;
    localStorage.setItem("tasmio_view", v);
    els.files.className = "files " + v;
    document.querySelectorAll(".vt").forEach(b =>
      b.classList.toggle("active", b.dataset.view === v));
  }

  function render() {
    els.files.className = "files " + state.view;
    els.files.innerHTML = "";
    if (state.view === "list") {
      const head = document.createElement("div");
      head.className = "head";
      head.innerHTML = '<span class="ic"></span><span class="h-name">Name</span>' +
        '<span class="h-meta">Modified</span><span class="h-meta">Size</span>';
      els.files.appendChild(head);
    }
    els.empty.hidden = state.items.length > 0;
    state.items.forEach(it => els.files.appendChild(renderItem(it)));
    els.statusCount.textContent = state.items.length + " item" + (state.items.length === 1 ? "" : "s");
    clearSelection();
  }

  function renderItem(it) {
    const el = document.createElement("div");
    el.className = "item";
    el.dataset.id = it.id;

    if (it.thumb) {
      const img = document.createElement("img");
      img.className = "thumb";
      img.alt = "";
      // Attach the error handler BEFORE setting src — a fast-failing request
      // (e.g. a local 404) can fire "error" before a later-attached handler
      // ever gets a chance to run.
      img.onerror = () => {
        const fallback = document.createElement("span");
        fallback.className = "ic";
        fallback.textContent = iconFor(it);
        img.replaceWith(fallback);
      };
      img.src = it.thumb;
      el.appendChild(img);
    } else {
      const icon = document.createElement("span");
      icon.className = "ic";
      icon.textContent = iconFor(it);
      el.appendChild(icon);
    }

    const nm = document.createElement("span");
    nm.className = "nm";
    nm.textContent = it.name;
    el.appendChild(nm);

    const dateSpan = document.createElement("span");
    dateSpan.className = "meta meta-date";
    dateSpan.textContent = fmtDate(it.modified);
    el.appendChild(dateSpan);

    const sizeSpan = document.createElement("span");
    sizeSpan.className = "meta meta-size";
    sizeSpan.textContent = it.is_folder ? "" : fmtSize(it.size);
    el.appendChild(sizeSpan);

    el.addEventListener("click", e => { e.stopPropagation(); select(it, el); });
    el.addEventListener("dblclick", () => open(it));
    el.addEventListener("contextmenu", e => {
      e.preventDefault(); select(it, el); showCtx(e.clientX, e.clientY, it);
    });
    // long-press for touch context menu
    let lp;
    el.addEventListener("touchstart", e => {
      lp = setTimeout(() => { select(it, el);
        const t = e.touches[0]; showCtx(t.clientX, t.clientY, it); }, 500);
    }, { passive: true });
    el.addEventListener("touchend", () => clearTimeout(lp));
    el.addEventListener("touchmove", () => clearTimeout(lp));
    return el;
  }

  function renderBreadcrumbs() {
    els.breadcrumbs.innerHTML = "";
    const parts = state.path ? state.path.split("/") : [];
    const home = document.createElement("a");
    home.className = "crumb"; home.textContent = "🏠 Home"; home.href = "#";
    home.onclick = e => { e.preventDefault(); navigate(""); };
    els.breadcrumbs.appendChild(home);
    let acc = "";
    parts.forEach(p => {
      acc = acc ? acc + "/" + p : p;
      const sep = document.createElement("span");
      sep.className = "crumb-sep"; sep.textContent = "›";
      els.breadcrumbs.appendChild(sep);
      const target = acc;
      const c = document.createElement("a");
      c.className = "crumb"; c.textContent = p; c.href = "#";
      c.onclick = e => { e.preventDefault(); navigate(target); };
      els.breadcrumbs.appendChild(c);
    });
  }

  /* ---------- selection ---------- */
  function clearSelection() {
    state.selected = null;
    document.querySelectorAll(".item.selected").forEach(n => n.classList.remove("selected"));
    els.statusSel.textContent = "";
    toggleActions(false);
  }
  function select(it, el) {
    document.querySelectorAll(".item.selected").forEach(n => n.classList.remove("selected"));
    el.classList.add("selected");
    state.selected = it;
    els.statusSel.textContent = it.name + (it.is_folder ? "" : " · " + fmtSize(it.size));
    toggleActions(true, it);
  }
  function toggleActions(on, it) {
    $("#btnDownload").disabled = !on || (it && it.is_folder);
    $("#btnRename").disabled = !on;
    $("#btnDelete").disabled = !on;
  }

  /* ---------- navigation ---------- */
  async function navigate(path) {
    state.path = path; state.searching = false;
    renderBreadcrumbs();
    els.loading.hidden = false; els.files.innerHTML = ""; els.empty.hidden = true;
    try {
      const d = await api("list", { query: { path } });
      state.items = d.items;
      render();
    } catch (e) { toast(e.message, true); state.items = []; render(); }
    finally { els.loading.hidden = true; }
  }

  function open(it) {
    if (it.is_folder) navigate(state.path ? state.path + "/" + it.name : it.name);
    else download(it);
  }

  function download(it) {
    if (!it || it.is_folder) return;
    window.location.href = API + "?action=download&id=" + encodeURIComponent(it.id);
  }

  /* ---------- mutations ---------- */
  async function doMkdir(name) {
    const fd = new FormData();
    fd.append("csrf", CSRF); fd.append("path", state.path); fd.append("name", name);
    try { await api("mkdir", { body: fd }); toast("Folder created"); navigate(state.path); }
    catch (e) { toast(e.message, true); }
  }
  async function doRename(it, name) {
    const fd = new FormData();
    fd.append("csrf", CSRF); fd.append("id", it.id); fd.append("name", name);
    try { await api("rename", { body: fd }); toast("Renamed"); navigate(state.path); }
    catch (e) { toast(e.message, true); }
  }
  async function doDelete(it) {
    if (!confirm('Delete "' + it.name + '"? It will go to the OneDrive Recycle Bin.')) return;
    const fd = new FormData();
    fd.append("csrf", CSRF); fd.append("id", it.id);
    try { await api("delete", { body: fd }); toast("Deleted"); navigate(state.path); }
    catch (e) { toast(e.message, true); }
  }
  async function uploadFiles(fileList) {
    const files = Array.from(fileList);
    if (!files.length) return;
    for (const f of files) {
      toast("Uploading " + f.name + "…");
      const fd = new FormData();
      fd.append("csrf", CSRF); fd.append("path", state.path); fd.append("file", f);
      try { await api("upload", { body: fd }); }
      catch (e) { toast(f.name + ": " + e.message, true); }
    }
    toast(files.length + " file" + (files.length > 1 ? "s" : "") + " uploaded");
    navigate(state.path);
  }

  async function search(q) {
    if (!q.trim()) { state.searching = false; return navigate(state.path); }
    state.searching = true;
    els.loading.hidden = false; els.files.innerHTML = "";
    try {
      const d = await api("search", { query: { q } });
      state.items = d.items; render();
      els.breadcrumbs.innerHTML = '<span class="crumb">🔎 Results for “' + q + '”</span>';
    } catch (e) { toast(e.message, true); }
    finally { els.loading.hidden = true; }
  }

  async function loadQuota() {
    try {
      const d = await api("quota");
      if (!d.quota) return;
      const used = fmtSize(d.quota.used), total = fmtSize(d.quota.total);
      const pct = d.quota.total ? (d.quota.used / d.quota.total * 100).toFixed(1) : 0;
      els.quota.innerHTML = "Storage<br>" + used + " of " + total +
        '<div class="qbar"><div style="width:' + pct + '%"></div></div>';
    } catch (e) {/* ignore */}
  }

  /* ---------- context menu ---------- */
  function showCtx(x, y, it) {
    const m = els.ctx;
    m.hidden = false;
    m.querySelector('[data-cmd="download"]').style.display = it.is_folder ? "none" : "";
    const vw = window.innerWidth, vh = window.innerHeight;
    m.style.left = Math.min(x, vw - m.offsetWidth - 8) + "px";
    m.style.top = Math.min(y, vh - m.offsetHeight - 8) + "px";
    m._item = it;
  }
  function hideCtx() { els.ctx.hidden = true; }
  els.ctx.addEventListener("click", e => {
    const cmd = e.target.dataset.cmd; const it = els.ctx._item;
    hideCtx(); if (!cmd || !it) return;
    if (cmd === "open") open(it);
    else if (cmd === "download") download(it);
    else if (cmd === "rename") promptModal("Rename", it.name, v => doRename(it, v));
    else if (cmd === "delete") doDelete(it);
  });

  /* ---------- modal ---------- */
  function promptModal(title, value, cb) {
    const back = $("#modalBack"), input = $("#modalInput");
    $("#modalTitle").textContent = title; input.value = value || "";
    back.hidden = false; input.focus(); input.select();
    const ok = () => { const v = input.value.trim(); cleanup(); if (v) cb(v); };
    const cancel = () => cleanup();
    function cleanup() {
      back.hidden = true;
      $("#modalOk").onclick = null; $("#modalCancel").onclick = null; input.onkeydown = null;
    }
    $("#modalOk").onclick = ok; $("#modalCancel").onclick = cancel;
    input.onkeydown = e => { if (e.key === "Enter") ok(); if (e.key === "Escape") cancel(); };
  }

  /* ---------- events ---------- */
  function bind() {
    $("#btnRefresh").onclick = () => navigate(state.path);
    $("#btnNewFolder").onclick = () => promptModal("New folder", "New folder", doMkdir);
    $("#btnUpload").onclick = () => $("#fileInput").click();
    $("#fileInput").onchange = e => { uploadFiles(e.target.files); e.target.value = ""; };
    $("#btnDownload").onclick = () => state.selected && download(state.selected);
    $("#btnRename").onclick = () => state.selected &&
      promptModal("Rename", state.selected.name, v => doRename(state.selected, v));
    $("#btnDelete").onclick = () => state.selected && doDelete(state.selected);

    document.querySelectorAll(".vt").forEach(b => b.onclick = () => setView(b.dataset.view));

    // sidebar home
    document.querySelector('.side-item[data-path=""]').onclick = e => {
      e.preventDefault(); navigate(""); closeSidebar();
    };

    // search (debounced)
    let st;
    $("#searchBox").addEventListener("input", e => {
      clearTimeout(st); const q = e.target.value;
      st = setTimeout(() => search(q), 350);
    });

    // click empty area clears selection / hide menus
    els.files.addEventListener("click", clearSelection);
    document.addEventListener("click", hideCtx);
    document.addEventListener("scroll", hideCtx, true);
    window.addEventListener("resize", hideCtx);

    // drag & drop upload
    ["dragenter","dragover"].forEach(ev => els.main.addEventListener(ev, e => {
      e.preventDefault(); els.dropzone.hidden = false;
    }));
    ["dragleave","drop"].forEach(ev => els.main.addEventListener(ev, e => {
      e.preventDefault();
      if (ev === "drop" && e.dataTransfer.files.length) uploadFiles(e.dataTransfer.files);
      if (ev === "dragleave" && e.relatedTarget && els.main.contains(e.relatedTarget)) return;
      els.dropzone.hidden = true;
    }));

    // keyboard shortcuts
    document.addEventListener("keydown", e => {
      if (e.target.matches("input")) return;
      if (e.key === "Delete" && state.selected) doDelete(state.selected);
      if (e.key === "F2" && state.selected)
        promptModal("Rename", state.selected.name, v => doRename(state.selected, v));
      if (e.key === "F5") { e.preventDefault(); navigate(state.path); }
    });

    // mobile: tap title to toggle sidebar
    $(".tb-icon").onclick = () => els.sidebar.classList.toggle("open");
  }
  function closeSidebar() { els.sidebar.classList.remove("open"); }

  /* ---------- init ---------- */
  function init() {
    setView(state.view);
    bind();
    if (window.TASMIO.connected) { navigate(""); loadQuota(); }
    else { els.empty.hidden = false; els.empty.textContent =
      "Storage isn’t connected yet. An admin needs to finish OneDrive setup."; }
  }
  init();
})();
