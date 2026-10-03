import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, computed, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { IconComponent } from '../icon/icon.component';
import { ClientProductApiDto, DashboardSummary, PortalApiService, TicketDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { AuthService } from '../../core/auth.service';
import { formatMoney } from '../../core/money.pipe';
import { ago } from '../../core/relative-time';

const TICKET_STATUS: Record<string, { label: string; tone: string }> = {
  Abierto: { label: 'Abierto', tone: 'success' },
  EnProgreso: { label: 'En progreso', tone: 'info' },
  Resuelto: { label: 'Resuelto', tone: 'neutral' },
  Publicado: { label: 'Publicado', tone: 'neutral' },
  Cerrado: { label: 'Cerrado', tone: 'danger' },
};

interface DueItem { id: string; name: string; detail: string; dateLabel: string; tone: string; when: string; }

const DAY_MS = 86_400_000;

/** Próxima fecha que pide algo al cliente: cobro (suscripción) o vencimiento (pago por periodo). */
function dueDate(p: ClientProductApiDto): Date | null {
  const iso = p.nextChargeAt ?? p.renewsAt;
  return iso ? new Date(iso) : null;
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, IconComponent],
  template: `<ng-template #actions>
      <a routerLink="/tickets/new" class="btn btn-primary btn-sm">Nuevo ticket</a>
    </ng-template>

    <section class="welcome">
      <p class="kicker">{{ viewing() ? 'Vista de cliente · ' + viewing() : 'Portal de asistencia' }}</p>
      <h1 class="greeting">Hola{{ firstName() ? ', ' + firstName() : '' }}.<br>¿En qué podemos ayudarte?</h1>
      <form class="ask" role="search" (ngSubmit)="ask()">
        <app-icon name="search" [size]="20" class="text-muted"/>
        <label for="ask" class="sr-only">Cuéntanos qué necesitas</label>
        <input id="ask" name="ask" [(ngModel)]="question" autocomplete="off" placeholder="Cuéntanos qué necesitas: un error, un cambio, una duda…">
        <button type="submit" class="btn btn-dark btn-sm" aria-label="Crear ticket" [disabled]="!question.trim()"><span class="hidden sm:inline">Crear ticket</span><app-icon name="arrow-right" [size]="16"/></button>
      </form>
      <div class="quick">
        <a routerLink="/tickets/new" [queryParams]="{ type: 'Bug' }" class="chip"><app-icon name="bug" [size]="16"/> Reportar un error</a>
        <a routerLink="/tickets/new" [queryParams]="{ type: 'Funcionalidad' }" class="chip"><app-icon name="sparkle" [size]="16"/> Pedir una mejora</a>
        <a routerLink="/billing" class="chip"><app-icon name="receipt" [size]="16"/> Ver mis pagos</a>
      </div>
    </section>

    <section class="band" aria-label="Resumen de tu cuenta">
      <svg class="band-art" viewBox="0 0 420 220" preserveAspectRatio="xMaxYMid slice" aria-hidden="true">
        @for (d of ribbon; track $index) { <path [attr.d]="d"/> }
      </svg>
      <div class="band-stats">
        <a routerLink="/services" class="band-stat">
          <span class="band-label">Servicios activos</span><span class="band-value">{{ summary()?.activeProducts ?? '–' }}</span>
        </a>
        <a routerLink="/services" class="band-stat" [class.alert]="(summary()?.expiringSoon ?? 0) > 0">
          <span class="band-label">Por vencer</span><span class="band-value">{{ summary()?.expiringSoon ?? '–' }}</span>
        </a>
        <a routerLink="/tickets" class="band-stat">
          <span class="band-label">Tickets abiertos</span><span class="band-value">{{ summary()?.openTickets ?? '–' }}</span>
        </a>
        <a routerLink="/billing" class="band-stat">
          <span class="band-label">Próximo pago</span><span class="band-value">{{ nextPayment() }}</span>
        </a>
      </div>
    </section>

    <div class="grid lg:grid-cols-[minmax(0,1.55fr)_minmax(0,1fr)] gap-5 mt-5">
      <section class="panel">
        <header class="panel-head">
          <h2>Tickets recientes</h2>
          <a routerLink="/tickets" class="link-more">Ver todos <app-icon name="arrow-right" [size]="14"/></a>
        </header>
        @if (loadingTickets()) {
          <div class="p-5 space-y-3"><div class="skeleton h-10"></div><div class="skeleton h-10"></div><div class="skeleton h-10"></div></div>
        } @else if (tickets().length) {
          <ul>
            @for (t of tickets(); track t.id) {
              <li>
                <a [routerLink]="['/tickets', t.id]" class="row">
                  <span class="min-w-0 flex-1">
                    <span class="block font-medium truncate">{{ t.title }}</span>
                    <span class="block text-xs text-muted mt-0.5">{{ t.code }} · actualizado {{ ago(t.updatedAt) }}</span>
                  </span>
                  <span class="status"><i class="dot" [ngClass]="'tone-' + status(t.status).tone"></i>{{ status(t.status).label }}</span>
                  <app-icon name="chevron" [size]="16" class="text-muted hidden sm:inline-flex"/>
                </a>
              </li>
            }
          </ul>
        } @else {
          <div class="panel-empty">
            <p class="font-medium">Aún no tienes tickets.</p>
            <p class="text-sm text-muted mt-1">Si algo no funciona o necesitas un cambio, escríbelo arriba y lo registramos.</p>
          </div>
        }
      </section>

      <section class="panel">
        <header class="panel-head">
          <h2>Próximos vencimientos</h2>
          <a routerLink="/services" class="link-more">Mis servicios <app-icon name="arrow-right" [size]="14"/></a>
        </header>
        @if (loadingProducts()) {
          <div class="p-5 space-y-3"><div class="skeleton h-10"></div><div class="skeleton h-10"></div></div>
        } @else if (due().length) {
          <ul>
            @for (d of due(); track d.id) {
              <li class="row static">
                <i class="dot" [ngClass]="'tone-' + d.tone"></i>
                <span class="min-w-0 flex-1">
                  <span class="block font-medium truncate">{{ d.name }}</span>
                  <span class="block text-xs text-muted mt-0.5 truncate">{{ d.detail }}</span>
                </span>
                <span class="text-right shrink-0">
                  <span class="block text-sm tabular-nums">{{ d.dateLabel }}</span>
                  <span class="block text-xs" [class.text-warn]="d.tone === 'warn'" [class.text-danger]="d.tone === 'danger'" [class.text-muted]="d.tone === 'success'">{{ d.when }}</span>
                </span>
              </li>
            }
          </ul>
        } @else {
          <div class="panel-empty">
            <p class="font-medium">Nada por renovar.</p>
            <p class="text-sm text-muted mt-1">Te avisaremos con tiempo antes de cada vencimiento.</p>
          </div>
        }
      </section>
    </div>`,
})
export class DashboardComponent implements OnInit, AfterViewInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  private auth = inject(AuthService);
  private router = inject(Router);
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  readonly ago = ago;
  question = '';

  summary = signal<DashboardSummary | null>(null);
  products = signal<ClientProductApiDto[]>([]);
  tickets = signal<TicketDto[]>([]);
  loadingTickets = signal(true);
  loadingProducts = signal(true);

  viewing = this.ui.viewingClientName;
  /** Nombre del cliente que entra; el SuperAdmin "viendo como" ve el saludo sin nombre. */
  firstName = computed(() => this.viewing() ? '' : this.auth.user()?.name?.trim().split(/\s+/)[0] ?? '');

  nextPayment = computed(() => {
    const amount = this.summary()?.nextPaymentAmount;
    if (!amount) return '—';
    const soonest = this.products().filter(p => p.status !== 'Cancelado' && dueDate(p)).sort((a, b) => +dueDate(a)! - +dueDate(b)!)[0];
    return formatMoney(amount, soonest?.product.currency ?? 'USD');
  });

  due = computed<DueItem[]>(() => {
    const now = Date.now();
    return this.products()
      .filter(p => p.status !== 'Cancelado')
      .map(p => ({ p, date: dueDate(p) }))
      .filter((x): x is { p: ClientProductApiDto; date: Date } => !!x.date)
      .sort((a, b) => +a.date - +b.date)
      .slice(0, 5)
      .map(({ p, date }) => {
        const days = Math.ceil((+date - now) / DAY_MS);
        const tone = days < 0 ? 'danger' : days <= 30 ? 'warn' : 'success';
        const when = days < 0 ? `venció hace ${-days} d` : days === 0 ? 'hoy' : days === 1 ? 'mañana' : `en ${days} días`;
        const dateLabel = date.toLocaleDateString('es-PE', { day: 'numeric', month: 'short', year: 'numeric' });
        return { id: p.id, name: p.domainName || p.product.name, detail: p.domainName ? p.product.name : p.project.name, dateLabel, tone, when };
      });
  });

  /** Cintas de la banda (eco del fondo lima de la referencia): curvas paralelas que se abren hacia la derecha. */
  readonly ribbon = Array.from({ length: 26 }, (_, i) =>
    `M ${40 + i * 5} 240 C ${150 + i * 6} ${200 - i * 3}, ${210 + i * 4} ${60 - i * 2}, ${440} ${10 + i * 6}`);

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.loadingTickets.set(true);
      this.loadingProducts.set(true);
      this.api.getDashboardSummary().subscribe(s => this.summary.set(s));
      this.api.getClientProducts().subscribe({ next: p => { this.products.set(p); this.loadingProducts.set(false); }, error: () => this.loadingProducts.set(false) });
      this.api.getTickets(1).subscribe({ next: page => { this.tickets.set(page.items.slice(0, 5)); this.loadingTickets.set(false); }, error: () => this.loadingTickets.set(false) });
    }, { allowSignalWrites: true });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Inicio' });
  }

  ngAfterViewInit(): void {
    this.ui.actions.set(this.actionsTpl);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }

  status(s: string) { return TICKET_STATUS[s] ?? { label: s, tone: 'neutral' }; }

  ask(): void {
    const title = this.question.trim();
    if (title) this.router.navigate(['/tickets/new'], { queryParams: { title } });
  }
}
