import { Component, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { PATHS } from '../../core/site-paths';
import { COMPANY } from '../../core/company';
import { LEGAL, LEGAL_UPDATED, LegalDoc, LegalId } from './legal-content';

/** Política de privacidad y aviso legal: la ruta indica cuál con data.doc. */
@Component({
  selector: 'app-legal-page',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="hero">
      <p class="v2-label">{{ doc.label }}</p>
      <h1 class="v2-display">{{ doc.title }}</h1>
      <p class="lead">{{ doc.intro }}</p>
    </section>

    <article>
      @for (s of doc.sections; track s.title) {
        <section>
          <h2>{{ s.title }}</h2>
          @for (p of s.paragraphs; track p) {<p>{{ p }}</p>}
        </section>
      }
      <p class="company">{{ company.name }} · RUC {{ company.ruc }} · {{ company.address }}</p>
      <p class="updated">{{ updated }}</p>
      @if (id === 'legal') {
        <a [routerLink]="paths.privacy" i18n="@@legal.seePrivacy">Ver la política de privacidad</a>
      } @else {
        <a [routerLink]="paths.legal" i18n="@@legal.seeNotice">Ver el aviso legal</a>
      }
    </article>
  `,
  styles: [`
    :host{display:block}
    .hero{padding:100px 5% 50px}
    h1{font-size:clamp(2.6rem,5.4vw,5.2rem);text-wrap:balance}
    .lead{max-width:760px;margin:28px 0 0;font-size:20px;line-height:1.5;color:var(--v2-muted)}
    article{max-width:760px;padding:0 5% 100px;font-size:17px;line-height:1.65}
    section{padding:28px 0;border-top:1px solid var(--v2-line)}
    h2{margin:0 0 12px;font-size:22px;letter-spacing:-.02em}
    p{margin:0 0 12px}
    .company{margin-top:28px;padding-top:28px;border-top:2px solid var(--v2-ink);font-weight:700}
    .updated{color:var(--v2-muted);font-size:15px}
    a{text-decoration:underline;text-underline-offset:3px}
  `],
})
export class LegalPageComponent implements OnInit {
  private readonly title = inject(Title);
  private readonly meta = inject(Meta);
  readonly id: LegalId = inject(ActivatedRoute).snapshot.data['doc'];
  readonly doc: LegalDoc = LEGAL[this.id];
  readonly company = COMPANY;
  readonly updated = LEGAL_UPDATED;
  readonly paths = PATHS;

  ngOnInit() {
    this.title.setTitle(this.doc.metaTitle);
    this.meta.updateTag({ name: 'description', content: this.doc.meta });
  }
}
