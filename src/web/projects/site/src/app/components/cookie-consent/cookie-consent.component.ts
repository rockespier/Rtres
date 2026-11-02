import { Component, inject } from '@angular/core';
import { CookieConsentService } from './cookie-consent.service';

@Component({
  selector: 'app-cookie-consent',
  standalone: true,
  template: `
    @if (consent.open()) {
      <section role="dialog" aria-live="polite" aria-labelledby="cc-title">
        <p>
          <b id="cc-title" i18n="@@cookies.title">Cookies</b>
          <span i18n="@@cookies.text">Usamos cookies de Google Analytics para medir visitas y mejorar el sitio. Solo se activan si las aceptas.</span>
        </p>
        <div class="actions">
          <button type="button" class="ghost" (click)="consent.set('denied')" i18n="@@cookies.reject">Rechazar</button>
          <button type="button" class="lime" (click)="consent.set('granted')" i18n="@@cookies.accept">Aceptar</button>
        </div>
      </section>
    }
  `,
  styles: [`
    section{position:fixed;left:16px;right:16px;bottom:16px;z-index:1000;max-width:720px;margin:0 auto;display:flex;align-items:center;gap:20px;padding:18px 20px;background:var(--v2-dark);color:#f5f5f0;font:14px/1.5 Arial,Helvetica,sans-serif;box-shadow:0 10px 30px rgba(0,0,0,.25)}
    p{margin:0;flex:1}
    b{display:block;margin-bottom:4px;font-size:11px;letter-spacing:.2em;text-transform:uppercase;color:var(--v2-lime)}
    .actions{display:flex;gap:10px;flex-shrink:0}
    button{padding:11px 18px;font:bold 13px Arial,Helvetica,sans-serif;cursor:pointer;border:1px solid var(--v2-lime)}
    .lime{background:var(--v2-lime);color:var(--v2-ink)}
    .ghost{background:transparent;color:#f5f5f0}
    button:focus-visible{outline:2px solid #fff;outline-offset:2px}
    @media(max-width:600px){section{flex-direction:column;align-items:stretch}.actions button{flex:1}}
  `],
})
export class CookieConsentComponent {
  readonly consent = inject(CookieConsentService);
}
