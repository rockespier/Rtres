// Genera en la raíz del site estático (dist/site/browser) los archivos SEO que no produce Angular:
//   - sitemap.xml con cada página prerenderizada y sus versiones en otros idiomas. Las URLs y los hreflang se leen del
//     propio HTML (canonical y <link rel="alternate">, que pone SeoService): los slugs cambian por idioma (site-paths.ts);
//   - robots.txt que apunta al sitemap;
//   - llms.txt con el resumen de la empresa y las páginas por idioma (título y description de cada una);
//   - favicon.ico (copiado de scripts/deploy).
// La página 404 de cada idioma la elige site.htaccess.
// Uso: node scripts/deploy/seo-files.mjs <ruta a dist/site/browser>
import { copyFileSync, existsSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = 'https://rtres.net';
const LOCALES = ['es', 'en', 'it'];
// Solo se escribe dentro de una carpeta dist/site/browser: el script borra y crea archivos en ella.
const root = process.argv[2] ? resolve(process.argv[2]) : '';
if (!root.endsWith(join('dist', 'site', 'browser')) || !existsSync(join(root, 'es', 'index.html'))) {
  console.error('Uso: node seo-files.mjs <dist/site/browser> (no se encontró es/index.html)');
  process.exit(1);
}

/**
 * Angular prerenderiza cada post en los 3 idiomas, pero cada idioma tiene los suyos: las páginas que salieron como 404
 * (noindex) se borran. Lo mismo si la API falló en el build: esa URL la atenderá la página base (site.htaccess).
 */
for (const locale of LOCALES) {
  const blog = join(root, locale, 'blog');
  if (!existsSync(blog)) continue;
  for (const name of readdirSync(blog)) {
    const file = join(blog, name, 'index.html');
    if (name !== '_post' && existsSync(file) && /<meta name="robots" content="[^"]*noindex/.test(readFileSync(file, 'utf8'))) rmSync(join(blog, name), { recursive: true });
  }
}

/** Páginas prerenderizadas (index.html) de un idioma, sin la 404, la página base del blog ni los assets. */
function pages(dir) {
  const found = existsSync(join(dir, 'index.html')) ? [join(dir, 'index.html')] : [];
  for (const name of readdirSync(dir)) {
    const full = join(dir, name);
    if (statSync(full).isDirectory() && name !== 'assets' && name !== '404' && name !== '_post') found.push(...pages(full));
  }
  return found;
}

const attr = (tag, name) => tag.match(new RegExp(`${name}="([^"]*)"`))?.[1];
const today = new Date().toISOString().slice(0, 10);
const entries = [];
/** Páginas indexables para llms.txt: idioma, URL canónica, título (sin la marca) y description. */
const llmsPages = [];
const decode = s => (s ?? '').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
for (const locale of LOCALES) {
  for (const file of pages(join(root, locale))) {
    const html = readFileSync(file, 'utf8');
    if (/<meta name="robots" content="[^"]*noindex/.test(html)) continue;
    const canonical = html.match(/<link rel="canonical"[^>]*>/)?.[0];
    if (!canonical) { console.warn(`Sin canonical: ${file}`); continue; }
    const alternates = [...html.matchAll(/<link rel="alternate"[^>]*hreflang[^>]*>/g)].map(m => m[0]);
    llmsPages.push({
      locale, url: attr(canonical, 'href'),
      title: decode(html.match(/<title>([^<]*)<\/title>/)?.[1]).split(' — ')[0],
      description: decode(attr(html.match(/<meta name="description"[^>]*>/)?.[0] ?? '', 'content')),
    });
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
writeFileSync(join(root, 'llms.txt'), llmsTxt());
writeFileSync(join(root, 'robots.txt'), `User-agent: *\nAllow: /\nDisallow: /*/404\n\nSitemap: ${SITE}/sitemap.xml\n`);

/**
 * llms.txt (https://llmstxt.org): resumen de la empresa y enlaces a las páginas, para asistentes de IA. Una sección por
 * idioma con el home primero; los posts del blog van en "Optional" (prescindibles si el contexto es corto).
 */
function llmsTxt() {
  const LANG = { es: 'Español', en: 'English', it: 'Italiano' };
  const line = p => `- [${p.title}](${p.url})${p.description ? `: ${p.description}` : ''}`;
  const isPost = p => /\/blog\/[^/]+$/.test(p.url);
  // Home, servicios, casos, resto de páginas y, al final, las legales (slugs de site-paths.ts).
  const rank = p => {
    const path = p.url.slice(SITE.length + 4);
    if (!path) return 0;
    if (/^(servicios|services|servizi)\//.test(path)) return 1;
    if (/^(casos|case-studies|casi-di-successo)\//.test(path)) return 2;
    if (/^(privacidad|privacy|aviso-legal|legal-notice|note-legali)$/.test(path)) return 4;
    return 3;
  };
  const sections = LOCALES.map(locale => {
    const list = llmsPages.filter(p => p.locale === locale && !isPost(p)).sort((a, b) => rank(a) - rank(b) || a.url.localeCompare(b.url));
    return `## ${LANG[locale]}\n\n${list.map(line).join('\n')}`;
  });
  const posts = llmsPages.filter(isPost).sort((a, b) => a.url.localeCompare(b.url));
  return [
    '# Rtres Web Solutions',
    '',
    '> RTRES WEB SOLUTIONS S.A.C. (RUC 20517137881) is a software company based in Lima, Peru, founded in 2007 and working with clients in Peru, Spain and Italy. Services: custom software, web applications, integration and automation (SAP, SUNAT e-invoicing, payment gateways) and hosting, domains and support, with a client portal for support tickets.',
    '',
    'Contact: info@rtres.net · +51 942 670 094 (Peru) · +39 328 191 5399 (Italy) · Calle Cabo Blanco 176, Lima 15067, Peru. The site is published in Spanish (/es/), English (/en/) and Italian (/it/).',
    '',
    ...sections.flatMap(s => [s, '']),
    ...(posts.length ? ['## Optional', '', ...posts.map(line), ''] : []),
  ].join('\n');
}

const here = dirname(fileURLToPath(import.meta.url));
copyFileSync(join(here, 'favicon.ico'), join(root, 'favicon.ico'));

console.log(`sitemap.xml: ${entries.length} URLs; llms.txt, robots.txt y favicon.ico listos.`);
