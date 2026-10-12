import { Component, DestroyRef, Input, LOCALE_ID, inject, signal } from '@angular/core';
import { NavigationEnd, Router } from '@angular/router';
import { filter } from 'rxjs';
import { Locale, translatePath } from '../../core/site-paths';

/** Selector de idioma: lleva a la misma página en el otro idioma (core/site-paths.ts traduce el slug). */
@Component({
  selector: 'app-lang-links',
  standalone: true,
  template: `@for (l of langs; track l; let last = $last) {<a [href]="'/' + l + translatePath(path(), l)" [class.active]="l === locale" [attr.hreflang]="l" [attr.aria-current]="l === locale ? 'page' : null">{{ l.toUpperCase() }}</a>@if (separator && !last) {<span aria-hidden="true">{{ separator }}</span>}}`,
  styles: [`.active{font-weight:bold}`],
})
export class LangLinksComponent {
  @Input() separator = '';
  readonly locale = inject(LOCALE_ID).slice(0, 2);
  readonly langs: Locale[] = ['es', 'en', 'it'];
  /** Los slugs cambian por idioma: /es/nosotros ↔ /en/about. */
  readonly translatePath = (path: string, to: Locale) => translatePath(path, to, this.locale as Locale);
  private router = inject(Router);
  /** "/servicios/software-a-medida", o "/" en el home. */
  path = signal(this.current());

  constructor() {
    const sub = this.router.events.pipe(filter(e => e instanceof NavigationEnd)).subscribe(() => this.path.set(this.current()));
    inject(DestroyRef).onDestroy(() => sub.unsubscribe());
  }

  private current() {
    const path = this.router.url.split(/[?#]/)[0].replace(/\/+$/, '');
    return !path || this.langs.some(l => path === `/${l}`) ? '/' : path;
  }
}
