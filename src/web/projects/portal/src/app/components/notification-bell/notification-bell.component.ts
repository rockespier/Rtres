import { Component, DestroyRef, ElementRef, HostListener, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router } from '@angular/router';
import { PortalApiService, PortalNotificationDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { formatMoney } from '../../core/money.pipe';
import { ago } from '../../core/relative-time';

const POLL_MS = 60_000;
const TICKET_STATUS: Record<string, string> = { Abierto: 'Abierto', EnProgreso: 'En progreso', Resuelto: 'Resuelto', Publicado: 'Publicado', Cerrado: 'Cerrado' };

interface NotificationView { id: string; title: string; detail: string; link: string; createdAt: string; unread: boolean; tone: string; }

type NotificationText = Pick<NotificationView, 'tone' | 'title' | 'detail' | 'link'>;

/** "vence hoy", "vence mañana" o "vence en N días". */
function dueIn(days: number): string {
  if (days <= 0) return 'vence hoy';
  return days === 1 ? 'vence mañana' : `vence en ${days} días`;
}

/** Título con el importe al final, si el aviso lo trae. */
function withAmount(title: string, amount: string): string {
  return amount ? `${title}: ${amount}` : title;
}

function renewalText(d: Record<string, string>, company: string, amount: string): NotificationText {
  const detail = amount ? `Renovación: ${amount}` : d['product'] ?? '';
  return { tone: 'warn', title: `${d['domain'] || d['product']} ${dueIn(Number(d['days']))}`, detail: company + detail, link: '/services' };
}

function taxDueText(d: Record<string, string>): NotificationText {
  const days = Number(d['days']);
  const [y, m] = (d['period'] ?? '').split('-').map(Number);
  const period = m ? new Date(y, m - 1, 1).toLocaleDateString('es-PE', { month: 'long', year: 'numeric' }) : d['period'];
  return { tone: days <= 1 ? 'danger' : 'warn', title: `Declaración SUNAT ${dueIn(days)}`, detail: `Periodo ${period}`, link: '/admin/tax-calendar' };
}

/** Texto, enlace y color de cada aviso, a partir de los mismos datos que usa el email. */
function describe(n: PortalNotificationDto): NotificationView {
  const d = n.data;
  const amount = d['amount'] ? formatMoney(Number(d['amount']), d['currency'] || 'USD') : '';
  const company = n.company ? `${n.company} · ` : '';
  return { id: n.id, createdAt: n.createdAt, unread: n.unread, ...notificationText(n.type, d, company, amount) };
}

function notificationText(type: string, d: Record<string, string>, company: string, amount: string): NotificationText {
  switch (type) {
    case 'TicketStatusChanged': return { tone: 'info', title: `Ticket ${d['code']}: ${TICKET_STATUS[d['status']] ?? d['status']}`, detail: company + (d['title'] ?? ''), link: `/tickets/${d['ticketId']}` };
    case 'TicketReply': return { tone: 'info', title: `Nueva respuesta en ${d['code']}`, detail: company + (d['title'] ?? ''), link: `/tickets/${d['ticketId']}` };
    case 'RenewalReminder': return renewalText(d, company, amount);
    case 'PaymentReceived': return { tone: 'success', title: withAmount('Pago recibido', amount), detail: company + (d['product'] ?? ''), link: '/billing' };
    case 'PaymentFailed': return { tone: 'danger', title: 'No se pudo cobrar un pago', detail: company + (d['product'] ?? ''), link: '/services' };
    case 'TicketCreated': return { tone: 'info', title: `Ticket nuevo ${d['code']}`, detail: `${d['company'] ?? ''} · ${d['title'] ?? ''}`, link: '/admin/tickets' };
    case 'TransferRequested': return { tone: 'warn', title: withAmount('Pago por transferencia pendiente', amount), detail: `${d['company'] ?? ''} · ${d['product'] ?? ''}`, link: `/admin/clients/${d['clientId']}` };
    case 'ContactLead': return { tone: 'info', title: `Nuevo contacto: ${d['name'] ?? ''}`, detail: [d['company'], d['service']].filter(Boolean).join(' · ') || (d['email'] ?? ''), link: '/admin/leads' };
    case 'TransferReported': return { tone: 'warn', title: withAmount('Pago por confirmar', amount), detail: `${d['company'] ?? ''} · ${d['product'] ?? ''}`, link: '/admin/transfer-reports' };
    case 'TransferRejected': return { tone: 'danger', title: 'No pudimos confirmar tu pago', detail: company + (d['product'] ?? ''), link: '/services' };
    case 'TaxDueReminder': return taxDueText(d);
    default: return { tone: 'neutral', title: type, detail: company, link: '/' };
  }
}


/** Campana del topbar: últimos cambios de tickets, vencimientos y pagos. Al abrirla, todo queda leído. */
@Component({
  selector: 'app-notification-bell',
  standalone: true,
  imports: [CommonModule],
  template: `<div class="relative">
    <button type="button" class="bell" [class.open]="open()" (click)="toggle()" [attr.aria-expanded]="open()" [attr.aria-label]="unread() ? 'Notificaciones, ' + unread() + ' sin leer' : 'Notificaciones'">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/></svg>
      <span *ngIf="unread()" class="bell-badge">{{ unread() > 9 ? '9+' : unread() }}</span>
    </button>
    <section *ngIf="open()" class="bell-panel card" role="dialog" aria-label="Notificaciones">
      <header class="flex items-center justify-between px-4 py-3 border-b"><h2 class="font-display font-semibold">Notificaciones</h2><span class="text-xs text-muted" *ngIf="items().length">Últimas {{ items().length }}</span></header>
      <p *ngIf="!items().length" class="px-4 py-8 text-sm text-muted text-center">No hay novedades por ahora.</p>
      <ul class="max-h-[420px] overflow-y-auto">
        <li *ngFor="let n of items()">
          <button type="button" class="bell-item" [class.unread]="n.unread" (click)="go(n)">
            <i class="bell-dot" [ngClass]="'tone-' + n.tone"></i>
            <span class="min-w-0 flex-1 text-left"><span class="block text-sm font-medium truncate">{{ n.title }}</span><span class="block text-xs text-muted truncate">{{ n.detail }}</span></span>
            <span class="text-xs text-muted whitespace-nowrap">{{ ago(n.createdAt) }}</span>
          </button>
        </li>
      </ul>
    </section>
  </div>`,
  styles: [`
    .bell{position:relative;display:grid;place-items:center;width:40px;height:40px;border-radius:999px;color:var(--muted);border:1px solid var(--border);background:var(--surface)}
    .bell:hover,.bell.open{color:var(--ink);background:var(--neutral-bg)}
    .bell-badge{position:absolute;top:-5px;right:-5px;min-width:18px;height:18px;padding:0 5px;border-radius:99px;background:var(--danger-ink);color:#fff;font-size:10.5px;font-weight:700;display:grid;place-items:center;border:2px solid var(--surface)}
    .bell-panel{position:absolute;right:0;top:calc(100% + 8px);width:min(380px,calc(100vw - 32px));z-index:40;box-shadow:var(--shadow-pop);overflow:hidden}
    .bell-item{display:flex;align-items:center;gap:12px;width:100%;padding:12px 16px;border-bottom:1px solid var(--border)}
    .bell-item:hover{background:var(--neutral-bg)}
    .bell-item.unread{background:var(--surface-tint)}
    .bell-dot{width:8px;height:8px;border-radius:99px;flex:none}
    .tone-info{background:var(--info-ink)}.tone-warn{background:var(--warn-ink)}.tone-success{background:var(--success-ink)}.tone-danger{background:var(--danger-ink)}.tone-neutral{background:var(--muted-2)}
  `],
})
export class NotificationBellComponent {
  private readonly api = inject(PortalApiService);
  private readonly ui = inject(PortalUiService);
  private readonly router = inject(Router);
  private readonly host = inject(ElementRef<HTMLElement>);
  open = signal(false);
  unread = signal(0);
  items = signal<NotificationView[]>([]);
  readonly ago = ago;

  constructor() {
    effect(() => { this.ui.viewingClientId(); this.load(); });
    const timer = setInterval(() => this.load(), POLL_MS);
    inject(DestroyRef).onDestroy(() => clearInterval(timer));
  }

  load() { this.api.getNotifications().subscribe({ next: r => { this.items.set(r.items.map(describe)); this.unread.set(r.unread); }, error: () => {} }); }

  toggle() {
    this.open.update(x => !x);
    if (this.open() && this.unread()) this.api.markNotificationsSeen().subscribe(() => this.unread.set(0));
    else if (!this.open()) this.items.update(list => list.map(n => ({ ...n, unread: false })));
  }

  go(n: NotificationView) { this.open.set(false); void this.router.navigateByUrl(n.link); }

  @HostListener('document:click', ['$event'])
  closeOutside(event: MouseEvent) { if (this.open() && !this.host.nativeElement.contains(event.target as Node)) this.toggle(); }

  @HostListener('document:keydown.escape')
  closeOnEscape() { if (this.open()) this.toggle(); }
}
