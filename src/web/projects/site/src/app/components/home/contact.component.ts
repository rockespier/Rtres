import { Component } from '@angular/core';

@Component({
  selector: 'app-home-contact',
  standalone: true,
  template: `
    <section id="contacto">
      <p class="v2-label" i18n="@@home.contact.label">EMPECEMOS</p>
      <h2 class="v2-display" i18n="@@home.contact.title">Cuéntanos qué necesita<br>tu negocio.</h2>
      <p class="contact-copy" i18n="@@home.contact.text">Analizamos tu contexto, definimos el camino y construimos una solución que puedas sostener.</p>
      <a class="v2-btn-lime" href="mailto:info&#64;rtres.net" i18n="@@home.contact.proposal">Pedir una propuesta</a>
      <a class="whatsapp" href="https://wa.me/393281915399" target="_blank" rel="noopener" i18n="@@home.contact.whatsapp">Escribir por WhatsApp ↗</a>
    </section>
  `,
  styles: [`
    :host{display:block}
    section{padding:105px 5%;background:var(--v2-paper)}
    h2{max-width:800px;margin-bottom:35px}
    .contact-copy{max-width:540px;color:var(--v2-muted);font-size:18px;margin:-15px 0 30px}
    .whatsapp{margin-left:20px;font-weight:bold;border-bottom:1px solid}
  `],
})
export class HomeContactComponent {}
