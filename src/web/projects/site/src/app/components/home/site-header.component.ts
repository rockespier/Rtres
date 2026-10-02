import { Component } from '@angular/core';

@Component({
  selector: 'app-home-header',
  standalone: true,
  template: `
    <header>
      <a href="#inicio"><img src="assets/logo-rtres.png" alt="Rtres"></a>
      <nav>
        <a href="#servicios"><ng-container i18n="@@home.nav.solutions">Soluciones</ng-container> <span class="chev">⌄</span></a>
        <a href="#sectores"><ng-container i18n="@@home.nav.sectors">Sectores</ng-container> <span class="chev">⌄</span></a>
        <a href="#nosotros" i18n="@@home.nav.about">Nosotros</a>
        <a href="#casos" i18n="@@home.nav.cases">Casos de éxito</a>
        <a href="#recursos"><ng-container i18n="@@home.nav.resources">Recursos</ng-container> <span class="chev">⌄</span></a>
      </nav>
      <div>
        <a class="v2-btn-lime" href="#contacto" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
        <a class="portal-link" href="#portal" i18n="@@home.cta.portal">Portal de asistencia</a>
      </div>
    </header>
  `,
  styles: [`
    :host{display:block;position:relative;z-index:2}
    header{height:88px;display:grid;grid-template-columns:150px 1fr auto;align-items:center;gap:24px;padding:0 5%}
    img{width:120px}
    nav{display:flex;justify-content:center;gap:30px;font-size:14px}
    .chev{font-size:11px;display:inline-block;transform:translateY(-1px)}
    .portal-link{margin-left:18px;border-bottom:.8px solid}
    @media(max-width:850px){
      header{grid-template-columns:1fr auto}
      nav,.portal-link{display:none}
    }
  `],
})
export class HomeHeaderComponent {}
