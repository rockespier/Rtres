import { Component, Input, LOCALE_ID, OnInit, PLATFORM_ID, inject, signal } from '@angular/core';
import { DOCUMENT, isPlatformBrowser } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpErrorResponse } from '@angular/common/http';
import { PublicApiService } from '../../core/public-api.service';
import { SERVICE_LINKS } from '../../core/site-nav';

/**
 * Formulario de contacto: llega al portal (Contactos de la web) y avisa al equipo por email. El campo "website" está
 * oculto para las personas: si llega con valor, el API lo trata como bot.
 */
@Component({
  selector: 'app-contact-form',
  standalone: true,
  imports: [FormsModule],
  template: `
    @if (sent()) {
      <div class="done" role="status">
        <p class="v2-label" i18n="@@contactForm.sentLabel">MENSAJE ENVIADO</p>
        <p class="done-title" i18n="@@contactForm.sentTitle">Gracias, {{ firstName() }}. Te escribimos pronto.</p>
        <p i18n="@@contactForm.sentText">Revisaremos lo que nos contaste y te responderemos por email o WhatsApp.</p>
      </div>
    } @else {
      <form (ngSubmit)="submit()" novalidate>
        <div class="row">
          <label><span><span i18n="@@contactForm.name">Nombre</span> <span class="req" aria-hidden="true">*</span></span><input name="name" [(ngModel)]="model.name" required maxlength="150" autocomplete="name" [attr.aria-invalid]="field() === 'name'"></label>
          <label><span><span i18n="@@contactForm.email">Email</span> <span class="req" aria-hidden="true">*</span></span><input name="email" type="email" [(ngModel)]="model.email" required maxlength="200" autocomplete="email" [attr.aria-invalid]="field() === 'email'"></label>
        </div>
        <div class="row">
          <label><span i18n="@@contactForm.phone">Teléfono o WhatsApp</span><input name="phone" type="tel" [(ngModel)]="model.phone" maxlength="40" autocomplete="tel"></label>
          <label><span i18n="@@contactForm.company">Empresa</span><input name="company" [(ngModel)]="model.company" maxlength="150" autocomplete="organization"></label>
        </div>
        <label><span i18n="@@contactForm.service">¿Qué necesitas?</span>
          <select name="service" [(ngModel)]="model.service">
            <option value="" i18n="@@contactForm.serviceAny">Elige una opción</option>
            @for (s of services; track s.path) { <option [value]="slug(s.path)">{{ s.label }}</option> }
            <option value="apis" i18n="@@contactForm.serviceApis">APIs de validación (RUC, DNI, cuentas bancarias)</option>
            <option value="otro" i18n="@@contactForm.serviceOther">Otro</option>
          </select>
        </label>
        <label><span><span i18n="@@contactForm.message">Cuéntanos tu proyecto</span> <span class="req" aria-hidden="true">*</span></span><textarea name="message" rows="5" [(ngModel)]="model.message" required maxlength="4000" [attr.aria-invalid]="field() === 'message'"></textarea></label>
        <!-- Campo trampa contra bots: oculto para personas y lectores de pantalla. -->
        <label class="trap" aria-hidden="true">Website<input name="website" [(ngModel)]="model.website" tabindex="-1" autocomplete="off"></label>
        @if (error()) { <p class="error" role="alert">{{ error() }}</p> }
        <button class="v2-btn-lime" [disabled]="sending()">{{ sending() ? sendingLabel : sendLabel }}</button>
        <p class="note" i18n="@@contactForm.privacy">Usamos tus datos solo para responderte.</p>
      </form>
    }
  `,
  styles: [`
    :host{display:block}
    form{display:grid;gap:18px}
    .row{display:grid;grid-template-columns:1fr 1fr;gap:18px}
    label{display:grid;gap:7px;font-size:13px;font-weight:bold;letter-spacing:.02em}
    input,select,textarea{font:inherit;font-weight:normal;font-size:16px;padding:13px 14px;border:1px solid var(--v2-rule);background:#fff;color:var(--v2-ink);border-radius:0;width:100%;box-sizing:border-box}
    input:focus,select:focus,textarea:focus{outline:2px solid var(--v2-ink);outline-offset:0}
    [aria-invalid=true]{border-color:#b42318;outline-color:#b42318}
    textarea{resize:vertical;min-height:130px}
    button{justify-self:start;border:0;cursor:pointer;font-size:15px}
    button:disabled{opacity:.6;cursor:default}
    .trap{position:absolute;left:-9999px;width:1px;height:1px;overflow:hidden}
    .req{color:#b42318}
    .error{margin:0;color:#b42318;font-size:15px}
    .note{margin:0;font-size:12px;color:var(--v2-muted)}
    .done{padding:30px 0}
    .done-title{font:clamp(1.8rem,3vw,2.6rem)/1.1 Georgia,serif;letter-spacing:-.03em;margin:14px 0}
    @media(max-width:850px){.row{grid-template-columns:1fr} button{justify-self:stretch;text-align:center}}
  `],
})
export class ContactFormComponent implements OnInit {
  private api = inject(PublicApiService);
  private document = inject(DOCUMENT);
  private browser = isPlatformBrowser(inject(PLATFORM_ID));
  private locale = inject(LOCALE_ID).slice(0, 2);
  /** Servicio preseleccionado (slug), p. ej. desde la página del servicio. */
  @Input() service = '';

  readonly services = SERVICE_LINKS;
  readonly sendLabel = $localize`:@@contactForm.send:Enviar mensaje`;
  readonly sendingLabel = $localize`:@@contactForm.sending:Enviando…`;
  model = { name: '', email: '', phone: '', company: '', service: '', message: '', website: '' };
  sending = signal(false); sent = signal(false); error = signal(''); field = signal('');

  ngOnInit() { this.model.service = this.service; }

  slug(path: string) { return path.split('/').pop() ?? ''; }
  firstName() { return this.model.name.trim().split(/\s+/)[0]; }

  submit() {
    const m = this.model;
    const missing = !m.name.trim() ? 'name' : !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(m.email.trim()) ? 'email' : m.message.trim().length < 10 ? 'message' : '';
    if (missing) { this.field.set(missing); this.error.set(MESSAGES[missing]); return; }
    this.sending.set(true); this.error.set(''); this.field.set('');
    this.api.sendContact({ ...m, locale: this.locale, page: this.sourcePage() }).subscribe({
      next: () => { this.sending.set(false); this.sent.set(true); },
      error: (e: HttpErrorResponse) => {
        this.sending.set(false);
        this.field.set(e.error?.field ?? '');
        this.error.set(e.status === 429 ? MESSAGES['tooMany'] : e.error?.field ? MESSAGES[e.error.field] ?? MESSAGES['generic'] : MESSAGES['generic']);
      },
    });
  }

  /** Página del sitio desde la que llegó (para saber qué contenido convierte); si no, la actual. */
  private sourcePage() {
    if (!this.browser) return '';
    try { const ref = new URL(this.document.referrer); if (ref.host === this.document.location.host) return ref.pathname; } catch { /* sin referrer */ }
    return this.document.location.pathname;
  }
}

const MESSAGES: Record<string, string> = {
  name: $localize`:@@contactForm.errName:Escribe tu nombre.`,
  email: $localize`:@@contactForm.errEmail:Escribe un email válido para poder responderte.`,
  message: $localize`:@@contactForm.errMessage:Cuéntanos en unas líneas qué necesitas.`,
  tooMany: $localize`:@@contactForm.errTooMany:Recibimos varios mensajes desde tu conexión. Espera unos minutos o escríbenos a info@rtres.net.`,
  generic: $localize`:@@contactForm.errGeneric:No pudimos enviar el mensaje. Inténtalo de nuevo o escríbenos a info@rtres.net.`,
};
