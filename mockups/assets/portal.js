// Applied synchronously (before portal.css paints) to avoid a flash of the wrong theme.
(function () {
  try {
    if (localStorage.getItem('rtres_portal_theme') === 'dark') {
      document.documentElement.dataset.theme = 'dark';
    }
  } catch (e) {}
})();

function togglePortalTheme(isDark) {
  document.documentElement.dataset.theme = isDark ? 'dark' : '';
  try { localStorage.setItem('rtres_portal_theme', isDark ? 'dark' : 'light'); } catch (e) {}
}

document.addEventListener('DOMContentLoaded', function () {
  var toggles = document.querySelectorAll('.theme-toggle-input');
  if (!toggles.length) return;
  var isDark = document.documentElement.dataset.theme === 'dark';
  toggles.forEach(function (cb) {
    cb.checked = isDark;
    cb.addEventListener('change', function () {
      togglePortalTheme(cb.checked);
      toggles.forEach(function (other) { other.checked = cb.checked; });
    });
  });
});
