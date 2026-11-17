import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HomeTopBarComponent } from '../components/home/top-bar.component';
import { HomeHeaderComponent } from '../components/home/site-header.component';
import { HomeFooterComponent } from '../components/home/site-footer.component';
import { CookieConsentComponent } from '../components/cookie-consent/cookie-consent.component';

/** Marco común de todas las páginas: barra de idiomas, cabecera fija y pie. */
@Component({
  selector: 'app-site-layout',
  standalone: true,
  imports: [RouterOutlet, HomeTopBarComponent, HomeHeaderComponent, HomeFooterComponent, CookieConsentComponent],
  template: `
    <a class="skip-link" href="#main" i18n="@@site.skipLink">Saltar al contenido</a>
    <app-home-top-bar />
    <app-home-header />
    <main id="main" tabindex="-1"><router-outlet /></main>
    <app-home-footer />
    <app-cookie-consent />
  `,
  styles: [`:host{display:block;font-family:Arial,Helvetica,sans-serif;color:var(--v2-ink)}
.skip-link{position:fixed;top:8px;left:8px;z-index:1000;padding:10px 16px;background:var(--v2-ink);color:#fff;font-weight:700;text-decoration:none;transform:translateY(-200%)}
.skip-link:focus{transform:none}
main:focus{outline:none}`],
})
export class SiteLayoutComponent {}
