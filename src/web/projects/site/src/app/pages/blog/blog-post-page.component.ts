import { Component, DestroyRef, LOCALE_ID, OnInit, PLATFORM_ID, TransferState, computed, inject, makeStateKey, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { isPlatformBrowser } from '@angular/common';
import { Meta, Title } from '@angular/platform-browser';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { EMPTY, map, of, switchMap, tap } from 'rxjs';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { BlogPost, PublicApiService } from '../../core/public-api.service';
import { SeoService } from '../../core/seo.service';
import { BLOG_SHELL_SLUG, PATHS } from '../../core/site-paths';
import { NotFoundPageComponent } from '../not-found/not-found-page.component';
import { BlogRowComponent, blogMeta } from './blog-row.component';

const postKey = (slug: string) => makeStateKey<BlogPost>(`blog-post:${slug}`);

/**
 * Artículo del blog. Con el deploy, cada post se prerenderiza con su HTML y sus metadatos. Un post publicado después aún
 * no tiene página: site.htaccess sirve /blog/_post (esta misma página, sin datos) y aquí se carga desde la API.
 * El HTML de WordPress entra por [innerHTML], que lo sanea: quita scripts, eventos e iframes.
 */
@Component({
  selector: 'app-blog-post-page',
  standalone: true,
  imports: [RouterLink, ClosingCtaComponent, BlogRowComponent, NotFoundPageComponent],
  template: `
    @if (post() === null) {
      <app-not-found-page />
    } @else {
      @if (post(); as p) {
        <article>
          <div class="head">
            <p class="crumb"><a [routerLink]="paths.blog">← Blog</a></p>
            <h1 class="v2-display">{{ p.title }}</h1>
            <p class="meta">{{ meta() }} · {{ p.readingMinutes }} min <ng-container i18n="@@blog.readingSuffix">de lectura</ng-container></p>
          </div>
          @if (p.coverUrl) { <div class="v2-photo cover"><img [src]="p.coverUrl" [alt]="p.coverAlt ?? ''"></div> }
          <div class="content" [innerHTML]="p.html"></div>
        </article>

        @if (p.related.length) {
          <section class="next" i18n-aria-label="@@blog.next" aria-label="Sigue leyendo">
            <p class="v2-label" i18n="@@blog.nextLabel">SIGUE LEYENDO</p>
            @for (r of p.related; track r.slug; let i = $index) { <app-blog-row [post]="r" [index]="i" [excerpt]="false" /> }
          </section>
        }
      } @else if (failed()) {
        <p class="state" i18n="@@blog.postError">No pudimos cargar este artículo. Vuelve a intentarlo en unos minutos.</p>
      } @else {
        <p class="state" i18n="@@blog.postLoading">Cargando artículo…</p>
      }
      <app-closing-cta [title]="ctaTitle" />
    }
  `,
  styles: [`
    :host{display:block}
    .state{min-height:40vh;margin:0;padding:90px 5%;color:var(--v2-muted);font-size:18px}
    .head{padding:70px 5% 44px}
    .crumb{margin:0 0 34px;font-size:13px;color:var(--v2-muted)}
    .crumb a{border-bottom:1px solid}
    h1{max-width:1120px;font-size:clamp(2.6rem,5.6vw,5.6rem);overflow-wrap:break-word}
    .meta{margin:30px 0 0;font-size:11px;letter-spacing:.2em;text-transform:uppercase}
    .cover{height:min(56vw,560px);margin:0 5%}
    .next{padding:0 5% 90px}
    .next .v2-label{padding-bottom:6px}

    /* Contenido de WordPress: las portadas llevan el tono lima; las imágenes del artículo, su color natural. */
    .content{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,700px) minmax(0,1fr);padding:64px 5% 80px}
    .content ::ng-deep>*{grid-column:2;min-width:0}
    .content ::ng-deep>:first-child{font-size:24px;line-height:1.4;letter-spacing:-.01em;margin:0 0 22px}
    .content ::ng-deep p,.content ::ng-deep li{font-size:18px;line-height:1.7;color:#2c2c2c}
    .content ::ng-deep p{margin:0 0 22px}
    .content ::ng-deep h2,.content ::ng-deep h3,.content ::ng-deep h4{margin:44px 0 16px;font-weight:900;letter-spacing:-.04em;line-height:1.08}
    .content ::ng-deep h2{font-size:clamp(1.7rem,2.6vw,2.3rem)}
    .content ::ng-deep h3{font-size:clamp(1.35rem,2vw,1.7rem)}
    .content ::ng-deep h4{font-size:1.15rem;letter-spacing:-.02em}
    .content ::ng-deep ul,.content ::ng-deep ol{margin:0 0 24px;padding-left:22px}
    .content ::ng-deep ul{list-style:disc}
    .content ::ng-deep ol{list-style:decimal}
    .content ::ng-deep li{margin-bottom:8px}
    .content ::ng-deep li::marker{color:var(--v2-mark)}
    .content ::ng-deep a{border-bottom:2px solid var(--v2-lime)}
    .content ::ng-deep a:hover{background:var(--v2-lime)}
    .content ::ng-deep blockquote{margin:30px 0;padding:4px 0 4px 26px;border-left:6px solid var(--v2-lime)}
    .content ::ng-deep blockquote p{margin:0;font-weight:900;font-size:clamp(1.4rem,2.2vw,1.9rem);letter-spacing:-.03em;line-height:1.15;color:var(--v2-ink)}
    .content ::ng-deep pre{overflow-x:auto;margin:0 0 24px;padding:20px;background:var(--v2-dark);color:#e8e8e8;font-size:14px;line-height:1.6}
    .content ::ng-deep code{font-size:.9em}
    .content ::ng-deep figure{margin:26px 0 34px}
    .content ::ng-deep .wp-block-table{overflow-x:auto}
    .content ::ng-deep img{display:block;max-width:100%;height:auto;margin-inline:auto}
    .content ::ng-deep figcaption{margin:12px 0 0;color:var(--v2-muted);font-size:14px}
    .content ::ng-deep table{width:100%;margin:0 0 24px;border-collapse:collapse;font-size:16px}
    .content ::ng-deep th,.content ::ng-deep td{padding:10px 12px;border-bottom:1px solid var(--v2-line);text-align:left}

    @media(max-width:700px){
      .state{padding:60px 7%}
      .head{padding:46px 7% 30px}
      .cover{height:62vw;margin:0}
      .content{display:block;padding:40px 7% 56px}
      .content ::ng-deep>:first-child{font-size:21px}
      .content ::ng-deep p,.content ::ng-deep li{font-size:17px}
      .next{padding:0 7% 70px}
    }
  `],
})
export class BlogPostPageComponent implements OnInit {
  private api = inject(PublicApiService);
  private route = inject(ActivatedRoute);
  private seo = inject(SeoService);
  private state = inject(TransferState);
  private locale = inject(LOCALE_ID).slice(0, 2);
  private browser = isPlatformBrowser(inject(PLATFORM_ID));
  private title = inject(Title);
  private metaTags = inject(Meta);
  private destroyRef = inject(DestroyRef);
  readonly paths = PATHS;
  readonly ctaTitle = $localize`:@@blog.cta:¿Tienes un proyecto en mente?`;

  /** undefined = cargando; null = no existe. */
  post = signal<BlogPost | null | undefined>(undefined);
  failed = signal(false);
  meta = computed(() => { const p = this.post(); return p ? blogMeta(p, this.locale) : ''; });

  ngOnInit() {
    this.destroyRef.onDestroy(() => this.seo.setArticle(null));
    // El componente se reutiliza al pasar de un post a otro ("Sigue leyendo"): se escucha el slug, no solo el primero.
    this.route.paramMap.pipe(
      map(params => params.get('slug') ?? this.route.snapshot.url.at(-1)?.path ?? ''),
      tap(slug => this.start(slug)),
      switchMap(slug => {
        // La página base del modo híbrido se prerenderiza sin datos. No lleva noindex: Google no ejecutaría el JS.
        if (slug === BLOG_SHELL_SLUG && !this.browser) return EMPTY;
        return this.api.getBlogPost(this.locale, slug).pipe(switchMap(result => of({ slug, result })));
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(({ slug, result }) => this.finish(slug, result));
  }

  private start(slug: string) {
    this.failed.set(false);
    this.seo.setArticle(null);
    this.title.setTitle($localize`:@@blog.metaTitle:Blog — Rtres Web Solutions`);
    const prerendered = this.state.get(postKey(slug), null);
    if (prerendered) this.show(prerendered);
    else this.post.set(undefined);
  }

  private finish(slug: string, result: BlogPost | null | 'error') {
    if (result === 'error') {
      if (this.post()) return; // Se conserva lo prerenderizado.
      this.failed.set(true);
      // En el prerender deja la página marcada: seo-files.mjs la borra y site.htaccess sirve la página base.
      if (!this.browser) this.metaTags.updateTag({ name: 'robots', content: 'noindex' });
    } else if (result === null) {
      this.seo.setArticle(null);
      this.post.set(null);
      // <app-not-found-page> fija título y noindex al crearse: después se quitan el canonical y los hreflang.
      setTimeout(() => this.seo.update());
    } else {
      if (!this.browser) this.state.set(postKey(slug), result);
      this.show(result);
    }
  }

  private show(post: BlogPost) {
    this.post.set(post);
    this.title.setTitle(`${post.title} — Rtres Web Solutions`);
    const description = post.excerpt.length > 160 ? `${post.excerpt.slice(0, 157).trimEnd()}…` : post.excerpt;
    this.metaTags.updateTag({ name: 'description', content: description });
    this.seo.setArticle({ headline: post.title, image: post.coverUrl, datePublished: post.publishedAt, dateModified: post.updatedAt });
    this.seo.update();
  }
}
