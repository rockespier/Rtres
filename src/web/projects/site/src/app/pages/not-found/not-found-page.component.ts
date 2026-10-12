import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
import { RouterLink } from '@angular/router';
import { SERVICE_LINKS } from '../../core/site-nav';

/**
 * Página 404. Se prerenderiza en /{idioma}/404 y el .htaccess la sirve con estado 404 para cualquier URL que no exista;
 * en el navegador también cubre las rutas desconocidas. Lleva noindex y sin canonical (ver SeoService).
 */
@Component({
  selector: 'app-not-found-page',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section class="nf">
      <p class="v2-label" i18n="@@notFound.label">ERROR 404</p>
      <h1 class="v2-display" i18n="@@notFound.title">Esta página no existe.</h1>
      <p class="lead" i18n="@@notFound.lead">Puede que el enlace esté mal escrito o que la página se haya movido. Estas te pueden servir:</p>
      <ul>
        <li><a routerLink="/" i18n="@@notFound.home">Inicio</a></li>
        @for (s of services; track s.path) {<li><a [routerLink]="s.path">{{ s.label }}</a></li>}
        <li><a routerLink="/" fragment="contacto" i18n="@@notFound.contact">Contacto</a></li>
      </ul>
    </section>
  `,
  styles: [`
    :host{display:block}
    .nf{padding:100px 5% 120px}
    h1{font-size:clamp(2.8rem,6vw,5.5rem)}
    .lead{max-width:640px;margin:28px 0 0;font-size:20px;line-height:1.45;color:var(--v2-muted)}
    ul{list-style:none;margin:36px 0 0;padding:0;max-width:640px}
    li{border-top:1px solid var(--v2-rule)}
    li:last-child{border-bottom:1px solid var(--v2-rule)}
    a{display:block;padding:16px 0;font-size:20px}
    a:hover{background:var(--v2-lime);padding-inline:12px}
    @media(max-width:850px){.nf{padding:60px 7% 80px}}
  `],
})
export class NotFoundPageComponent implements OnInit, OnDestroy {
  private title = inject(Title);
  private meta = inject(Meta);
  readonly services = SERVICE_LINKS;

  ngOnInit() {
    this.title.setTitle($localize`:@@notFound.metaTitle:Página no encontrada — Rtres Web Solutions`);
    this.meta.updateTag({ name: 'description', content: $localize`:@@notFound.meta:La página que buscas no existe en rtres.net.` });
    this.meta.updateTag({ name: 'robots', content: 'noindex' });
  }

  ngOnDestroy() { this.meta.removeTag('name="robots"'); }
}
