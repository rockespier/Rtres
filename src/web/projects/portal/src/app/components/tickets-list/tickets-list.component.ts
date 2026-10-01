import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, effect, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { TicketTableComponent } from '../ticket-table/ticket-table.component';
import { FormsModule } from '@angular/forms';
import { PortalApiService, ProjectDto, TicketDto } from '../../core/portal-api.service';
import { TICKET_TYPE_LABELS } from '../ticket-type-pill/ticket-type-pill.component';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-tickets-list',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, TicketTableComponent],
  template: `<ng-template #actions>
      <a routerLink="/tickets/new" class="btn btn-primary btn-sm shrink-0">+ Nuevo ticket</a>
    </ng-template>
    <h1 class="font-display text-2xl font-semibold">Tickets</h1>
    <p class="text-muted mt-1">Reporta bugs y pide nuevas funcionalidades o requerimientos; te avisamos de cada avance.</p>
    <div class="grid sm:grid-cols-2 gap-3 mt-6 max-w-xl">
      <select class="field" aria-label="Estado" [ngModel]="status()" (ngModelChange)="setFilter(status, $event)">
        <option value="">Todos los estados</option>
        <option *ngFor="let s of statuses" [value]="s.value">{{ s.label }}</option>
      </select>
      <select class="field" aria-label="Tipo" [ngModel]="type()" (ngModelChange)="setFilter(type, $event)">
        <option value="">Todos los tipos</option>
        <option *ngFor="let t of types" [value]="t.value">{{ t.label }}</option>
      </select>
    </div>
    <app-ticket-table [tickets]="tickets()" [projects]="projects()"/>
    <div class="flex items-center gap-3 mt-5 text-xs text-muted">
      <button class="btn btn-ghost btn-sm" [disabled]="page() <= 1" (click)="page.set(page() - 1)">Anterior</button>
      <span>Página {{ page() }} de {{ totalPages() || 1 }}</span>
      <button class="btn btn-ghost btn-sm" [disabled]="page() >= totalPages()" (click)="page.set(page() + 1)">Siguiente</button>
    </div>`,
})
export class TicketsListComponent implements OnInit, AfterViewInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  tickets = signal<TicketDto[]>([]);
  projects = signal<ProjectDto[]>([]);
  page = signal(1);
  totalPages = signal(1);
  status = signal('');
  type = signal('');

  statuses = [
    { value: 'Abierto', label: 'Abierto' },
    { value: 'EnProgreso', label: 'En progreso' },
    { value: 'Resuelto', label: 'Resuelto' },
    { value: 'Publicado', label: 'Publicado' },
    { value: 'Cerrado', label: 'Cerrado' },
  ];
  types = Object.entries(TICKET_TYPE_LABELS).map(([value, label]) => ({ value, label }));

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.api.getProjects().subscribe(p => this.projects.set(p));
    });
    effect(() => {
      this.ui.viewingClientId();
      this.api.getTickets(this.page(), { status: this.status(), type: this.type() }).subscribe(r => {
        this.tickets.set(r.items);
        this.totalPages.set(r.totalPages);
      });
    });
  }

  setFilter(filter: typeof this.status, value: string): void {
    filter.set(value);
    this.page.set(1);
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
