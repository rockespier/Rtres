// Genera la lista de posts del blog que el build production prerenderiza (angular.json, prerender.routesFile).
// Angular prerenderiza cada ruta en los 3 idiomas, pero cada idioma tiene sus propios posts: las páginas que no
// corresponden salen como 404 (noindex) y seo-files.mjs las borra después del build.
// Si la API no responde, el build sigue: los posts se verán igual, cargados en el navegador (ver site.htaccess).
// Uso: node scripts/deploy/blog-routes.mjs <archivo de salida> [URL de la API]
import { writeFileSync } from 'node:fs';

const [output, api = 'https://api.rtres.net/api'] = process.argv.slice(2);
if (!output) {
  console.error('Uso: node blog-routes.mjs <archivo de salida> [URL de la API]');
  process.exit(1);
}

const routes = new Set();
for (const locale of ['es', 'en', 'it']) {
  try {
    const response = await fetch(`${api}/public/${locale}/blog`, { signal: AbortSignal.timeout(60000) });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    for (const post of await response.json()) routes.add(`/blog/${post.slug}`);
  } catch (error) {
    console.warn(`AVISO: no se pudieron leer los posts de ${locale} (${error.message}); no se prerenderizarán en este deploy.`);
  }
}

writeFileSync(output, [...routes].join('\n') + '\n');
console.log(`Blog: ${routes.size} posts para prerenderizar.`);
