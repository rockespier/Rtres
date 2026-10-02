import { Component } from '@angular/core';

interface Testimonial { quote: string; author: string; role: string; initials: string; tone: string; }

@Component({
  selector: 'app-home-support',
  standalone: true,
  template: `
    <section id="portal">
      <div class="support-copy">
        <p class="support-label" i18n="@@home.support.label">CLIENTES Y SOPORTE</p>
        <h2 i18n="@@home.support.title">No desaparecemos<br><i>al entregar.</i></h2>
        <div class="testimonials">
          @for (t of testimonials; track t.author) {
            <blockquote class="testimonial">
              <p>“{{ t.quote }}”</p>
              <div class="testimonial-meta">
                <span class="avatar" [style.background]="t.tone" aria-hidden="true">{{ t.initials }}</span>
                <span><b>{{ t.author }}</b><small>{{ t.role }}</small></span>
              </div>
            </blockquote>
          }
        </div>
        <a class="continues" href="#contacto"><span i18n="@@home.support.continues">PROYECTOS QUE CONTINÚAN</span><i></i><b aria-hidden="true">→</b></a>
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
    .support-copy{display:flex;flex-direction:column;padding:68px 7% 54px 6%}
    .support-label{display:flex;align-items:center;gap:24px;margin:0;color:#f7f7f2;font:11px Arial;letter-spacing:.24em}
    .support-label:after{content:"";height:1px;flex:1;background:#666}
    .support-copy>h2{max-width:760px;margin:34px 0 0;font:clamp(3.4rem,5.1vw,5.5rem)/.93 Georgia,serif;letter-spacing:-.04em;text-wrap:balance}
    .support-copy>h2 i{color:var(--v2-lime)}
    .testimonials{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));margin-top:64px;max-width:900px}
    .testimonial{margin:0;padding:0 48px 0 0}
    .testimonial+.testimonial{padding:0 0 0 48px;border-left:1px solid #3c3c3c}
    .testimonial p{margin:0;color:#f5f5ef;font:clamp(1.75rem,2.55vw,2.7rem)/1.08 Georgia,serif;letter-spacing:-.035em;text-wrap:balance}
    .testimonial-meta{display:flex;align-items:center;gap:17px;margin-top:31px}
    .avatar{display:grid;place-items:center;flex:none;width:58px;height:58px;border-radius:50%;color:#171717;font:700 11px Arial;letter-spacing:.04em}
    .testimonial-meta b{display:block;color:#fff;font:400 20px Georgia,serif}
    .testimonial-meta small{display:block;margin-top:5px;color:#c9c9c4;font:10px Arial;text-transform:uppercase;letter-spacing:.2em}
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
    }
  `],
})
export class HomeSupportComponent {
  readonly testimonials: Testimonial[] = [
    { quote: $localize`:@@home.support.t1.quote:Rtres cumple en exceso con nuestras expectativas.`, author: 'Erick Weston', role: $localize`:@@home.support.t1.role:Gerente comercial`, initials: 'EW', tone: '#deded8' },
    { quote: $localize`:@@home.support.t2.quote:Siempre presentes para ir mejorando mi sitio web.`, author: 'Hosefa Tavolara', role: $localize`:@@home.support.t2.role:Artista plástica`, initials: 'HT', tone: '#babcb5' },
  ];
}
