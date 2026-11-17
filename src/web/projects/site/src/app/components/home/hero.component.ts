import { Component, PLATFORM_ID, inject } from '@angular/core';
import { DOCUMENT, isPlatformServer } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PATHS } from '../../core/site-paths';

const HERO_IMAGE = 'assets/hero-dashboard.webp';

@Component({
  selector: 'app-home-hero',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="hero" id="inicio">
      <div class="copy" [style.background-image]="heroBackground">
        <h1 class="v2-display" i18n="@@home.hero.title">Tecnología que<br>hace avanzar<br>tu negocio.</h1>
        <p i18n="@@home.hero.sub">Software a medida, infraestructura y soporte para convertir tus proyectos en realidad.</p>
        <a class="v2-btn-lime" [routerLink]="paths.contact" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
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
      /* Botones apilados: "Portal de asistencia" debajo de "Hablemos de tu proyecto", del mismo ancho. */
      .copy a{display:block;width:100%;max-width:340px;text-align:center}
      .outline{margin:12px 0 0}
    }
  `],
})
export class HomeHeroComponent {
  readonly paths = PATHS;
  readonly heroBackground = `url(${HERO_IMAGE})`;

  constructor() {
    // El fondo del hero es el LCP de la home: el prerender pide la imagen desde el <head> con prioridad alta,
    // en vez de esperar a que el navegador lo descubra al aplicar estilos.
    if (!isPlatformServer(inject(PLATFORM_ID))) return;
    const doc = inject(DOCUMENT);
    const link = doc.createElement('link');
    // setAttribute: el DOM del prerender (domino) no implementa la propiedad link.as.
    for (const [k, v] of [['rel', 'preload'], ['as', 'image'], ['href', HERO_IMAGE], ['fetchpriority', 'high']]) link.setAttribute(k, v);
    doc.head.appendChild(link);
  }
}
