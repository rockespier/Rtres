// Genera en la raíz del site estático (dist/site/browser) los archivos SEO que no produce Angular:
//   - sitemap.xml con cada página prerenderizada y sus versiones es/en/it (xhtml:link hreflang + x-default);
//   - robots.txt que apunta al sitemap;
//   - favicon.ico (copiado de scripts/deploy).
// La página 404 de cada idioma la elige site.htaccess.
// Uso: node scripts/deploy/seo-files.mjs <ruta a dist/site/browser>
// Las URLs van sin "/" final (salvo el home de cada idioma), igual que el canonical que pone SeoService.
import { copyFileSync, existsSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = 'https://rtres.net';
const LOCALES = ['es', 'en', 'it'];
const root = process.argv[2];
if (!root || !existsSync(join(root, 'es', 'index.html'))) {
  console.error('Uso: node seo-files.mjs <dist/site/browser> (no se encontró es/index.html)');
  process.exit(1);
}

/** Rutas prerenderizadas de un idioma: carpetas con index.html ("" = home), sin la 404. */
function routes(dir, base = dir) {
  const found = [];
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (!statSync(full).isDirectory() || name === 'assets') continue;
    if (existsSync(join(full, 'index.html'))) found.push(relative(base, full).split(sep).join('/'));
    found.push(...routes(full, base));
  }
  return found;
}

const paths = ['', ...new Set(routes(join(root, 'es')))].filter(p => p !== '404').sort();
const url = (locale, path) => `${SITE}/${locale}/${path}`.replace(/\/$/, path ? '' : '/');
const today = new Date().toISOString().slice(0, 10);

const entries = paths.flatMap(path => LOCALES.map(locale => [
  '  <url>',
  `    <loc>${url(locale, path)}</loc>`,
  `    <lastmod>${today}</lastmod>`,
  ...LOCALES.map(l => `    <xhtml:link rel="alternate" hreflang="${l}" href="${url(l, path)}"/>`),
  `    <xhtml:link rel="alternate" hreflang="x-default" href="${url('es', path)}"/>`,
  '  </url>',
].join('\n')));

writeFileSync(join(root, 'sitemap.xml'),
  `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n${entries.join('\n')}\n</urlset>\n`);
writeFileSync(join(root, 'robots.txt'), `User-agent: *\nAllow: /\nDisallow: /*/404\n\nSitemap: ${SITE}/sitemap.xml\n`);

const here = dirname(fileURLToPath(import.meta.url));
copyFileSync(join(here, 'favicon.ico'), join(root, 'favicon.ico'));
console.log(`sitemap.xml: ${entries.length} URLs (${paths.length} páginas × ${LOCALES.length} idiomas); robots.txt y favicon.ico listos.`);
