import { Component } from '@angular/core';
import { LangLinksComponent } from './lang-links.component';

@Component({
  selector: 'app-home-footer',
  standalone: true,
  imports: [LangLinksComponent],
  template: `
    <footer>
      <img src="assets/logo-rtres.png" alt="Rtres">
      <p class="tagline" i18n="@@home.footer.tagline">Profesionales en soluciones web.</p>
      <div>
        <b i18n="@@home.footer.services">Servicios</b>
        <a href="#servicios" i18n="@@home.services.1.title">Software a medida</a>
        <a href="#servicios" i18n="@@home.services.2.title">Apps y experiencias web</a>
        <a href="#servicios" i18n="@@home.footer.hosting">Hosting y soporte</a>
      </div>
      <div>
        <b i18n="@@home.footer.company">Empresa</b>
        <a href="#nosotros" i18n="@@home.nav.about">Nosotros</a>
        <a href="#casos" i18n="@@home.nav.cases">Casos de éxito</a>
        <a href="#portal" i18n="@@home.footer.reviews">Opiniones</a>
      </div>
      <div>
        <b i18n="@@home.footer.contact">Contacto</b>
        <a href="mailto:info&#64;rtres.net">info&#64;rtres.net</a>
        <a href="tel:+393281915399">+39 328 191 5399</a>
      </div>
      <div class="langs"><app-lang-links separator=" · " /></div>
    </footer>
  `,
  styles: [`
    :host{display:block}
    footer{display:grid;grid-template-columns:2fr 1fr 1fr 1fr;gap:30px;padding:70px 5%;border-top:1px solid var(--v2-line)}
    img{width:125px}
    b,a{display:block;margin-bottom:10px}
    .tagline{align-self:center;color:var(--v2-muted)}
    .langs{align-self:end;font-size:12px;letter-spacing:.12em}
    .langs ::ng-deep a{display:inline;margin:0}
    @media(max-width:850px){
      footer{grid-template-columns:1fr 1fr}
    }
  `],
})
export class HomeFooterComponent {}
