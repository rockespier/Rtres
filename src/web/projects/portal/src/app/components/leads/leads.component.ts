import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ContactLeadDto, ContactLeadStatus, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { SORTABLE } from '../../core/sortable';

const STATUS: { value: ContactLeadStatus; label: string; pill: string }[] = [
  { value: 'Nuevo', label: 'Nuevo', pill: 'pill-warn' },
  { value: 'Contactado', label: 'Contactado', pill: 'pill-info' },
  { value: 'Cliente', label: 'Se hizo cliente', pill: 'pill-success' },
  { value: 'Descartado', label: 'Descartado', pill: 'pill-neutral' },
];
const SERVICES: Record<string, string> = {
  'software-a-medida': 'Software a medida', 'apps-y-experiencias-web': 'Apps y experiencias web', 'integracion-y-automatizacion': 'Integración y automatización',
  'hosting-dominios-y-soporte': 'Hosting, dominios y soporte', apis: 'APIs de validación', otro: 'Otro',
};

/** Contactos que llegan desde el formulario de rtres.net/contacto: seguimiento y de qué página vinieron. */
@Component({
  selector: 'app-leads',
  standalone: true,
  imports: [CommonModule, FormsModule, ...SORTABLE],
  template: `
    <h1 class="font-display text-2xl font-semibold">Contactos de la web</h1>
    <p class="text-sm text-muted mt-1 max-w-2xl">Mensajes del formulario de rtres.net/contacto. Cada uno te llega también por correo; aquí llevas el seguimiento y ves desde qué página escribió cada persona.</p>

    <div class="grid gap-4 mt-6 sm:grid-cols-3">
      <div class="card p-5"><p class="stat-label">Nuevos sin responder</p><p class="stat-value mt-2">{{ count('Nuevo') }}</p></div>
      <div class="card p-5"><p class="stat-label">Últimos 30 días</p><p class="stat-value mt-2">{{ last30() }}</p></div>
      <div class="card p-5"><p class="stat-label">Se hicieron clientes</p><p class="stat-value mt-2">{{ count('Cliente') }}</p></div>
    </div>

    <div class="card mt-4 overflow-x-auto">
      <table class="p-table w-full" appSort="createdAt:desc" #s="appSort" *ngIf="items().length; else empty">
        <thead><tr><th sortKey="createdAt">Fecha</th><th sortKey="name">Contacto</th><th sortKey="service">Interés</th><th>Mensaje</th><th sortKey="sourcePage">Página</th><th sortKey="status">Estado</th></tr></thead>
        <tbody>
          <tr *ngFor="let x of items() | sortBy:s.key():s.dir()">
            <td class="whitespace-nowrap">{{ x.createdAt | date:'dd/MM/yyyy HH:mm' }}<span class="block text-xs text-muted uppercase">{{ x.locale }}</span></td>
            <td><span class="font-medium">{{ x.name }}</span><span *ngIf="x.company" class="block text-xs text-muted">{{ x.company }}</span><a class="block text-xs underline" [href]="'mailto:' + x.email">{{ x.email }}</a><a *ngIf="x.phone" class="block text-xs underline" [href]="whatsapp(x.phone)" target="_blank" rel="noopener">{{ x.phone }}</a></td>
            <td>{{ serviceLabel(x.service) }}</td>
            <td class="max-w-md"><p class="text-sm whitespace-pre-line" [class.line-clamp-3]="openId !== x.id">{{ x.message }}</p><button *ngIf="x.message.length > 160" class="text-xs underline mt-1" (click)="openId = openId === x.id ? null : x.id">{{ openId === x.id ? 'Ver menos' : 'Ver todo' }}</button></td>
            <td class="text-xs text-muted">{{ x.sourcePage || '—' }}</td>
            <td><select class="field text-sm" style="width:auto" [ngModel]="x.status" (ngModelChange)="setStatus(x, $event)" [attr.aria-label]="'Estado de ' + x.name"><option *ngFor="let st of statuses" [ngValue]="st.value">{{ st.label }}</option></select></td>
          </tr>
        </tbody>
      </table>
      <ng-template #empty><p class="p-6 text-muted">Aún no llegaron mensajes desde la web.</p></ng-template>
    </div>
    <p *ngIf="error()" class="text-sm text-red-600 mt-3">{{ error() }}</p>
  `,
})
export class LeadsComponent implements OnInit {
  private api = inject(PortalApiService); private ui = inject(PortalUiService);
  readonly statuses = STATUS;
  items = signal<ContactLeadDto[]>([]);
  error = signal('');
  openId: string | null = null;
  last30 = computed(() => this.items().filter(x => Date.now() - new Date(x.createdAt).getTime() <= 30 * 86_400_000).length);

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Contactos de la web' }); this.load(); }
  load() { this.api.getLeads().subscribe({ next: x => this.items.set(x), error: () => this.error.set('No se pudieron cargar los contactos.') }); }
  count(status: ContactLeadStatus) { return this.items().filter(x => x.status === status).length; }
  serviceLabel(s: string | null) { return s ? SERVICES[s] ?? s : '—'; }
  /** wa.me necesita solo dígitos con código de país. */
  whatsapp(phone: string) { return 'https://wa.me/' + phone.replace(/\D/g, ''); }

  setStatus(x: ContactLeadDto, status: ContactLeadStatus) {
    this.api.updateLead(x.id, { status }).subscribe({
      next: updated => this.items.update(list => list.map(i => i.id === updated.id ? updated : i)),
      error: () => { this.error.set('No se pudo guardar el estado.'); this.load(); },
    });
  }
}
