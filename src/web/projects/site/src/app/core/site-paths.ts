/**
 * Rutas de cada página por idioma (slugs traducidos: PLAN-seo.md, T6). Es la única fuente: la usan las rutas, los
 * menús y enlaces, los hreflang de SeoService, el selector de idioma y el sitemap (que lee los hreflang del prerender).
 * El español conserva los slugs originales; las URLs viejas en español bajo /en y /it redirigen con 301 (site.htaccess).
 */
export type Locale = 'es' | 'en' | 'it';
export const LOCALES: Locale[] = ['es', 'en', 'it'];

/**
 * Idioma del bundle: un mensaje traducido que el build reemplaza por "en" o "it" (igual en el navegador y en el
 * prerender; no depende del LOCALE_ID ni de la URL).
 */
export const LOCALE = $localize`:@@site.localeCode:es` as Locale;

export const PAGE_PATHS = {
  'service:software-a-medida': { es: 'servicios/software-a-medida', en: 'services/custom-software', it: 'servizi/software-su-misura' },
  'service:apps-y-experiencias-web': { es: 'servicios/apps-y-experiencias-web', en: 'services/web-apps', it: 'servizi/app-web' },
  'service:integracion-y-automatizacion': { es: 'servicios/integracion-y-automatizacion', en: 'services/integration-and-automation', it: 'servizi/integrazione-e-automazione' },
  'service:hosting-dominios-y-soporte': { es: 'servicios/hosting-dominios-y-soporte', en: 'services/hosting-domains-and-support', it: 'servizi/hosting-domini-e-supporto' },
  'case:euroamerican-assistance': { es: 'casos/euroamerican-assistance', en: 'case-studies/euroamerican-assistance', it: 'casi-di-successo/euroamerican-assistance' },
  'case:grupo-crosland': { es: 'casos/grupo-crosland', en: 'case-studies/grupo-crosland', it: 'casi-di-successo/grupo-crosland' },
  'case:alas-global-tour': { es: 'casos/alas-global-tour', en: 'case-studies/alas-global-tour', it: 'casi-di-successo/alas-global-tour' },
  about: { es: 'nosotros', en: 'about', it: 'chi-siamo' },
  resources: { es: 'recursos', en: 'resources', it: 'risorse' },
  contact: { es: 'contacto', en: 'contact', it: 'contatti' },
} satisfies Record<string, Record<Locale, string>>;

export type PageId = keyof typeof PAGE_PATHS;

/** Ruta de la página en el idioma actual, con "/" inicial (para routerLink): "/services/custom-software". */
export const pagePath = (id: PageId) => '/' + PAGE_PATHS[id][LOCALE];
export const servicePath = (slug: string) => pagePath(`service:${slug}` as PageId);
export const casePath = (slug: string) => pagePath(`case:${slug}` as PageId);

/** Accesos directos para las plantillas. */
export const PATHS = { about: pagePath('about'), resources: pagePath('resources'), contact: pagePath('contact') };

/**
 * La misma página en otro idioma: "/services/custom-software" (en) → "/servicios/software-a-medida" (es). Las rutas que
 * no están en la tabla (el home, la 404) son iguales en todos los idiomas.
 */
export function translatePath(path: string, to: Locale, from: Locale = LOCALE) {
  const clean = path.replace(/^\/+|\/+$/g, '');
  const entry = Object.values(PAGE_PATHS).find(p => p[from] === clean);
  return '/' + (entry ? entry[to] : clean);
}
