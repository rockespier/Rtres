import { Component, OnInit, inject, signal } from '@angular/core';
import { MarqueeComponent } from '../marquee/marquee.component';
import { PublicApiService } from '../../core/public-api.service';

@Component({selector:'app-hero',standalone:true,imports:[MarqueeComponent],template:`<section id="inicio" class="relative pt-16 pb-24 overflow-hidden"><div class="wrap relative z-10"><span class="badge"><span class="dot"></span><span i18n="@@hero.eyebrow">18+ años de experiencia · 300+ proyectos entregados</span></span></div><div class="wrap relative"><p class="huge huge-fill -mb-4 sm:-mb-8 mt-2" i18n="@@hero.giant">CRECE</p></div><div class="wrap relative z-10"><div class="grid lg:grid-cols-12 gap-10 lg:gap-8 items-end"><div class="lg:col-span-7"><h1 class="font-display text-5xl md:text-7xl font-bold mt-6"><span i18n="@@hero.title.line1">Soluciones web que</span><br/><em i18n="@@hero.title.line2">convierten visitas en clientes</em></h1><p class="lead mt-6" i18n="@@hero.sub">Diseñamos y desarrollamos sitios, tiendas y sistemas a medida — con soporte y gestión de clientes en un solo lugar.</p><div class="flex gap-3 mt-7"><a href="#contact" class="btn btn-primary" i18n="@@hero.cta.primary">Solicitar cotización</a><a href="#pricing" class="btn btn-ghost" i18n="@@hero.cta.secondary">Ver planes</a></div></div><div class="lg:col-span-5 relative"><div class="sunburst w-[420px] h-[420px] -top-16 -right-10 hidden sm:block"></div><div class="photo-duotone rounded-[28px] aspect-[4/5] relative"><img [src]="photoUrl()" alt="Equipo de Rtres trabajando en un proyecto web"></div><div class="float-card -bottom-8 -left-6 sm:-left-10 p-5 w-[210px]"><b class="font-display text-3xl font-semibold block" i18n="@@hero.float.number">300+</b><span class="text-xs text-[color:var(--text-muted)] mt-1 block" i18n="@@hero.float.label">Proyectos entregados</span><div class="flex items-center gap-1.5 mt-3 pt-3 border-t border-black/10"><span class="text-[color:var(--green)] text-sm">★★★★★</span><small class="text-xs text-[color:var(--text-muted)]" i18n="@@hero.float.rating">5.0 · 18 años</small></div></div></div></div><p class="mt-16 text-sm text-[color:var(--text-muted)]" i18n="@@hero.trust">Marcas que confían en nosotros</p><app-marquee [items]="clients"/></div></section>`})
export class HeroComponent implements OnInit {
  private api = inject(PublicApiService);
  clients = ['Assist Card', 'Cabalgatas Andinas', 'Ransa', 'Claro', 'Rimac'];
  photoUrl = signal('https://picsum.photos/id/48/900/1100');

  ngOnInit(): void {
    this.api.getHeroPhoto().subscribe({ next: r => this.photoUrl.set(r.url), error: () => {} });
  }
}
