import { Component } from '@angular/core';

@Component({
  selector: 'app-home-contact',
  standalone: true,
  template: `
    <section id="contacto">
      <div class="copy">
        <p class="v2-label" i18n="@@home.contact.label">EMPECEMOS</p>
        <h2 class="v2-display" i18n="@@home.contact.title">Cuéntanos qué necesita<br>tu negocio.</h2>
        <p class="contact-copy" i18n="@@home.contact.text">Analizamos tu contexto, definimos el camino y construimos una solución que puedas sostener.</p>
        <div class="actions">
          <a class="v2-btn-lime" href="mailto:info&#64;rtres.net" i18n="@@home.contact.proposal">Pedir una propuesta</a>
          <a class="whatsapp" href="https://wa.me/393281915399" target="_blank" rel="noopener" i18n="@@home.contact.whatsapp">Escribir por WhatsApp ↗</a>
        </div>
      </div>
      <!-- Foto de stock (Unsplash, licencia libre): reemplazable por una foto propia del equipo. -->
      <div class="photo" style="background-image:url('assets/photos/contact-team.jpg')" role="img" i18n-aria-label="@@home.contact.photo" aria-label="Equipo trabajando en un proyecto"></div>
    </section>
  `,
  styles: [`
    :host{display:block}
    section{display:grid;grid-template-columns:1.1fr .9fr;background:var(--v2-paper)}
    .copy{padding:105px 5%}
    h2{max-width:800px;margin-bottom:35px}
    .contact-copy{max-width:540px;color:var(--v2-muted);font-size:18px;margin:-15px 0 30px}
    .actions{display:flex;flex-wrap:wrap;align-items:center;gap:20px}
    .whatsapp{font-weight:bold;border-bottom:1px solid}
    /* Duotono: la luminosidad de la foto sobre el lima de la marca. */
    .photo{min-height:460px;background-color:var(--v2-lime);background-position:center;background-size:cover;background-repeat:no-repeat;background-blend-mode:luminosity}
    @media(max-width:850px){
      section{grid-template-columns:1fr}
      .photo{min-height:260px;order:-1}
      .copy{padding:70px 7%}
    }
  `],
})
export class HomeContactComponent {}
