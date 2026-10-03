import { Component, OnInit, computed, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { ProductCardComponent } from '../product-card/product-card.component';
import { ClientProductApiDto, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

type Filter = 'vigentes' | 'atencion' | 'todos';

/** Estados que piden una acción del cliente (pagar o renovar). */
const NEEDS_ACTION = new Set(['PorVencer', 'Vencido', 'Pendiente']);

@Component({
  selector: 'app-services',
  standalone: true,
  imports: [CommonModule, RouterLink, ProductCardComponent],
  template: `<header class="page-head">
      <div>
        <h1 class="page-title">Mis servicios</h1>
        <p class="text-muted mt-1">Hosting, dominios, soporte y desarrollos que tienes con Rtres.</p>
      </div>
      <a routerLink="/catalog" class="btn btn-ghost btn-sm">Contratar otro servicio</a>
    </header>
    <nav class="tabs mt-6" aria-label="Filtrar servicios">
      @for (t of tabs; track t.value) {
        <button type="button" class="tab" [class.active]="filter() === t.value" [attr.aria-pressed]="filter() === t.value" (click)="filter.set(t.value)">
          {{ t.label }} <span class="tab-count">{{ count(t.value) }}</span>
        </button>
      }
    </nav>
    @if (loading()) {
      <div class="grid md:grid-cols-2 gap-5 mt-6"><div class="skeleton h-56"></div><div class="skeleton h-56"></div></div>
    } @else if (visible().length) {
      <div class="grid md:grid-cols-2 gap-5 mt-6">
        @for (product of visible(); track product.id) { <app-product-card [product]="product"/> }
      </div>
    } @else {
      <div class="empty mt-6">
        <p class="font-medium">{{ filter() === 'atencion' ? 'Todo al día: ningún servicio necesita tu atención.' : 'Aún no tienes servicios con Rtres.' }}</p>
        @if (filter() !== 'atencion') { <a routerLink="/catalog" class="btn btn-primary btn-sm mt-4">Ver catálogo</a> }
      </div>
    }`,
})
export class ServicesComponent implements OnInit {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);

  products = signal<ClientProductApiDto[]>([]);
  loading = signal(true);
  filter = signal<Filter>('vigentes');
  tabs: { value: Filter; label: string }[] = [
    { value: 'vigentes', label: 'Vigentes' },
    { value: 'atencion', label: 'Requieren atención' },
    { value: 'todos', label: 'Todos' },
  ];
  visible = computed(() => this.products().filter(p => this.matches(p, this.filter())));

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.loading.set(true);
      this.api.getClientProducts().subscribe({ next: p => { this.products.set(p); this.loading.set(false); }, error: () => this.loading.set(false) });
    }, { allowSignalWrites: true });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Mis servicios' });
  }

  count(f: Filter): number { return this.products().filter(p => this.matches(p, f)).length; }

  private matches(p: ClientProductApiDto, f: Filter): boolean {
    if (f === 'atencion') return NEEDS_ACTION.has(p.status);
    if (f === 'vigentes') return p.status !== 'Cancelado';
    return true;
  }
}
