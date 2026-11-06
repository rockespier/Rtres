import { Component, LOCALE_ID, computed, inject, input } from '@angular/core';
import { RouterLink } from '@angular/router';
import { BlogPostSummary } from '../../core/public-api.service';
import { blogPostPath } from '../../core/site-paths';

/** "Software · 4 nov 2026": fecha en UTC para que el prerender y el navegador muestren el mismo día. */
export function blogMeta(post: Pick<BlogPostSummary, 'tag' | 'publishedAt'>, locale: string) {
  const date = new Intl.DateTimeFormat(locale, { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'UTC' }).format(new Date(post.publishedAt));
  return post.tag ? `${post.tag} · ${date}` : date;
}

/** Fila numerada del índice del blog; también es la de "Sigue leyendo" (sin extracto). */
@Component({
  selector: 'app-blog-row',
  standalone: true,
  imports: [RouterLink],
  template: `
    <a class="row" [class.no-photo]="!post().coverUrl" [routerLink]="path()">
      <span class="n">{{ number() }}</span>
      <div>
        <p class="meta">{{ meta() }} · {{ post().readingMinutes }} min</p>
        <h2>{{ post().title }}</h2>
        @if (excerpt()) { <p class="ex">{{ post().excerpt }}</p> }
      </div>
      @if (post().coverUrl; as cover) { <div class="v2-photo thumb"><img [src]="cover" alt="" loading="lazy"></div> }
    </a>
  `,
  styles: [`
    :host{display:block;border-top:1px solid var(--v2-line)}
    :host(:last-of-type){border-bottom:1px solid var(--v2-line)}
    .row{display:grid;grid-template-columns:70px minmax(0,1fr) 220px;gap:32px;align-items:center;padding:30px 0}
    .row.no-photo{grid-template-columns:70px minmax(0,1fr)}
    .row:focus-visible{outline:2px solid var(--v2-mark);outline-offset:2px}
    .n{align-self:start;font-weight:900;font-size:34px;letter-spacing:-.05em;color:var(--v2-rule);transition:color .2s}
    .meta{margin:0;font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:var(--v2-muted)}
    h2{margin:10px 0 0;font-weight:900;font-size:clamp(1.5rem,2.3vw,2.25rem);letter-spacing:-.04em;line-height:1.05;text-wrap:balance}
    .ex{margin:12px 0 0;max-width:640px;color:var(--v2-muted);font-size:16px;line-height:1.5}
    .thumb{height:132px}
    .row:hover .n{color:var(--v2-ink)}
    .row:hover h2{text-decoration:underline;text-decoration-color:var(--v2-lime);text-decoration-thickness:3px;text-underline-offset:5px}
    .row:hover .thumb img{transform:scale(1.05)}
    @media(max-width:700px){
      .row,.row.no-photo{grid-template-columns:44px minmax(0,1fr);gap:0 12px;padding:24px 0}
      .n{font-size:24px}
      .thumb{display:none}
    }
  `],
})
export class BlogRowComponent {
  private locale = inject(LOCALE_ID).slice(0, 2);
  post = input.required<BlogPostSummary>();
  index = input.required<number>();
  excerpt = input(true);
  number = computed(() => String(this.index() + 1).padStart(2, '0'));
  path = computed(() => blogPostPath(this.post().slug));
  meta = computed(() => blogMeta(this.post(), this.locale));
}
