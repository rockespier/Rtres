import { Component } from '@angular/core';
import { RouterLink } from '@angular/router';
import { SERVICE_LINKS } from '../../core/site-nav';

interface Service { title: string; text: string; path: string; }

@Component({
  selector: 'app-home-services',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section id="servicios">
      <p class="v2-label" i18n="@@home.services.label">LO QUE HACEMOS</p>
      <h2 class="v2-display" i18n="@@home.services.title">No vendemos piezas<br>sueltas. Construimos la<br>base tecnológica de tu empresa.</h2>
      @for (s of services; track s.title; let i = $index) {
        <a [routerLink]="s.path"><small>{{ (i + 1).toString().padStart(2, '0') }}</small><b>{{ s.title }}</b><em>{{ s.text }}</em>↗</a>
      }
    </section>
  `,
  styles: [`
    :host{display:block}
    section{padding:105px 5%}
    h2{font-size:clamp(2.6rem,5vw,5rem);margin-bottom:55px}
    a{display:grid;grid-template-columns:60px 1fr 1fr 30px;gap:20px;padding:26px 0;border-top:1px solid var(--v2-rule);font-size:29px;transition:.2s}
    a:hover{background:var(--v2-lime);padding-inline:15px}
    small{font-size:12px;color:var(--v2-muted)}
    em{font-size:15px;color:var(--v2-muted);font-style:normal}
    @media(max-width:850px){
      a{grid-template-columns:35px 1fr 25px;font-size:22px}
      em{grid-column:2}
    }
  `],
})
export class HomeServicesComponent {
  readonly services: Service[] = [
    { title: $localize`:@@home.services.1.title:Software a medida`, path: SERVICE_LINKS[0].path, text: $localize`:@@home.services.1.text:Plataformas que ordenan procesos y automatizan tareas.` },
    { title: $localize`:@@home.services.2.title:Apps y experiencias web`, path: SERVICE_LINKS[1].path, text: $localize`:@@home.services.2.text:Productos digitales claros y rápidos.` },
    { title: $localize`:@@home.services.3.title:Integración y automatización`, path: SERVICE_LINKS[2].path, text: $localize`:@@home.services.3.text:ERP, facturación, inventario y servicios conectados.` },
    { title: $localize`:@@home.services.4.title:Hosting, dominios y soporte`, path: SERVICE_LINKS[3].path, text: $localize`:@@home.services.4.text:La operación técnica que mantiene tus sistemas disponibles.` },
  ];
}
