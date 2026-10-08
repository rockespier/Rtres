import { Component, input } from '@angular/core';
import { RouterLink } from '@angular/router';

/** Banda de cierre de las páginas internas: fondo papel con filete lima, para no fundirse con el pie lima. */
@Component({
  selector: 'app-closing-cta',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section>
      <h2>{{ title() }}</h2>
      <div>
        <a class="dark-btn" routerLink="/" fragment="contacto" i18n="@@home.contact.proposal">Pedir una propuesta</a>
        <a class="whatsapp" href="https://wa.me/393281915399" target="_blank" rel="noopener" i18n="@@home.contact.whatsapp">Escribir por WhatsApp ↗</a>
      </div>
    </section>
  `,
  styles: [`
    :host{display:block}
    section{display:flex;justify-content:space-between;align-items:center;gap:30px;padding:80px 5%;background:var(--v2-paper);border-top:6px solid var(--v2-lime)}
    h2{max-width:720px;margin:0;font-weight:900;font-size:clamp(2rem,3.6vw,3.4rem);letter-spacing:-.04em;line-height:1}
    div{display:flex;align-items:center;gap:22px;flex-shrink:0}
    .dark-btn{background:var(--v2-ink);color:#fff;padding:15px 22px;font-weight:bold}
    .whatsapp{font-weight:bold;border-bottom:1px solid}
    @media(max-width:850px){
      section{flex-direction:column;align-items:flex-start}
      div{flex-wrap:wrap}
    }
  `],
})
export class ClosingCtaComponent {
  title = input.required<string>();
}
