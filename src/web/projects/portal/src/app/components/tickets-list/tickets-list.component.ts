import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { TicketTableComponent } from '../ticket-table/ticket-table.component';
import { PortalApiService, TicketDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-tickets-list',
  standalone: true,
  imports: [CommonModule, RouterLink, TicketTableComponent],
  template: `<ng-template #actions>
      <a routerLink="/tickets/new" class="btn btn-primary btn-sm shrink-0">+ Nuevo ticket</a>
    </ng-template>
    <h1 class="font-display text-2xl font-semibold">Tickets</h1>
    <p class="text-muted mt-1">Soporte y solicitudes de cambio, sincronizados con GitHub.</p>
    <div class="flex gap-3 mt-6"><input class="field" placeholder="Buscar tickets…"><select class="field"><option>Todos los estados</option></select><select class="field"><option>Todos los tipos</option></select><button class="btn btn-ghost">Filtrar</button></div>
    <app-ticket-table [tickets]="tickets()"/>
    <p class="text-xs text-muted mt-5">Página {{ page() }} de {{ totalPages() }}</p>`,
})
export class TicketsListComponent implements OnInit, AfterViewInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  tickets = signal<TicketDto[]>([]);
  page = signal(1);
  totalPages = signal(1);

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.api.getTickets(this.page()).subscribe(r => {
        this.tickets.set(r.items);
        this.page.set(r.page);
        this.totalPages.set(r.totalPages);
      });
    });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Tickets' });
  }

  ngAfterViewInit(): void {
    this.ui.actions.set(this.actionsTpl);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }
}
