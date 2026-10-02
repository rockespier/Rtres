import { Component } from '@angular/core';

interface SuccessCase { sector: string; name: string; scope: string; menu: string[]; panel: string; }

@Component({
  selector: 'app-home-cases',
  standalone: true,
  template: `
    <section id="casos">
      <p class="v2-label case-label" i18n="@@home.cases.label">CASOS DE ÉXITO</p>
      <h2 class="v2-display" i18n="@@home.cases.title">Sistemas que sostienen <mark>operaciones reales.</mark></h2>
      <p class="intro" i18n="@@home.cases.sub">Dos proyectos, dos sectores y años de evolución tecnológica.</p>
      <div class="cases">
        @for (c of cases; track c.name) {
          <article>
            <small>{{ c.sector }}</small>
            <h3>{{ c.name }}</h3>
            <b>{{ c.scope }}</b>
            <div class="dash" aria-hidden="true">
              <aside>◉ {{ c.menu[0] }}<br>{{ c.menu[1] }}<br>{{ c.menu[2] }}</aside>
              <div>{{ c.panel }}<hr><i></i><i></i></div>
            </div>
          </article>
        }
      </div>
      <footer>
        <small class="rule" i18n="@@home.cases.rule1">TECNOLOGÍA<br>QUE TRABAJA<br>CON VOS.</small>
        <b><ng-container i18n="@@home.cases.footer.title">Mismos principios, distintos desafíos.</ng-container><em i18n="@@home.cases.footer.text">Sistemas sólidos, equipos que evolucionan y operaciones que no se detienen.</em></b>
        <small class="rule" i18n="@@home.cases.rule2">IDEAS<br>SISTEMAS<br>RESULTADOS</small>
      </footer>
    </section>
  `,
  styles: [`
    :host{display:block}
    section{padding:105px 5% 0}
    .case-label:before{content:"";display:inline-block;width:30px;border-top:1px solid;margin:0 12px 4px 0}
    h2{font-size:clamp(2.7rem,5.5vw,5.1rem);text-wrap:balance}
    mark{background:none;color:var(--v2-mark)}
    .intro{margin:22px 0 0;font-size:clamp(1.25rem,2vw,1.75rem);line-height:1.3}
    .cases{display:grid;grid-template-columns:1fr 1fr;margin-top:48px}
    article{padding-right:35px}
    article+article{padding-left:35px;padding-right:0;border-left:1px solid var(--v2-rule)}
    h3{font-size:40px;margin:15px 0}
    .dash{height:270px;margin-top:25px;display:grid;grid-template-columns:130px 1fr;background:#f8f8f8}
    .dash aside{background:#202826;color:#fff;padding:16px;line-height:2.5;font-size:12px}
    .dash>div{padding:22px}
    .dash i{display:block;height:75px;border-bottom:1px solid var(--v2-line);background:linear-gradient(170deg,transparent 45%,var(--v2-mark) 46% 49%,transparent 50%)}
    footer{display:grid;grid-template-columns:1fr 3fr 1fr;gap:30px;align-items:center;min-height:136px;margin:0 -5vw;padding:28px 5vw;background:var(--v2-lime)}
    footer b{font-size:24px}
    footer em{display:block;font-size:15px;font-style:normal;font-weight:normal;margin-top:5px}
    .rule{border-left:1px solid;padding-left:18px;letter-spacing:.18em;font-size:10px}
    @media(max-width:850px){
      .cases,footer{grid-template-columns:1fr}
      article,article+article{padding:0 0 40px;border:0}
    }
  `],
})
export class HomeCasesComponent {
  readonly cases: SuccessCase[] = [
    {
      sector: $localize`:@@home.cases.1.sector:SECTOR · ASISTENCIA AL VIAJERO`,
      name: 'Euroamerican Assistance',
      scope: $localize`:@@home.cases.1.scope:Desde 2008 · Ventas, comisiones y BI`,
      menu: ['Dashboard', $localize`:@@home.cases.1.menu2:Ventas`, $localize`:@@home.cases.1.menu3:Comisiones`],
      panel: $localize`:@@home.cases.1.menu2:Ventas`,
    },
    {
      sector: $localize`:@@home.cases.2.sector:SECTOR · AUTOMOTRIZ / POSVENTA`,
      name: 'Grupo Crosland',
      scope: $localize`:@@home.cases.2.scope:DMS · SAP · Garantías`,
      menu: [$localize`:@@home.cases.2.menu1:Taller`, $localize`:@@home.cases.2.menu2:Órdenes`, $localize`:@@home.cases.2.menu3:Garantías`],
      panel: $localize`:@@home.cases.2.panel:Operaciones`,
    },
  ];
}
