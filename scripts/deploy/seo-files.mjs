// Genera en la raíz del site estático (dist/site/browser) los archivos SEO que no produce Angular:
//   - sitemap.xml con cada página prerenderizada y sus versiones en otros idiomas. Las URLs y los hreflang se leen del
//     propio HTML (canonical y <link rel="alternate">, que pone SeoService): los slugs cambian por idioma (site-paths.ts);
//   - robots.txt que apunta al sitemap;
//   - favicon.ico (copiado de scripts/deploy).
// La página 404 de cada idioma la elige site.htaccess.
// Uso: node scripts/deploy/seo-files.mjs <ruta a dist/site/browser>
import { copyFileSync, existsSync, readFileSync, readdirSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = 'https://rtres.net';
const LOCALES = ['es', 'en', 'it'];
const root = process.argv[2];
if (!root || !existsSync(join(root, 'es', 'index.html'))) {
  console.error('Uso: node seo-files.mjs <dist/site/browser> (no se encontró es/index.html)');
  process.exit(1);
}

/** Páginas prerenderizadas (index.html) de un idioma, sin la 404 ni los assets. */
function pages(dir) {
  const found = existsSync(join(dir, 'index.html')) ? [join(dir, 'index.html')] : [];
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory() && name !== 'assets' && name !== '404') found.push(...pages(full));
  }
  return found;
}

const attr = (tag, name) => tag.match(new RegExp(`${name}="([^"]*)"`))?.[1];
const today = new Date().toISOString().slice(0, 10);
const entries = [];
for (const locale of LOCALES) {
  for (const file of pages(join(root, locale))) {
    const html = readFileSync(file, 'utf8');
    if (/<meta name="robots" content="[^"]*noindex/.test(html)) continue;
    const canonical = html.match(/<link rel="canonical"[^>]*>/)?.[0];
    if (!canonical) { console.warn(`Sin canonical: ${file}`); continue; }
    const alternates = [...html.matchAll(/<link rel="alternate"[^>]*hreflang[^>]*>/g)].map(m => m[0]);
    entries.push([
      '  <url>',
      `    <loc>${attr(canonical, 'href')}</loc>`,
      `    <lastmod>${today}</lastmod>`,
      ...alternates.map(tag => `    <xhtml:link rel="alternate" hreflang="${attr(tag, 'hreflang')}" href="${attr(tag, 'href')}"/>`),
      '  </url>',
    ].join('\n'));
  }
}

writeFileSync(join(root, 'sitemap.xml'),
  `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">\n${entries.join('\n')}\n</urlset>\n`);
writeFileSync(join(root, 'robots.txt'), `User-agent: *\nAllow: /\nDisallow: /*/404\n\nSitemap: ${SITE}/sitemap.xml\n`);

const here = dirname(fileURLToPath(import.meta.url));
copyFileSync(join(here, 'favicon.ico'), join(root, 'favicon.ico'));

console.log(`sitemap.xml: ${entries.length} URLs; robots.txt y favicon.ico listos.`);
