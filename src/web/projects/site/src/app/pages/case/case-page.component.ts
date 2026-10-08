import { Component, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { CASES, CaseContent } from './case-content';

/** Plantilla de los casos de éxito; el contenido sale de CASES según el slug de la ruta. */
@Component({
  selector: 'app-case-page',
  standalone: true,
  imports: [RouterLink, ClosingCtaComponent],
  template: `
    @if (c; as c) {
      <section class="hero">
        <p class="v2-label kicker"><span i18n="@@home.cases.label">CASOS DE ÉXITO</span> · {{ c.sector }}</p>
        <h1 class="v2-display">{{ c.name }}</h1>
        <p class="intro">{{ c.intro }}</p>
        <dl class="stats">
          @for (s of c.stats; track s.value) {<div><dt>{{ s.value }}</dt><dd>{{ s.label }}</dd></div>}
        </dl>
      </section>
      <section class="challenge">
        <div>
          <p class="v2-label" i18n="@@case.challenge.label">EL DESAFÍO</p>
          <p class="statement">{{ c.challenge }}</p>
        </div>
        <div class="shot" [style.max-width.px]="c.shot.width" role="img" [attr.aria-label]="c.name" style="background-image:url('assets/casos_exito.png')" [style.aspect-ratio]="c.shot.ratio" [style.background-size]="c.shot.size" [style.background-position]="c.shot.position"></div>
      </section>

      <section class="solution">
        <p class="v2-label" i18n="@@case.solution.label">NUESTRA SOLUCIÓN</p>
        @for (g of c.solution; track $index) {
          @if (g.title) { <h2>{{ g.title }}</h2> }
          <ol>
            @for (r of g.rows; track r.title; let i = $index) {<li><small>{{ pad(i + 1) }}</small><b>{{ r.title }}</b><em>{{ r.text }}</em></li>}
          </ol>
        }
        <p class="integrations"><span class="v2-label" i18n="@@case.integrations.label">CONECTA</span>@for (x of c.integrations; track x; let last = $last) {<b>{{ x }}</b>@if (!last) {<i aria-hidden="true">·</i>}}</p>
      </section>

      <section class="impact">
        <p class="v2-label" i18n="@@case.impact.label">IMPACTO</p>
        <p>{{ c.impact }}</p>
      </section>

      @if (c.testimonial; as t) {
        <figure class="quote">
          <blockquote>“{{ t.quote }}”</blockquote>
          <figcaption><b>{{ t.author }}</b><small>{{ t.role }}</small></figcaption>
        </figure>
      }

      <section class="more">
        <div>
          <p class="v2-label" i18n="@@case.services.label">SERVICIOS DE ESTE PROYECTO</p>
          @for (s of c.services; track s.path) {<a [routerLink]="s.path">{{ s.label }} <b aria-hidden="true">↗</b></a>}
        </div>
        <a class="next" [routerLink]="c.next.path">
          <span class="v2-label" i18n="@@case.next.label">SIGUIENTE CASO</span>
          <strong>{{ c.next.name }} <b aria-hidden="true">→</b></strong>
        </a>
      </section>

      <app-closing-cta [title]="ctaTitle" />
    }
  `,
  styles: [`
    :host{display:block}
    .hero{padding:90px 5% 60px}
    .kicker{color:var(--v2-muted);text-transform:uppercase}
    h1{font-size:clamp(3rem,7.5vw,7.4rem);text-wrap:balance}
    .intro{max-width:720px;margin:28px 0 0;font-size:22px;line-height:1.4;color:var(--v2-muted)}
    .stats{display:grid;grid-template-columns:repeat(3,1fr);margin:60px 0 0}
    .stats div{padding:18px 30px 0 0;border-top:2px solid var(--v2-ink)}
    .stats div+div{padding-left:30px;border-left:1px solid var(--v2-line)}
    .stats dt{font-weight:900;font-size:clamp(2.4rem,4.4vw,4.2rem);letter-spacing:-.05em;line-height:1}
    .stats dd{margin:10px 0 0;color:var(--v2-muted);font-size:15px}
    .shot{width:100%;justify-self:end;background-color:#202826;background-repeat:no-repeat;border:1px solid var(--v2-line);box-shadow:0 30px 60px -40px rgba(0,0,0,.45)}
    .challenge{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.25fr);gap:60px;align-items:center;padding:40px 5% 100px}
    .statement{margin:0;font:clamp(1.7rem,2.4vw,2.5rem)/1.15 Georgia,serif;letter-spacing:-.03em;text-wrap:balance}
    .solution{padding:20px 5% 100px}
    .solution h2{margin:40px 0 0;font-size:clamp(1.6rem,2.6vw,2.4rem);letter-spacing:-.03em}
    .solution ol{list-style:none;margin:20px 0 0;padding:0}
    .solution li{display:grid;grid-template-columns:60px 1fr 1fr;gap:20px;align-items:baseline;padding:26px 0;border-top:1px solid var(--v2-rule)}
    .solution li:last-child{border-bottom:1px solid var(--v2-rule)}
    .solution small{font-size:12px;color:var(--v2-muted)}
    .solution b{font-size:clamp(1.3rem,2vw,1.75rem);letter-spacing:-.03em}
    .solution em{font-style:normal;font-size:16px;line-height:1.5;color:var(--v2-muted)}
    .integrations{display:flex;flex-wrap:wrap;align-items:baseline;gap:10px 14px;margin:50px 0 0;font-size:20px}
    .integrations .v2-label{margin:0 10px 0 0}
    .integrations i{color:var(--v2-mark);font-style:normal}
    .impact{display:grid;grid-template-columns:1fr 3fr;gap:30px;padding:90px 5%;background:var(--v2-lime)}
    .impact p:last-child{margin:0;font-weight:900;font-size:clamp(2rem,3.6vw,3.6rem);letter-spacing:-.045em;line-height:1.02;text-wrap:balance}
    .quote{margin:0;padding:100px 5%;background:var(--v2-dark);color:#fff}
    .quote blockquote{max-width:1050px;margin:0;font:clamp(1.8rem,3.2vw,3.2rem)/1.1 Georgia,serif;letter-spacing:-.035em;color:#f5f5ef;text-wrap:balance}
    .quote figcaption{margin-top:36px}
    .quote b{display:block;font:400 22px Georgia,serif}
    .quote small{display:block;margin-top:6px;color:#c9c9c4;font-size:11px;letter-spacing:.2em;text-transform:uppercase}
    .more{display:grid;grid-template-columns:1fr 1fr;gap:60px;padding:90px 5%}
    .more>div a{display:flex;justify-content:space-between;padding:18px 0;border-top:1px solid var(--v2-line);font-size:22px;font-weight:bold;letter-spacing:-.02em}
    .more>div a:hover{background:var(--v2-lime);padding-inline:12px}
    .next{display:flex;flex-direction:column;justify-content:flex-end;padding:30px;background:var(--v2-paper)}
    .next strong{font-weight:900;font-size:clamp(2rem,3.4vw,3.2rem);letter-spacing:-.05em;line-height:1}
    .next strong b{display:inline-block;transition:transform .25s}
    .next:hover strong b{transform:translateX(8px)}
    @media(max-width:850px){
      .hero{padding:60px 7% 40px}
      .stats{grid-template-columns:1fr}
      .stats div,.stats div+div{padding:16px 0;border-left:0}
      .challenge,.impact,.more{grid-template-columns:1fr;gap:20px}
      .solution li{grid-template-columns:35px 1fr}
      .solution em{grid-column:2}
    }
  `],
})
export class CasePageComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private title = inject(Title);
  private meta = inject(Meta);
  c: CaseContent | undefined;
  readonly ctaTitle = $localize`:@@case.cta:¿Tu empresa enfrenta un desafío parecido?`;

  ngOnInit() {
    this.c = CASES.find(x => x.slug === this.route.snapshot.data['slug']);
    if (!this.c) return;
    this.title.setTitle(`${this.c.name} — ${$localize`:@@case.titleSuffix:Caso de éxito`} — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: this.c.metaDescription });
  }

  pad(n: number) { return n.toString().padStart(2, '0'); }
}
