/* ═══════════════════════════════════════════════════════════════════
   CTD large-screen scaling (2026-09-18)

   Every page is designed and tested up to 1920 × 1080. On a bigger
   screen - a 4K or ultrawide monitor, or any browser zoomed out - the
   content used to stay capped at ~1,700px wide with 11px text, sitting
   in a narrow strip with most of the screen empty (client report: a
   ~5,100 × 2,000 window showed the pages in the middle third).

   Rule, by screen size only, never by device: when the window is
   bigger than 1920 × 1080 in both directions, the whole page is scaled
   up by the smaller of the two ratios, so it looks exactly like the
   1920 × 1080 layout, just larger. At 1920 × 1080 and below nothing
   changes. Loaded in <head> so the first paint is already scaled.

   Pages that fill exactly one screen divide their 100dvh height by
   --ctd-zoom, because zoom multiplies viewport units too.
   ═══════════════════════════════════════════════════════════════════ */
(function () {
  var DESIGN_W = 1920, DESIGN_H = 1080;
  var root = document.documentElement;

  function fit() {
    var z = Math.min(window.innerWidth / DESIGN_W, window.innerHeight / DESIGN_H);
    // a few pixels over 1920x1080 isn't worth scaling for
    z = z > 1.04 ? Math.round(z * 100) / 100 : 1;
    root.style.zoom = z === 1 ? '' : String(z);
    root.style.setProperty('--ctd-zoom', String(z));
    // lets a page opt into rules that only make sense when scaled up
    root.classList.toggle('ctd-scaled', z !== 1);
  }

  fit();
  var t;
  window.addEventListener('resize', function () {
    clearTimeout(t);
    t = setTimeout(fit, 80);
  });

  // For scripts that position things with viewport maths (e.g. a
  // fixed-position tooltip): the current scale factor.
  window.CTD_zoom = function () {
    return parseFloat(root.style.zoom) || 1;
  };
})();
