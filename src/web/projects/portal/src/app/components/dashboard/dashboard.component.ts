import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { StatCardComponent } from '../stat-card/stat-card.component';
import { ProductCardComponent } from '../product-card/product-card.component';
import { ClientProductApiDto, DashboardSummary, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink, StatCardComponent, ProductCardComponent],
  template: `<ng-template #actions>
      <button type="button" class="relative w-9 h-9 rounded-full border border-[color:var(--border-strong)] hidden sm:flex items-center justify-center hover:bg-[color:var(--neutral-bg)] transition">
        <svg class="w-4 h-4 text-muted" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M18 8a6 6 0 00-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 01-3.4 0"/></svg>
        <span class="absolute -top-0.5 -right-0.5 w-2.5 h-2.5 rounded-full bg-[color:var(--primary)] ring-2 ring-[color:var(--surface)]"></span>
      </button>
      <a routerLink="/tickets/new" class="btn btn-primary btn-sm">+ Nuevo ticket</a>
      <div class="avatar w-9 h-9 bg-[color:var(--primary)] text-[13px]">RR</div>
    </ng-template>
    <h1 class="font-display text-2xl font-semibold">Mis productos</h1>
    <p class="text-muted mt-1">Todo lo que tienes con Rtres, en un solo lugar.</p>
    <div class="grid sm:grid-cols-2 lg:grid-cols-4 gap-4 mt-6" *ngIf="summary() as s">
      <app-stat-card label="Productos activos" [value]="s.activeProducts.toString()"/>
      <app-stat-card label="Por vencer" [value]="s.expiringSoon.toString()" variant="warn"/>
      <app-stat-card label="Tickets abiertos" [value]="s.openTickets.toString()"/>
      <app-stat-card label="Próximo pago" [value]="s.nextPaymentAmount ? ('$' + s.nextPaymentAmount) : '—'" variant="accent"/>
    </div>
    <div class="grid md:grid-cols-2 gap-5 mt-7">
      <app-product-card *ngFor="let product of products()" [product]="product"/>
    </div>`,
})
export class DashboardComponent implements OnInit, AfterViewInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  summary = signal<DashboardSummary | null>(null);
  products = signal<ClientProductApiDto[]>([]);

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.api.getDashboardSummary().subscribe(s => this.summary.set(s));
      this.api.getClientProducts().subscribe(p => this.products.set(p));
    });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Mis productos' });
  }

  ngAfterViewInit(): void {
    this.ui.actions.set(this.actionsTpl);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }
}
