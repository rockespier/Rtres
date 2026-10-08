import { Component, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { PROCESS_STEPS, SERVICES, ServiceContent } from './service-content';

/** Plantilla de las páginas de servicio; el contenido sale de SERVICES según el slug de la ruta. */
@Component({
  selector: 'app-service-page',
  standalone: true,
  imports: [RouterLink, ClosingCtaComponent],
  template: `
    @if (s; as s) {
      <section class="hero">
        <div class="copy">
          <p class="v2-label"><span i18n="@@service.label">SERVICIOS</span> · {{ s.index }}</p>
          <h1 class="v2-display">{{ s.title }}</h1>
          <p class="lead">{{ s.lead }}</p>
          <div class="ctas">
            <a class="v2-btn-lime" routerLink="/" fragment="contacto" i18n="@@home.cta.talk">Hablemos de tu proyecto</a>
            @if (s.relatedCase) { <a class="v2-btn-outline" [routerLink]="s.relatedCase.path" i18n="@@service.seeCase">Ver un caso real</a> }
          </div>
        </div>
        <div class="visual" role="img" [attr.aria-label]="s.title" [style.background-image]="'url(' + s.image + ')'" [style.background-position]="s.imagePosition"></div>
      </section>

      <section class="problem">
        <p class="v2-label">{{ s.problemLabel }}</p>
        <p class="statement">{{ s.problem }}</p>
      </section>

      <section class="build">
        <p class="v2-label" i18n="@@service.build.label">QUÉ CONSTRUIMOS</p>
        <ol>
          @for (r of s.rows; track r.title; let i = $index) {
            <li><small>{{ pad(i + 1) }}</small><b>{{ r.title }}</b><em>{{ r.text }}</em></li>
          }
        </ol>
      </section>

      <section class="specs">
        <div>
          <p class="v2-label" i18n="@@service.deliverables.label">LO QUE RECIBES</p>
          <ul>@for (d of s.deliverables; track d) {<li>{{ d }}</li>}</ul>
        </div>
        <div>
          <p class="v2-label" i18n="@@service.tech.label">TECNOLOGÍA E INTEGRACIONES</p>
          <p class="tech">@for (t of s.technologies; track t; let last = $last) {<span>{{ t }}</span>@if (!last) {<i aria-hidden="true"> · </i>}}</p>
          <p class="v2-label process-label" i18n="@@service.process.label">CÓMO TRABAJAMOS</p>
          <ol class="process">
            @for (p of steps; track p.title; let i = $index) {<li><small>{{ pad(i + 1) }}</small><b>{{ p.title }}</b><span>{{ p.text }}</span></li>}
          </ol>
        </div>
      </section>

      @if (s.relatedCase; as c) {
        <a class="case" [routerLink]="c.path">
          <p class="v2-label" i18n="@@service.case.label">CASO REAL</p>
          <h2>{{ c.name }}</h2>
          <p class="scope">{{ c.scope }}</p>
          <p class="quote">{{ c.quote }}</p>
          <span class="more"><ng-container i18n="@@service.case.more">Ver el caso completo</ng-container> <b aria-hidden="true">→</b></span>
        </a>
      }

      <app-closing-cta [title]="s.ctaTitle" />
    }
  `,
  styles: [`
    :host{display:block}
    .hero{display:grid;grid-template-columns:1.05fr .95fr;min-height:620px;border-bottom:1px solid var(--v2-line)}
    .copy{display:flex;flex-direction:column;justify-content:center;padding:80px 5%}
    h1{font-size:clamp(2.8rem,5.2vw,5.8rem);text-wrap:balance;hyphens:auto}
    .lead{max-width:560px;margin:30px 0 36px;font-size:21px;line-height:1.45;color:var(--v2-muted)}
    .ctas{display:flex;flex-wrap:wrap;gap:14px}
    .visual{background:#f0f0ea no-repeat;background-size:cover;filter:grayscale(.15) contrast(1.02)}
    .problem{display:grid;grid-template-columns:1fr 3fr;gap:30px;padding:100px 5%;background:var(--v2-paper)}
    .statement{margin:0;font:clamp(1.9rem,3vw,3rem)/1.12 Georgia,serif;letter-spacing:-.03em;text-wrap:balance}
    .build{padding:100px 5% 60px}
    .build ol{list-style:none;margin:30px 0 0;padding:0}
    .build li{display:grid;grid-template-columns:60px 1fr 1fr;gap:20px;align-items:baseline;padding:28px 0;border-top:1px solid var(--v2-rule)}
    .build li:last-child{border-bottom:1px solid var(--v2-rule)}
    .build small{font-size:12px;color:var(--v2-muted)}
    .build b{font-size:clamp(1.5rem,2.3vw,2rem);letter-spacing:-.03em}
    .build em{font-style:normal;font-size:16px;line-height:1.5;color:var(--v2-muted)}
    .specs{display:grid;grid-template-columns:1fr 1fr;gap:80px;padding:60px 5% 110px}
    .specs ul{list-style:none;margin:0;padding:0}
    .specs ul li{padding:16px 0;border-top:1px solid var(--v2-line);font-size:18px}
    .specs ul li:before{content:"✓";display:inline-block;width:28px;color:var(--v2-mark);font-weight:bold}
    .tech{margin:0;font-size:22px;font-weight:bold;letter-spacing:-.02em;line-height:1.5}
    .tech i{color:var(--v2-mark);font-style:normal}
    .process-label{margin-top:50px}
    .process{list-style:none;margin:0;padding:0;display:grid;grid-template-columns:repeat(4,1fr);gap:18px}
    .process li{padding-top:14px;border-top:2px solid var(--v2-ink)}
    .process small{display:block;font-size:11px;color:var(--v2-muted)}
    .process b{display:block;margin:6px 0;font-size:17px}
    .process span{font-size:14px;line-height:1.45;color:var(--v2-muted)}
    .case{display:block;padding:100px 5%;background:var(--v2-dark);color:#fff}
    .case .v2-label{color:#c9c9c4}
    .case h2{margin:0;font-weight:900;font-size:clamp(2.6rem,6vw,5.6rem);letter-spacing:-.05em;line-height:.95}
    .case .scope{margin:18px 0 0;color:var(--v2-lime);font-size:18px}
    .case .quote{max-width:760px;margin:40px 0 0;font:clamp(1.5rem,2.4vw,2.3rem)/1.15 Georgia,serif;letter-spacing:-.03em;color:#f5f5ef}
    .case .more{display:inline-flex;align-items:center;gap:14px;margin-top:44px;font-size:12px;letter-spacing:.2em;text-transform:uppercase}
    .case .more b{font:300 28px Arial;transition:transform .25s}
    .case:hover .more b{transform:translateX(8px)}
    @media(max-width:850px){
      .hero{grid-template-columns:1fr}
      .visual{min-height:280px;order:-1}
      .copy{padding:50px 7%}
      .problem,.specs{grid-template-columns:1fr;gap:20px}
      .build li{grid-template-columns:35px 1fr}
      .build em{grid-column:2}
      .process{grid-template-columns:1fr 1fr}
    }
  `],
})
export class ServicePageComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private title = inject(Title);
  private meta = inject(Meta);
  readonly steps = PROCESS_STEPS;
  s: ServiceContent | undefined;

  ngOnInit() {
    this.s = SERVICES.find(x => x.slug === this.route.snapshot.data['slug']);
    if (!this.s) return;
    this.title.setTitle(`${this.s.title} — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: this.s.metaDescription });
  }

  pad(n: number) { return n.toString().padStart(2, '0'); }
}
