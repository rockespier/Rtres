import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { CASE_LINKS, SERVICE_LINKS } from '../../core/site-nav';
import { LangLinksComponent } from './lang-links.component';

@Component({
  selector: 'app-home-footer',
  standalone: true,
  imports: [RouterLink, LangLinksComponent],
  template: `
    <footer>
      <div class="brand">
        <!-- Sobre lima el logo gris/lima se pierde: se muestra en una sola tinta oscura. -->
        <a routerLink="/"><img src="assets/logo-rtres.png" alt="Rtres — inicio"></a>
        <p class="tagline" i18n="@@home.footer.tagline">Profesionales en soluciones web.</p>
      </div>
      <div>
        <b i18n="@@home.footer.services">Servicios</b>
        @for (l of services; track l.path) {<a [routerLink]="l.path">{{ l.label }}</a>}
      </div>
      <div>
        <b i18n="@@home.footer.company">Empresa</b>
        <a routerLink="/nosotros" i18n="@@home.nav.about">Nosotros</a>
        @for (l of cases; track l.path) {<a [routerLink]="l.path">{{ l.label }}</a>}
        <a routerLink="/recursos" i18n="@@home.nav.resources">Recursos</a>
        <a routerLink="/" fragment="portal" i18n="@@home.footer.reviews">Opiniones</a>
      </div>
      <div>
        <b i18n="@@home.footer.contact">Contacto</b>
        <a href="mailto:info&#64;rtres.net">info&#64;rtres.net</a>
        <a href="tel:+393281915399">+39 328 191 5399</a>
        <a href="https://wa.me/393281915399" target="_blank" rel="noopener">WhatsApp ↗</a>
      </div>
      <div class="bottom">
        <small>© {{ year }} Rtres Web Solutions</small>
        <div class="langs"><app-lang-links separator=" · " /></div>
      </div>
    </footer>
  `,
  styles: [`
    :host{display:block}
    footer{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:30px;padding:70px 5% 28px;background:var(--v2-lime);color:var(--v2-ink)}
    img{width:125px;filter:brightness(0)}
    .tagline{margin:18px 0 0;max-width:260px;font-size:15px}
    b{display:block;margin-bottom:14px;font-size:11px;letter-spacing:.2em;text-transform:uppercase}
    footer>div:not(.brand)>a{display:block;margin-bottom:10px}
    footer a:hover{text-decoration:underline;text-underline-offset:3px}
    .bottom{grid-column:1/-1;display:flex;justify-content:space-between;align-items:center;gap:20px;margin-top:30px;padding-top:22px;border-top:1px solid rgba(20,20,20,.25);font-size:12px}
    .langs{letter-spacing:.12em}
    .langs ::ng-deep a{display:inline;margin:0}
    @media(max-width:850px){
      footer{grid-template-columns:1fr 1fr}
      .brand{grid-column:1/-1}
      .bottom{flex-direction:column;align-items:flex-start}
    }
  `],
})
export class HomeFooterComponent {
  readonly services = SERVICE_LINKS;
  readonly cases = CASE_LINKS;
  readonly year = new Date().getFullYear();
}
