import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { SERVICE_LINKS } from '../../core/site-nav';
import { PublicApiService } from '../../core/public-api.service';

/** Quiénes somos. Fuente: Documentacion/Carta presentacion.docx y Casos de exito Rtres.docx. */
@Component({
  selector: 'app-about-page',
  standalone: true,
  imports: [RouterLink, ClosingCtaComponent],
  template: `
    <section class="hero">
      <p class="v2-label" i18n="@@about.label">QUIÉNES SOMOS</p>
      <h1 class="v2-display" i18n="@@about.title">Socios tecnológicos,<br>no proveedores de paso.</h1>
      <p class="lead" i18n="@@about.lead">Desde 2007 construimos y sostenemos los sistemas de empresas que no pueden detenerse. Con sede en Lima y operación en España e Italia.</p>
    </section>

    <dl class="stats">
      @for (s of stats(); track s.label) {<div><dt>{{ s.value }}</dt><dd>{{ s.label }}</dd></div>}
    </dl>

    <section class="story">
      <p class="v2-label" i18n="@@about.story.label">NUESTRA HISTORIA</p>
      <div>
        <p class="statement" i18n="@@about.story.statement">Empezamos como una firma de desarrollo local. Hoy somos el equipo técnico de empresas en América y Europa, y varios de nuestros primeros clientes siguen con nosotros desde 2008.</p>
        <p class="body" i18n="@@about.story.body">Esa continuidad no es casualidad: entendemos cómo opera cada negocio, evolucionamos sus sistemas al ritmo del mercado y seguimos ahí después de la entrega, con soporte y mejoras continuas.</p>
      </div>
    </section>

    <section class="principles">
      <p class="v2-label" i18n="@@about.principles.label">CÓMO PENSAMOS</p>
      <ol>
        @for (p of principles; track p.title; let i = $index) {<li><small>{{ pad(i + 1) }}</small><b>{{ p.title }}</b><em>{{ p.text }}</em></li>}
      </ol>
    </section>

    <section class="brands">
      <p class="v2-label" i18n="@@about.brands.label">HAN CONFIADO EN NOSOTROS</p>
      <p class="list">@for (b of brands; track b; let last = $last) {<span>{{ b }}</span>@if (!last) {<i aria-hidden="true"> / </i>}}</p>
    </section>

    <section class="services">
      <p class="v2-label" i18n="@@about.services.label">LO QUE HACEMOS</p>
      @for (s of services; track s.path; let i = $index) {<a [routerLink]="s.path"><small>{{ pad(i + 1) }}</small><b>{{ s.label }}</b><span aria-hidden="true">↗</span></a>}
    </section>

    <app-closing-cta [title]="ctaTitle" />
  `,
  styles: [`
    :host{display:block}
    .hero{padding:100px 5% 70px}
    h1{font-size:clamp(3rem,6.6vw,6.6rem);text-wrap:balance}
    .lead{max-width:680px;margin:32px 0 0;font-size:22px;line-height:1.45;color:var(--v2-muted)}
    .stats{display:grid;grid-template-columns:repeat(4,1fr);margin:0;padding:0 5% 90px}
    .stats div{padding:18px 24px 0 0;border-top:2px solid var(--v2-ink)}
    .stats div+div{padding-left:24px;border-left:1px solid var(--v2-line)}
    .stats dt{font-weight:900;font-size:clamp(2.4rem,4.4vw,4.4rem);letter-spacing:-.05em;line-height:1}
    .stats dd{margin:10px 0 0;color:var(--v2-muted);font-size:15px}
    .story{display:grid;grid-template-columns:1fr 3fr;gap:30px;padding:100px 5%;background:var(--v2-paper)}
    .statement{margin:0;font:clamp(1.9rem,3vw,3rem)/1.12 Georgia,serif;letter-spacing:-.03em;text-wrap:balance}
    .body{max-width:680px;margin:30px 0 0;font-size:18px;line-height:1.6;color:var(--v2-muted)}
    .principles{padding:100px 5% 80px}
    .principles ol{list-style:none;margin:30px 0 0;padding:0}
    .principles li{display:grid;grid-template-columns:60px 1fr 1fr;gap:20px;align-items:baseline;padding:28px 0;border-top:1px solid var(--v2-rule)}
    .principles li:last-child{border-bottom:1px solid var(--v2-rule)}
    .principles small{font-size:12px;color:var(--v2-muted)}
    .principles b{font-size:clamp(1.5rem,2.3vw,2rem);letter-spacing:-.03em}
    .principles em{font-style:normal;font-size:16px;line-height:1.5;color:var(--v2-muted)}
    .brands{padding:100px 5%;background:var(--v2-dark);color:#fff}
    .brands .v2-label{color:#c9c9c4}
    .list{margin:0;font-weight:900;font-size:clamp(1.9rem,3.6vw,3.6rem);letter-spacing:-.045em;line-height:1.15}
    .list i{color:var(--v2-lime);font-style:normal;font-weight:400}
    .services{padding:100px 5%}
    .services a{display:grid;grid-template-columns:60px 1fr 30px;gap:20px;padding:24px 0;border-top:1px solid var(--v2-rule);font-size:clamp(1.4rem,2.6vw,2.2rem);transition:.2s}
    .services a:last-child{border-bottom:1px solid var(--v2-rule)}
    .services a:hover{background:var(--v2-lime);padding-inline:15px}
    .services small{font-size:12px;color:var(--v2-muted);align-self:center}
    @media(max-width:850px){
      .hero{padding:60px 7% 50px}
      .stats{grid-template-columns:1fr 1fr;gap:24px 0}
      .stats div,.stats div+div{padding:16px 16px 0 0;border-left:0}
      .story{grid-template-columns:1fr;gap:20px}
      .principles li{grid-template-columns:35px 1fr}
      .principles em{grid-column:2}
      .services a{grid-template-columns:35px 1fr 25px}
    }
  `],
})
export class AboutPageComponent implements OnInit {
  private title = inject(Title);
  private meta = inject(Meta);
  readonly services = SERVICE_LINKS;
  readonly ctaTitle = $localize`:@@about.cta:¿Conversamos sobre tu proyecto?`;
  private api = inject(PublicApiService);
  /** Clientes activos en el portal: se lee en el prerender y otra vez en el navegador, para que esté al día sin recompilar. */
  private activeClients = signal<number | null>(null);
  readonly stats = computed(() => [
    { value: '2007', label: $localize`:@@about.stat1:año de fundación, en Lima` },
    // Espacio fijo mientras carga (o si la API no responde): la fila no cambia de alto.
    { value: this.activeClients()?.toString() ?? ' ', label: $localize`:@@about.stat2:clientes activos en nuestro portal` },
    { value: '3', label: $localize`:@@about.stat3:países: Perú, España e Italia` },
    { value: '300+', label: $localize`:@@about.stat4:talleres conectados en un solo sistema` },
  ]);
  readonly principles = [
    { title: $localize`:@@about.p1.title:Relaciones largas`, text: $localize`:@@about.p1.text:Preferimos un cliente por quince años que quince proyectos sueltos. Por eso diseñamos pensando en el mantenimiento.` },
    { title: $localize`:@@about.p2.title:Visión global, ejecución local`, text: $localize`:@@about.p2.text:Entendemos el mercado peruano y su normativa, y trabajamos con los estándares de un equipo internacional.` },
    { title: $localize`:@@about.p3.title:Madurez para lo crítico`, text: $localize`:@@about.p3.text:Procesos, seguridad y experiencia para sostener sistemas de los que dependen ventas, talleres y operaciones 24/7.` },
    { title: $localize`:@@about.p4.title:Calidad hasta el final`, text: $localize`:@@about.p4.text:Desde la primera línea de código hasta el soporte posterior a la entrega, la prioridad es que funcione y se use.` },
  ];
  readonly brands = ['Kawasaki', 'Bajaj', 'Euroamerican Assistance', 'Travel Solutions Assistance', 'SOS 24', 'Building Connections', 'Alliance', 'Triz', 'Soldimix', $localize`:@@about.brand.surf:Asociación Latinoamericana de Surf`, $localize`:@@about.brand.fpt:Federación Peruana de Tabla`];

  ngOnInit() {
    this.api.getStats().subscribe(s => this.activeClients.set(s?.activeClients ?? null));
    this.title.setTitle($localize`:@@about.metaTitle:Quiénes somos — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: $localize`:@@about.meta:Rtres Web Solutions: socios tecnológicos desde 2007, con sede en Lima y operación en España e Italia. Software a medida, integración y soporte.` });
  }

  pad(n: number) { return n.toString().padStart(2, '0'); }
}
