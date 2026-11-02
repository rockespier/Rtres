import { Injectable, PLATFORM_ID, inject, signal } from '@angular/core';
import { isPlatformBrowser } from '@angular/common';

type Choice = 'granted' | 'denied';
const KEY = 'rtres-consent';

/** Consentimiento de cookies analíticas (GA4 Consent Mode v2). El valor por defecto 'denied' lo fija index.html. */
@Injectable({ providedIn: 'root' })
export class CookieConsentService {
  private readonly browser = isPlatformBrowser(inject(PLATFORM_ID));
  /** Banner visible: solo en navegador y sin elección guardada. */
  readonly open = signal(this.browser && !this.read());

  set(choice: Choice): void {
    try { localStorage.setItem(KEY, choice); } catch { /* modo privado: solo aplica a esta visita */ }
    const gtag = (window as unknown as { gtag?: (...a: unknown[]) => void }).gtag;
    gtag?.('consent', 'update', { analytics_storage: choice });
    if (choice === 'denied') this.clearGaCookies();
    this.open.set(false);
  }

  reopen(): void {
    if (this.browser) this.open.set(true);
  }

  private read(): Choice | null {
    try { return localStorage.getItem(KEY) as Choice | null; } catch { return null; }
  }

  /** Borra _ga/_ga_* si el visitante retira el consentimiento. */
  private clearGaCookies(): void {
    const host = location.hostname.replace(/^www\./, '');
    for (const c of document.cookie.split(';')) {
      const name = c.split('=')[0].trim();
      if (!name.startsWith('_ga')) continue;
      for (const domain of ['', `;domain=.${host}`, `;domain=${host}`]) {
        document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/${domain}`;
      }
    }
  }
}
