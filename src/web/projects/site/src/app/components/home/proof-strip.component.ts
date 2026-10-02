import { Component } from '@angular/core';

@Component({
  selector: 'app-home-proof',
  standalone: true,
  template: `
    <section class="proof">
      <p i18n="@@home.proof.text">Desde la idea hasta la operación diaria, un solo equipo para resolver necesidades tecnológicas.</p>
      <div>
        <b i18n="@@home.proof.software">Software</b>
        <b i18n="@@home.proof.infra">Infraestructura</b>
        <b i18n="@@home.proof.support">Soporte</b>
        <b i18n="@@home.proof.continuity">Continuidad</b>
      </div>
    </section>
  `,
  styles: [`
    :host{display:block}
    .proof{display:flex;justify-content:space-between;align-items:center;padding:28px 5%;border-block:1px solid var(--v2-line)}
    p{max-width:430px;color:var(--v2-muted);margin:0}
    div{display:flex;gap:45px}
    @media(max-width:850px){
      .proof{display:block}
      div{margin-top:18px;flex-wrap:wrap}
    }
  `],
})
export class HomeProofComponent {}
