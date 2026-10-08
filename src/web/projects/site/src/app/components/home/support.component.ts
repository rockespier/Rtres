import { Component, DestroyRef, PLATFORM_ID, afterNextRender, computed, inject, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';
import { RouterLink } from '@angular/router';

interface Testimonial { quote: string; author: string; role: string; initials: string; tone: string; }

const AUTOPLAY_MS = 7000;

@Component({
  selector: 'app-home-support',
  standalone: true,
  imports: [RouterLink],
  template: `
    <section id="portal">
      <div class="support-copy">
        <p class="support-label" i18n="@@home.support.label">CLIENTES Y SOPORTE</p>
        <h2 i18n="@@home.support.title">No desaparecemos<br><i>al entregar.</i></h2>

        <div class="carousel" role="region" aria-roledescription="carrusel" i18n-aria-label="@@home.support.carousel" aria-label="Opiniones de clientes"
          (mouseenter)="paused.set(true)" (mouseleave)="paused.set(false)" (focusin)="paused.set(true)" (focusout)="paused.set(false)">
          <div class="viewport">
            <div class="track" [attr.aria-live]="paused() ? 'polite' : 'off'" [style.--i]="index()">
              @for (t of testimonials; track t.author; let i = $index) {
                <blockquote class="testimonial" role="group" aria-roledescription="opinión" [attr.aria-label]="(i + 1) + ' / ' + testimonials.length" [attr.aria-hidden]="!isVisible(i)">
                  <p>“{{ t.quote }}”</p>
                  <div class="testimonial-meta">
                    <span class="avatar" [style.background]="t.tone" aria-hidden="true">{{ t.initials }}</span>
                    <span><b>{{ t.author }}</b><small>{{ t.role }}</small></span>
                  </div>
                </blockquote>
              }
            </div>
          </div>
          <div class="controls">
            <button type="button" class="arrow" (click)="go(index() - 1)" [disabled]="index() === 0" i18n-aria-label="@@home.support.prev" aria-label="Opinión anterior">←</button>
            <div class="dots">
              @for (p of positions(); track p) {
                <button type="button" [class.on]="p === index()" [attr.aria-current]="p === index() ? 'true' : null" [attr.aria-label]="(p + 1) + ' / ' + positions().length" (click)="go(p)"></button>
              }
            </div>
            <button type="button" class="arrow" (click)="go(index() + 1)" [disabled]="index() === maxIndex()" i18n-aria-label="@@home.support.next" aria-label="Opinión siguiente">→</button>
          </div>
        </div>

        <a class="continues" routerLink="/" fragment="contacto"><span i18n="@@home.support.continues">PROYECTOS QUE CONTINÚAN</span><i></i><b aria-hidden="true">→</b></a>
      </div>
      <aside class="portal-visual" style="background-image:url('assets/portal-assistance.webp')">
        <div class="portal-copy">
          <div class="portal-kicker">
            <p i18n="@@home.portal.label">PORTAL DE ASISTENCIA</p>
            <a class="portal-status" href="https://portal.rtres.net" target="_blank" rel="noopener" i18n="@@home.portal.status">Próximamente</a>
          </div>
          <h2 i18n="@@home.portal.title">Compra, renueva y gestiona <br>tus tickets desde un solo lugar.</h2>
        </div>
      </aside>
    </section>
  `,
  styles: [`
    :host{display:block}
    section{display:grid;grid-template-columns:1.12fr .88fr;min-height:760px;background:var(--v2-dark);color:#fff}
    .support-copy{display:flex;flex-direction:column;min-width:0;padding:68px 7% 54px 6%}
    .support-label{display:flex;align-items:center;gap:24px;margin:0;color:#f7f7f2;font:11px Arial;letter-spacing:.24em}
    .support-label:after{content:"";height:1px;flex:1;background:#666}
    .support-copy>h2{max-width:760px;margin:34px 0 0;font:clamp(3.4rem,5.1vw,5.5rem)/.93 Georgia,serif;letter-spacing:-.04em;text-wrap:balance}
    .support-copy>h2 i{color:var(--v2-lime)}
    .carousel{--per:2;margin-top:64px;max-width:900px}
    .viewport{overflow:hidden}
    .track{display:flex;transition:transform .6s cubic-bezier(.22,1,.36,1);transform:translateX(calc(var(--i) * -100% / var(--per)))}
    .testimonial{flex:0 0 calc(100% / var(--per));box-sizing:border-box;margin:0;padding:0 36px 0 0}
    .testimonial+.testimonial{padding:0 36px;border-left:1px solid #3c3c3c}
    .testimonial p{margin:0;color:#f5f5ef;font:clamp(1.15rem,1.45vw,1.55rem)/1.25 Georgia,serif;letter-spacing:-.02em;text-wrap:pretty}
    .testimonial-meta{display:flex;align-items:center;gap:17px;margin-top:31px}
    .avatar{display:grid;place-items:center;flex:none;width:58px;height:58px;border-radius:50%;color:#171717;font:700 11px Arial;letter-spacing:.04em}
    .testimonial-meta b{display:block;color:#fff;font:400 20px Georgia,serif}
    .testimonial-meta small{display:block;margin-top:5px;color:#c9c9c4;font:10px Arial;text-transform:uppercase;letter-spacing:.2em}
    .controls{display:flex;align-items:center;gap:18px;margin-top:40px}
    .arrow{width:46px;height:46px;border:1px solid #555;border-radius:50%;background:none;color:#fff;font-size:18px;cursor:pointer;transition:background .2s,border-color .2s}
    .arrow:hover:not(:disabled){background:var(--v2-lime);border-color:var(--v2-lime);color:#111}
    .arrow:disabled{opacity:.3;cursor:default}
    .dots{display:flex;gap:8px}
    .dots button{width:26px;height:4px;padding:0;border:0;background:#555;cursor:pointer;transition:background .2s,width .2s}
    .dots button.on{width:40px;background:var(--v2-lime)}
    .arrow:focus-visible,.dots button:focus-visible{outline:2px solid var(--v2-lime);outline-offset:3px}
    .continues{display:flex;align-items:center;gap:18px;margin-top:auto;padding-top:55px;color:#fff;font:11px Arial;letter-spacing:.24em}
    .continues i{height:1px;flex:1;max-width:530px;background:#777}
    .continues b{font:300 30px Arial;transition:transform .25s ease}
    .continues:hover b{transform:translateX(8px)}
    .portal-visual{position:relative;overflow:hidden;padding:70px clamp(46px,7vw,118px) 55px;background:#d8e84d 52% center/auto 100%;color:#121212}
    .portal-copy{position:relative;z-index:1;max-width:620px}
    .portal-kicker{display:flex;align-items:center;justify-content:space-between;gap:28px}
    .portal-kicker p{margin:0;color:#121212;font:11px Arial;letter-spacing:.24em}
    .portal-status{display:inline-block;border-radius:999px;background:var(--v2-dark);color:#fff;padding:10px 18px;font:16px Arial;white-space:nowrap}
    .portal-status:hover,.portal-status:focus-visible{background:#303030}
    .portal-copy h2{max-width:620px;margin:15px 0 0;color:var(--v2-dark);font:clamp(2rem,2.45vw,3rem)/1.06 Georgia,serif;letter-spacing:-.035em;text-wrap:balance}
    @media(max-width:850px){
      section{grid-template-columns:1fr}
      .carousel{--per:1}
      .testimonial,.testimonial+.testimonial{padding:0;border-left:0}
    }
    @media(prefers-reduced-motion:reduce){ .track{transition:none} }
  `],
})
export class HomeSupportComponent {
  /** Fuente: Documentacion/Opiniones.docx. Mujica y Falcon tenían el mismo texto: queda una sola. */
  readonly testimonials: Testimonial[] = [
    { quote: $localize`:@@testimonial.weston:Rtres cumple en exceso con nuestras expectativas. Hemos desarrollado un sistema de venta online que nos permite trabajar con una ventaja tecnológica, lo cual se traduce en un mejor producto para nuestros clientes.`, author: 'Erick Weston', role: $localize`:@@home.support.t1.role:Gerente comercial`, initials: 'EW', tone: '#deded8' },
    { quote: $localize`:@@testimonial.tavolara:Lo que más aprecio del servicio de Rtres es que están siempre presentes para ir mejorando mi sitio web. Tener un sitio web me ha servido para ampliar la cantidad de personas que se interesan en mi arte.`, author: 'Hosefa Tavolara', role: $localize`:@@home.support.t2.role:Artista plástica`, initials: 'HT', tone: '#babcb5' },
    { quote: $localize`:@@testimonial.mendoza:Gracias a Rtres, hoy nuestro portal web es uno de los más visitados por surfers locales y extranjeros. Probé muchos servicios similares, pero ninguno con la misma efectividad.`, author: 'Manuel Mendoza', role: $localize`:@@testimonial.mendoza.role:Propietario, Etnia Escuela de Surf`, initials: 'MM', tone: '#c9db3e' },
    { quote: $localize`:@@testimonial.ayres:¡Excelente servicio! No solo crearon mi página web, también nos apoyan ante cualquier eventualidad o servicio adicional que necesitemos. Definitivamente lo recomiendo.`, author: 'Andrés Ayres', role: $localize`:@@testimonial.ayres.role:Propietario, Hotel Puerto Antiguo`, initials: 'AA', tone: '#deded8' },
    { quote: $localize`:@@testimonial.falcon:Gracias, Rtres, por la implementación de las páginas de Atiq Consultoría y Atiq Educación. 100% recomendados.`, author: 'Christian Falcón', role: $localize`:@@testimonial.falcon.role:Gerente general, Grupo Atiq`, initials: 'CF', tone: '#babcb5' },
    { quote: $localize`:@@testimonial.vejarano:Son totalmente profesionales y siempre dispuestos a mejorar. Resuelven las dudas en el menor tiempo posible y se puede contar con ellos de inmediato. La experiencia ha sido gratificante y enriquecedora.`, author: 'Nathaly Vejarano', role: $localize`:@@testimonial.vejarano.role:Cofundadora, Khalma`, initials: 'NV', tone: '#c9db3e' },
  ];

  index = signal(0);
  paused = signal(false);
  /** Opiniones visibles a la vez (2 en escritorio, 1 en móvil); en SSR se asume escritorio. */
  private perView = signal(2);
  maxIndex = computed(() => Math.max(0, this.testimonials.length - this.perView()));
  positions = computed(() => Array.from({ length: this.maxIndex() + 1 }, (_, i) => i));

  constructor() {
    const destroyRef = inject(DestroyRef);
    if (!isPlatformBrowser(inject(PLATFORM_ID))) return;
    afterNextRender(() => {
      const mobile = window.matchMedia('(max-width: 850px)');
      const sync = () => { this.perView.set(mobile.matches ? 1 : 2); this.go(this.index()); };
      sync();
      mobile.addEventListener('change', sync);
      // Sin autoavance si el usuario pidió reducir el movimiento.
      const timer = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? undefined
        : window.setInterval(() => { if (!this.paused() && !document.hidden) this.go(this.index() >= this.maxIndex() ? 0 : this.index() + 1); }, AUTOPLAY_MS);
      destroyRef.onDestroy(() => { mobile.removeEventListener('change', sync); window.clearInterval(timer); });
    });
  }

  go(i: number) { this.index.set(Math.min(Math.max(i, 0), this.maxIndex())); }
  isVisible(i: number) { return i >= this.index() && i < this.index() + this.perView(); }
}
