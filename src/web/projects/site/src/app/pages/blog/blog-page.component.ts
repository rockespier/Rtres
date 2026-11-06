import { Component, LOCALE_ID, OnInit, PLATFORM_ID, TransferState, computed, inject, makeStateKey, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { Meta, Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { BlogPostSummary, PublicApiService } from '../../core/public-api.service';
import { blogPostPath } from '../../core/site-paths';
import { BlogRowComponent, blogMeta } from './blog-row.component';

const PAGE_SIZE = 10;
const POSTS_KEY = makeStateKey<BlogPostSummary[]>('blog-posts');

/**
 * Blog: los posts se escriben en WordPress (categorías blog-es, blog-en, blog-it). La lista se prerenderiza y el navegador
 * la vuelve a pedir, así un post nuevo aparece sin publicar el sitio.
 */
@Component({
  selector: 'app-blog-page',
  standalone: true,
  imports: [RouterLink, ClosingCtaComponent, BlogRowComponent],
  template: `
    <section class="hero">
      <div>
        <p class="v2-label" i18n="@@blog.label">BLOG</p>
        <h1 class="v2-display" i18n="@@blog.title">Ideas para<br>construir mejor.</h1>
      </div>
      <p class="lead" i18n="@@blog.lead">Lo que aprendemos desarrollando software, integrando sistemas y manteniendo sitios en producción, contado sin rodeos.</p>
    </section>

    @if (posts() === undefined) {
      <p class="state" i18n="@@blog.loading">Cargando artículos…</p>
    } @else if (posts() === null) {
      <p class="state" i18n="@@blog.error">No pudimos cargar los artículos. Vuelve a intentarlo en unos minutos.</p>
    } @else if (!posts()!.length) {
      <p class="state" i18n="@@blog.empty">Muy pronto publicaremos aquí nuestros primeros artículos.</p>
    } @else {
      @if (lead(); as p) {
        <a class="lead-post" [routerLink]="postPath(p.slug)">
          <div class="v2-photo">@if (p.coverUrl) {<img [src]="p.coverUrl" [alt]="p.coverAlt ?? ''">}</div>
          <div class="txt">
            <span class="latest" i18n="@@blog.latest">Lo último</span>
            <p class="meta">{{ meta(p) }} · {{ p.readingMinutes }} min</p>
            <h2>{{ p.title }}</h2>
            <p class="ex">{{ p.excerpt }}</p>
            <span class="read"><ng-container i18n="@@blog.read">Leer artículo</ng-container> →</span>
          </div>
        </a>
      }

      @if (tags().length > 1) {
        <div class="filters" role="group" i18n-aria-label="@@blog.filter" aria-label="Filtrar por tema">
          <button type="button" [class.on]="!tag()" [attr.aria-pressed]="!tag()" (click)="pick(null)" i18n="@@blog.all">Todos</button>
          @for (t of tags(); track t) {<button type="button" [class.on]="tag() === t" [attr.aria-pressed]="tag() === t" (click)="pick(t)">{{ t }}</button>}
        </div>
      }

      <section class="index" [class.flush]="tags().length <= 1" i18n-aria-label="@@blog.articles" aria-label="Artículos">
        @for (p of shown(); track p.slug; let i = $index) { <app-blog-row [post]="p" [index]="i" /> }
        @if (shown().length < rows().length) {
          <button type="button" class="more" (click)="visible.set(visible() + pageSize)" i18n="@@blog.more">Ver más artículos</button>
        }
      </section>
    }

    <app-closing-cta [title]="ctaTitle" />
  `,
  styles: [`
    :host{display:block}
    .hero{display:grid;grid-template-columns:minmax(0,1.5fr) minmax(0,1fr);gap:40px;align-items:end;padding:90px 5% 56px}
    h1{font-size:clamp(3rem,6.6vw,6.6rem)}
    .lead{margin:0;font-size:20px;line-height:1.45;color:var(--v2-muted)}
    .state{margin:0 5% 90px;padding:40px 0;border-top:1px solid var(--v2-line);color:var(--v2-muted);font-size:18px}
    .lead-post{display:grid;grid-template-columns:minmax(0,1.45fr) minmax(0,1fr);margin:0 5%;background:var(--v2-dark);color:#fff}
    .lead-post .v2-photo{min-height:480px}
    .lead-post:hover img{transform:scale(1.03)}
    .lead-post:focus-visible{outline:2px solid var(--v2-mark);outline-offset:2px}
    .txt{display:flex;flex-direction:column;justify-content:flex-end;padding:44px}
    .latest{align-self:flex-start;margin:0 0 auto;padding:6px 12px;background:var(--v2-lime);color:var(--v2-ink);font-size:11px;font-weight:bold;letter-spacing:.2em;text-transform:uppercase}
    .meta{margin:40px 0 0;font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:#b5b5b5}
    .lead-post h2{margin:16px 0 0;font-weight:900;font-size:clamp(2rem,3.2vw,3.2rem);letter-spacing:-.045em;line-height:1;text-wrap:balance}
    .ex{margin:20px 0 0;color:#c9c9c9;font-size:17px;line-height:1.5}
    .read{align-self:flex-start;margin-top:26px;font-weight:bold;font-size:14px;border-bottom:1px solid}
    .filters{display:flex;flex-wrap:wrap;gap:8px;padding:56px 5% 24px}
    .filters button{padding:9px 16px;border:1px solid var(--v2-rule);background:#fff;font:600 14px Arial;color:var(--v2-ink);cursor:pointer}
    .filters button.on{background:var(--v2-ink);border-color:var(--v2-ink);color:#fff}
    .filters button:focus-visible,.more:focus-visible{outline:2px solid var(--v2-mark);outline-offset:2px}
    .index{padding:0 5% 90px}
    .index.flush{padding-top:56px}
    .more{display:block;margin:34px auto 0;padding:14px 22px;border:1px solid var(--v2-ink);background:#fff;font:bold 14px Arial;color:var(--v2-ink);cursor:pointer}
    @media(max-width:1000px){
      .hero,.lead-post{grid-template-columns:1fr}
      .lead-post .v2-photo{min-height:0;height:52vw}
      .meta{margin-top:26px}
    }
    @media(max-width:700px){
      .hero{padding:56px 7% 36px;gap:22px}
      .state{margin:0 7% 60px}
      .lead-post{margin:0}
      .txt{padding:28px 7% 34px}
      .filters{padding:40px 7% 20px}
      .index{padding:0 7% 70px}
      .index.flush{padding-top:40px}
    }
  `],
})
export class BlogPageComponent implements OnInit {
  private api = inject(PublicApiService);
  private state = inject(TransferState);
  private locale = inject(LOCALE_ID).slice(0, 2);
  private browser = isPlatformBrowser(inject(PLATFORM_ID));
  private title = inject(Title);
  private metaTags = inject(Meta);
  readonly ctaTitle = $localize`:@@blog.cta:¿Tienes un proyecto en mente?`;
  readonly pageSize = PAGE_SIZE;
  readonly postPath = blogPostPath;

  /** undefined = cargando; null = error. */
  posts = signal<BlogPostSummary[] | null | undefined>(undefined);
  tag = signal<string | null>(null);
  visible = signal(PAGE_SIZE);
  tags = computed(() => [...new Set((this.posts() ?? []).flatMap(p => p.tag ? [p.tag] : []))]);
  /** El destacado es el último post; al filtrar por tema desaparece y la lista muestra solo ese tema. */
  lead = computed(() => this.tag() ? null : this.posts()?.[0] ?? null);
  rows = computed(() => {
    const posts = this.posts() ?? [];
    return this.tag() ? posts.filter(p => p.tag === this.tag()) : posts.slice(1);
  });
  shown = computed(() => this.rows().slice(0, this.visible()));

  ngOnInit() {
    this.title.setTitle($localize`:@@blog.metaTitle:Blog — Rtres Web Solutions`);
    this.metaTags.updateTag({ name: 'description', content: $localize`:@@blog.meta:Artículos de Rtres sobre software a medida, integración de sistemas, automatización y hosting para empresas.` });

    // Lo prerenderizado se muestra al instante; si la API falla en el navegador se conserva.
    const prerendered = this.state.get(POSTS_KEY, null);
    if (prerendered) this.posts.set(prerendered);
    this.api.getBlogPosts(this.locale).subscribe(posts => {
      if (posts) {
        this.posts.set(posts);
        if (!this.browser) this.state.set(POSTS_KEY, posts);
      } else if (!prerendered) this.posts.set(null);
    });
  }

  meta(post: BlogPostSummary) { return blogMeta(post, this.locale); }

  pick(tag: string | null) {
    this.tag.set(tag);
    this.visible.set(PAGE_SIZE);
  }
}
