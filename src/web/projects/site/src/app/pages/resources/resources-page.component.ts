import { Component, LOCALE_ID, OnInit, PLATFORM_ID, computed, inject, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { Meta, Title } from '@angular/platform-browser';
import { DomSanitizer, SafeResourceUrl } from '@angular/platform-browser';
import { ClosingCtaComponent } from '../../components/home/closing-cta.component';
import { PublicApiService, PublicVideo } from '../../core/public-api.service';

/**
 * Recursos: videos educativos que se administran en el portal. Se piden en el navegador (no en el prerender)
 * para que un video nuevo aparezca sin volver a publicar el sitio.
 */
@Component({
  selector: 'app-resources-page',
  standalone: true,
  imports: [ClosingCtaComponent],
  template: `
    <section class="hero">
      <p class="v2-label" i18n="@@resources.label">RECURSOS</p>
      <h1 class="v2-display" i18n="@@resources.title">Aprende con<br>nosotros.</h1>
      <p class="lead" i18n="@@resources.lead">Videos que recomendamos para crecer como profesional y como empresa: marca personal, disciplina, hábitos, negocios y tecnología.</p>
    </section>

    <section class="list">
      @if (videos() === undefined) {
        <p class="state" i18n="@@resources.loading">Cargando videos…</p>
      } @else if (videos() === null) {
        <p class="state" i18n="@@resources.error">No pudimos cargar los videos. Vuelve a intentarlo en unos minutos.</p>
      } @else if (!videos()!.length) {
        <p class="state" i18n="@@resources.empty">Muy pronto compartiremos aquí nuestros videos recomendados.</p>
      } @else {
        @if (categories().length > 1) {
          <div class="filters" role="group" i18n-aria-label="@@resources.filter" aria-label="Filtrar por tema">
            <button type="button" [class.on]="!category()" [attr.aria-pressed]="!category()" (click)="category.set(null)" i18n="@@resources.all">Todos</button>
            @for (c of categories(); track c) {<button type="button" [class.on]="category() === c" [attr.aria-pressed]="category() === c" (click)="category.set(c)">{{ c }}</button>}
          </div>
        }
        <div class="grid">
          @for (v of filtered(); track v.youtubeId; let first = $first) {
            <article [class.featured]="first">
              <div class="player">
                @if (playing() === v.youtubeId) {
                  <iframe [src]="embed(v.youtubeId)" [title]="v.title" referrerpolicy="strict-origin-when-cross-origin" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
                } @else {
                  <button type="button" class="poster" (click)="playing.set(v.youtubeId)" [attr.aria-label]="playLabel + ': ' + v.title">
                    <img [src]="'https://i.ytimg.com/vi/' + v.youtubeId + (first ? '/maxresdefault.jpg' : '/hqdefault.jpg')" alt="" loading="lazy" (error)="fallback($event, v.youtubeId)">
                    <span class="play" aria-hidden="true">▶</span>
                  </button>
                }
              </div>
              <div class="info">
                @if (first) { <p class="badge" i18n="@@resources.featured">Destacado</p> }
                <p class="cat">{{ v.category }}</p>
                <h2>{{ v.title }}</h2>
                @if (v.description) { <p class="desc">{{ v.description }}</p> }
                <!-- Algunos canales no permiten reproducir sus videos fuera de YouTube: siempre queda el enlace directo. -->
                <a class="yt" [href]="'https://www.youtube.com/watch?v=' + v.youtubeId" target="_blank" rel="noopener"><ng-container i18n="@@resources.openYoutube">Ver en YouTube</ng-container> <span aria-hidden="true">↗</span></a>
              </div>
            </article>
          }
        </div>
      }
    </section>

    <app-closing-cta [title]="ctaTitle" />
  `,
  styles: [`
    :host{display:block}
    .hero{padding:100px 5% 60px}
    h1{font-size:clamp(3rem,6.6vw,6.6rem)}
    .lead{max-width:640px;margin:30px 0 0;font-size:21px;line-height:1.45;color:var(--v2-muted)}
    .list{padding:0 5% 110px}
    .state{padding:40px 0;border-top:1px solid var(--v2-line);color:var(--v2-muted);font-size:18px}
    .filters{display:flex;flex-wrap:wrap;gap:8px;padding:24px 0;border-top:1px solid var(--v2-line)}
    .filters button{padding:9px 16px;border:1px solid var(--v2-rule);background:#fff;font:600 14px Arial;cursor:pointer}
    .filters button.on{background:var(--v2-ink);border-color:var(--v2-ink);color:#fff}
    .filters button:focus-visible{outline:2px solid var(--v2-mark);outline-offset:2px}
    .grid{display:grid;grid-template-columns:repeat(3,1fr);gap:50px 32px;margin-top:20px}
    .featured{grid-column:1/-1;display:grid;grid-template-columns:minmax(0,1.7fr) minmax(0,1fr);gap:0 48px;align-items:start;padding-bottom:50px;border-bottom:1px solid var(--v2-line)}
    .featured .info{padding-top:4px}
    .badge{display:inline-block;margin:0 0 22px;padding:6px 12px;background:var(--v2-lime);font-size:11px;font-weight:bold;letter-spacing:.2em;text-transform:uppercase}
    .featured .cat{margin-top:0;display:flex;align-items:center;gap:12px;color:var(--v2-ink)}
    .featured .cat:after{content:"";height:1px;flex:1;max-width:80px;background:var(--v2-rule)}
    .featured h2{margin-top:14px;font-weight:900;font-size:clamp(1.9rem,2.8vw,2.9rem);letter-spacing:-.04em;line-height:1.02;text-wrap:balance}
    .featured .desc{margin-top:22px;font-size:17px;line-height:1.6;color:#4a4a4a}
    .featured .yt{margin-top:28px;font-size:14px;letter-spacing:.02em}
    .player{position:relative;aspect-ratio:16/9;background:var(--v2-dark)}
    .player iframe{position:absolute;inset:0;width:100%;height:100%;border:0}
    .poster{position:absolute;inset:0;padding:0;border:0;background:none;cursor:pointer}
    .poster img{width:100%;height:100%;object-fit:cover;display:block;transition:filter .25s}
    .poster:hover img{filter:brightness(.8)}
    .play{position:absolute;left:50%;top:50%;display:grid;place-items:center;width:64px;height:64px;margin:-32px 0 0 -32px;border-radius:50%;background:var(--v2-lime);color:var(--v2-ink);font-size:20px;transition:transform .2s}
    .poster:hover .play,.poster:focus-visible .play{transform:scale(1.1)}
    .poster:focus-visible{outline:3px solid var(--v2-mark);outline-offset:3px}
    .cat{margin:16px 0 0;font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:var(--v2-muted)}
    h2{margin:8px 0 0;font-size:20px;letter-spacing:-.02em;line-height:1.2}
    .desc{margin:10px 0 0;color:var(--v2-muted);font-size:15px;line-height:1.5}
    .yt{display:inline-block;margin-top:10px;font-size:13px;font-weight:bold;border-bottom:1px solid}
    .yt:hover{background:var(--v2-lime)}
    @media(max-width:1000px){ .grid{grid-template-columns:1fr 1fr} }
    @media(max-width:700px){
      .hero{padding:60px 7% 40px}
      .grid,.featured{grid-template-columns:1fr}
      .featured .info{padding-top:20px}
    }
  `],
})
export class ResourcesPageComponent implements OnInit {
  private api = inject(PublicApiService);
  private sanitizer = inject(DomSanitizer);
  private locale = inject(LOCALE_ID).slice(0, 2);
  private browser = isPlatformBrowser(inject(PLATFORM_ID));
  private title = inject(Title);
  private meta = inject(Meta);
  readonly ctaTitle = $localize`:@@resources.cta:¿Quieres llevar tu negocio al siguiente nivel?`;
  readonly playLabel = $localize`:@@resources.play:Reproducir`;

  /** undefined = cargando; null = error. */
  videos = signal<PublicVideo[] | null | undefined>(undefined);
  category = signal<string | null>(null);
  playing = signal<string | null>(null);
  categories = computed(() => [...new Set((this.videos() ?? []).map(v => v.category))]);
  filtered = computed(() => (this.videos() ?? []).filter(v => !this.category() || v.category === this.category()));

  ngOnInit() {
    this.title.setTitle($localize`:@@resources.metaTitle:Recursos — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: $localize`:@@resources.meta:Videos recomendados por Rtres para crecer como profesional y como empresa: marca personal, disciplina, hábitos, negocios y tecnología.` });
    if (this.browser) this.api.getVideos(this.locale).subscribe(v => this.videos.set(v));
  }

  /** youtube-nocookie: no deja cookies de seguimiento hasta que el visitante reproduce. */
  embed(id: string): SafeResourceUrl {
    return this.sanitizer.bypassSecurityTrustResourceUrl(`https://www.youtube-nocookie.com/embed/${encodeURIComponent(id)}?autoplay=1&rel=0`);
  }

  /** No todos los videos tienen miniatura en alta resolución. */
  fallback(event: Event, id: string) {
    const img = event.target as HTMLImageElement;
    const low = `https://i.ytimg.com/vi/${id}/hqdefault.jpg`;
    if (img.src !== low) img.src = low;
  }
}
