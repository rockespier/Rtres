import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-home-hero',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="hero" id="inicio">
      <div class="copy" style="background-image:url('assets/hero-dashboard.webp')">
        <h1 class="v2-display" i18n="@@home.hero.title">Tecnología que<br>hace avanzar<br>tu negocio.</h1>
        <p i18n="@@home.hero.sub">Software a medida, infraestructura y soporte para convertir tus proyectos en realidad.</p>
        <a class="v2-btn-lime" routerLink="/" fragment="contacto" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
        <a class="v2-btn-outline outline" routerLink="/" fragment="portal" i18n="@@home.cta.portal">Portal de asistencia</a>
      </div>
    </section>
  `,
  styles: [`
    :host{display:block}
    .hero{position:relative;overflow:hidden}
    .copy{position:relative;z-index:1;min-height:702px;padding:95px 5%;width:100%}
    h1{font-size:clamp(3rem,6vw,5.5rem)}
    p{font-size:22px;color:var(--v2-muted);max-width:520px;margin:32px 0}
    .outline{margin-left:15px}
    @media(max-width:850px){
      .hero{height:auto}
      .copy{width:auto;padding:70px 7%}
    }
  `],
})
export class HomeHeroComponent {}
