import { DOCUMENT } from '@angular/common';
import { Injectable, LOCALE_ID, inject } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';
import { Locale, translatePath } from './site-paths';

export const SITE_URL = 'https://rtres.net';
export const SITE_LOCALES = ['es', 'en', 'it'] as const;
const OG_LOCALES: Record<string, string> = { es: 'es_PE', en: 'en_US', it: 'it_IT' };
const HOME_LABEL: Record<string, string> = { es: 'Inicio', en: 'Home', it: 'Home' };

/**
 * Etiquetas SEO que dependen de la URL, en cada navegación (también en el prerender):
 * - canonical absoluto: sin "/" final, salvo el home de cada idioma (/es/);
 * - alternates hreflang es/en/it y x-default (español);
 * - Open Graph y Twitter con el título y la descripción que fijó la página;
 * - JSON-LD: Organization en todo el sitio y BreadcrumbList en las páginas internas.
 */
@Injectable({ providedIn: 'root' })
export class SeoService {
  private document = inject(DOCUMENT);
  private router = inject(Router);
  private locale = inject(LOCALE_ID).slice(0, 2);

  /** Preguntas frecuentes de la página actual (FAQPage); la página las fija en ngOnInit y valen solo para esa navegación. */
  private faq: { q: string; a: string }[] | null = null;
  setFaq(items: { q: string; a: string }[]) { this.faq = items; }

  init() {
    // Las páginas fijan título y description en ngOnInit: se leen después de que la vista nueva se haya creado.
    this.router.events.pipe(filter(e => e instanceof NavigationEnd)).subscribe(() => setTimeout(() => this.update()));
  }

  /** Ruta sin idioma, query ni fragmento: "/servicios/software-a-medida" o "" para el home. */
  private path() {
    const path = this.router.url.split(/[?#]/)[0].replace(/\/+$/, '');
    // En el dev server el idioma puede venir como primer segmento (/en): no es parte de la página.
    return SITE_LOCALES.some(l => path === `/${l}`) ? '' : path;
  }

  private url(locale: string, path: string) { return `${SITE_URL}/${locale}${path || '/'}`; }
  /** La misma página en otro idioma (los slugs están traducidos: core/site-paths.ts). */
  private alternate(locale: Locale, path: string) { return this.url(locale, path ? translatePath(path, locale, this.locale as Locale) : ''); }

  update() {
    const head = this.document.head;
    const path = this.path();
    const canonical = this.url(this.locale, path);
    const title = this.document.title;
    const description = head.querySelector<HTMLMetaElement>('meta[name="description"]')?.content ?? '';

    // Una página noindex (404) no declara canonical ni versiones en otros idiomas.
    const noindex = !!head.querySelector('meta[name="robots"][content*="noindex"]');
    if (noindex) head.querySelectorAll('link[rel="canonical"], link[rel="alternate"][hreflang]').forEach(el => el.remove());
    else {
      this.link('canonical', canonical);
      for (const l of SITE_LOCALES) this.link('alternate', this.alternate(l, path), l);
      this.link('alternate', this.alternate('es', path), 'x-default');
    }

    const image = `${SITE_URL}/${this.locale}/assets/og-image.jpg`;
    this.meta('property', 'og:type', 'website');
    this.meta('property', 'og:site_name', 'Rtres Web Solutions');
    this.meta('property', 'og:title', title);
    this.meta('property', 'og:description', description);
    this.meta('property', 'og:url', canonical);
    this.meta('property', 'og:image', image);
    this.meta('property', 'og:image:width', '1200');
    this.meta('property', 'og:image:height', '630');
    this.meta('property', 'og:locale', OG_LOCALES[this.locale] ?? 'es_PE');
    this.meta('name', 'twitter:card', 'summary_large_image');
    this.meta('name', 'twitter:title', title);
    this.meta('name', 'twitter:description', description);
    this.meta('name', 'twitter:image', image);

    this.jsonLd('ld-organization', {
      '@context': 'https://schema.org', '@type': 'Organization', '@id': `${SITE_URL}/#organization`,
      name: 'Rtres Web Solutions', url: `${SITE_URL}/${this.locale}/`, logo: `${SITE_URL}/es/assets/logo-rtres.png`,
      email: 'info@rtres.net', telephone: '+39 328 191 5399', foundingDate: '2007',
      address: { '@type': 'PostalAddress', addressLocality: 'Lima', addressCountry: 'PE' },
      areaServed: ['PE', 'IT', 'ES'],
    });
    this.jsonLd('ld-faq', this.faq?.length && !noindex ? {
      '@context': 'https://schema.org', '@type': 'FAQPage',
      mainEntity: this.faq.map(f => ({ '@type': 'Question', name: f.q, acceptedAnswer: { '@type': 'Answer', text: f.a } })),
    } : null);
    this.faq = null;
    // Páginas internas: Inicio › página (el nombre es el título sin la marca).
    this.jsonLd('ld-breadcrumb', path && !noindex ? {
      '@context': 'https://schema.org', '@type': 'BreadcrumbList', itemListElement: [
        { '@type': 'ListItem', position: 1, name: HOME_LABEL[this.locale] ?? 'Inicio', item: this.url(this.locale, '') },
        { '@type': 'ListItem', position: 2, name: title.split(' — ')[0], item: canonical },
      ],
    } : null);
  }

  private link(rel: string, href: string, hreflang?: string) {
    const selector = hreflang ? `link[rel="${rel}"][hreflang="${hreflang}"]` : `link[rel="${rel}"]:not([hreflang])`;
    let el = this.document.head.querySelector<HTMLLinkElement>(selector);
    if (!el) { el = this.document.createElement('link'); el.rel = rel; if (hreflang) el.hreflang = hreflang; this.document.head.appendChild(el); }
    el.href = href;
  }

  private meta(attr: 'name' | 'property', key: string, content: string) {
    let el = this.document.head.querySelector<HTMLMetaElement>(`meta[${attr}="${key}"]`);
    if (!el) { el = this.document.createElement('meta'); el.setAttribute(attr, key); this.document.head.appendChild(el); }
    el.setAttribute('content', content);
  }

  private jsonLd(id: string, data: object | null) {
    let el = this.document.getElementById(id);
    if (!data) { el?.remove(); return; }
    if (!el) { el = this.document.createElement('script'); el.id = id; el.setAttribute('type', 'application/ld+json'); this.document.head.appendChild(el); }
    el.textContent = JSON.stringify(data);
  }
}
