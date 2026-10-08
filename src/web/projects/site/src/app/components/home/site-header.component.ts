import { Component, DestroyRef, inject, signal } from '@angular/core';
import { NavigationEnd, Router, RouterLink, RouterLinkActive } from '@angular/router';
import { filter } from 'rxjs';
import { CASE_LINKS, NavLink, SERVICE_LINKS } from '../../core/site-nav';
import { LangLinksComponent } from './lang-links.component';

type Menu = 'services' | 'cases' | null;

/** Cabecera fija: queda visible al hacer scroll (se compacta) y en móvil abre un panel con todo el menú. */
@Component({
  selector: 'app-home-header',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, LangLinksComponent],
  host: { '[class.scrolled]': 'scrolled()', '(window:scroll)': 'onScroll()', '(document:keydown.escape)': 'closeAll()' },
  template: `
    <header>
      <a routerLink="/" class="logo" (click)="closeAll()"><img src="assets/logo-rtres.png" alt="Rtres — inicio"></a>

      <nav aria-label="Principal" i18n-aria-label="@@site.nav.aria">
        <div class="dd" (mouseenter)="open.set('services')" (mouseleave)="open.set(null)">
          <button type="button" [attr.aria-expanded]="open() === 'services'" aria-controls="menu-services" (click)="toggle('services')"><ng-container i18n="@@home.nav.solutions">Soluciones</ng-container> <span class="chev" aria-hidden="true">⌄</span></button>
          @if (open() === 'services') { <ul id="menu-services">@for (l of services; track l.path) {<li><a [routerLink]="l.path" routerLinkActive="active" (click)="closeAll()">{{ l.label }}</a></li>}</ul> }
        </div>
        <div class="dd" (mouseenter)="open.set('cases')" (mouseleave)="open.set(null)">
          <button type="button" [attr.aria-expanded]="open() === 'cases'" aria-controls="menu-cases" (click)="toggle('cases')"><ng-container i18n="@@home.nav.cases">Casos de éxito</ng-container> <span class="chev" aria-hidden="true">⌄</span></button>
          @if (open() === 'cases') { <ul id="menu-cases">@for (l of cases; track l.path) {<li><a [routerLink]="l.path" routerLinkActive="active" (click)="closeAll()">{{ l.label }}</a></li>}</ul> }
        </div>
        <a routerLink="/nosotros" routerLinkActive="active" i18n="@@home.nav.about">Nosotros</a>
        <a routerLink="/recursos" routerLinkActive="active" i18n="@@home.nav.resources">Recursos</a>
      </nav>

      <div class="actions">
        <a class="v2-btn-lime" routerLink="/" fragment="contacto" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
        <a class="portal-link" routerLink="/" fragment="portal" i18n="@@home.cta.portal">Portal de asistencia</a>
        <button type="button" class="burger" [attr.aria-expanded]="mobile()" aria-controls="mobile-menu" (click)="mobile.set(!mobile())">
          <span class="sr-only" i18n="@@site.nav.menu">Menú</span><i></i><i></i><i></i>
        </button>
      </div>
    </header>

    @if (mobile()) {
      <div id="mobile-menu" class="mobile">
        <p class="v2-label" i18n="@@home.nav.solutions">Soluciones</p>
        @for (l of services; track l.path) {<a [routerLink]="l.path" (click)="closeAll()">{{ l.label }}</a>}
        <p class="v2-label" i18n="@@home.nav.cases">Casos de éxito</p>
        @for (l of cases; track l.path) {<a [routerLink]="l.path" (click)="closeAll()">{{ l.label }}</a>}
        <hr>
        <a routerLink="/nosotros" (click)="closeAll()" i18n="@@home.nav.about">Nosotros</a>
        <a routerLink="/recursos" (click)="closeAll()" i18n="@@home.nav.resources">Recursos</a>
        <a routerLink="/" fragment="portal" (click)="closeAll()" i18n="@@home.cta.portal">Portal de asistencia</a>
        <a class="v2-btn-lime cta" routerLink="/" fragment="contacto" (click)="closeAll()" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
        <div class="langs"><app-lang-links separator=" · " /></div>
      </div>
    }
  `,
  styles: [`
    :host{display:block;position:sticky;top:0;z-index:50;background:#fff;transition:box-shadow .2s}
    :host(.scrolled){box-shadow:0 1px 0 var(--v2-line),0 10px 30px -22px rgba(0,0,0,.35)}
    header{height:88px;display:grid;grid-template-columns:150px 1fr auto;align-items:center;gap:24px;padding:0 5%;transition:height .2s}
    :host(.scrolled) header{height:68px}
    .logo img{width:120px;transition:width .2s}
    :host(.scrolled) .logo img{width:96px}
    nav{display:flex;justify-content:center;align-items:center;gap:30px;font-size:14px}
    nav>a,.dd>button{padding:8px 0;border-bottom:2px solid transparent;background:none;font:inherit;color:inherit;cursor:pointer}
    nav>a.active,nav>a:hover,.dd>button:hover,.dd>button[aria-expanded=true]{border-color:var(--v2-lime)}
    .dd{position:relative}
    .dd ul{position:absolute;top:100%;left:-18px;min-width:260px;margin:0;padding:10px 0;list-style:none;background:#fff;border:1px solid var(--v2-line);box-shadow:0 18px 40px -24px rgba(0,0,0,.35)}
    .dd ul a{display:block;padding:10px 18px}
    .dd ul a:hover,.dd ul a.active{background:var(--v2-lime)}
    .chev{font-size:11px;display:inline-block;transform:translateY(-1px)}
    .actions{display:flex;align-items:center}
    .portal-link{margin-left:18px;border-bottom:.8px solid}
    .burger{display:none;width:44px;height:44px;margin-left:12px;border:0;background:none;cursor:pointer;flex-direction:column;justify-content:center;gap:5px;padding:0 10px}
    .burger i{display:block;height:2px;background:var(--v2-ink)}
    .sr-only{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap}
    .mobile{display:flex;flex-direction:column;gap:2px;max-height:calc(100vh - 68px);overflow:auto;padding:20px 7% 30px;border-top:1px solid var(--v2-line);background:#fff}
    .mobile .v2-label{margin:18px 0 6px;color:var(--v2-muted)}
    .mobile a{padding:10px 0;font-size:18px}
    .mobile hr{width:100%;border:0;border-top:1px solid var(--v2-line);margin:14px 0 6px}
    .mobile .cta{margin-top:16px;text-align:center}
    .mobile .langs{margin-top:16px;font-size:12px;letter-spacing:.12em}
    .mobile .langs ::ng-deep a{padding:0;font-size:12px}
    @media(max-width:850px){
      header{grid-template-columns:1fr auto;height:68px}
      nav,.portal-link,.actions>.v2-btn-lime{display:none}
      .burger{display:flex}
      .logo img{width:96px}
    }
  `],
})
export class HomeHeaderComponent {
  readonly services: NavLink[] = SERVICE_LINKS;
  readonly cases: NavLink[] = CASE_LINKS;
  open = signal<Menu>(null);
  mobile = signal(false);
  scrolled = signal(false);

  constructor() {
    const router = inject(Router);
    const sub = router.events.pipe(filter(e => e instanceof NavigationEnd)).subscribe(() => this.closeAll());
    inject(DestroyRef).onDestroy(() => sub.unsubscribe());
  }

  /** En SSR no hay scroll; el listener de window solo existe en el navegador. */
  onScroll() { this.scrolled.set(window.scrollY > 24); }

  toggle(menu: Exclude<Menu, null>) { this.open.set(this.open() === menu ? null : menu); }
  closeAll() { this.open.set(null); this.mobile.set(false); }
}
