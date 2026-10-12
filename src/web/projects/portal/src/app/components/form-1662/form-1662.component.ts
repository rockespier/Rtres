import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { Form1662Dto, Form1662Item, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { MoneyPipe } from '../../core/money.pipe';
import { SORTABLE } from '../../core/sortable';

/**
 * Formulario 1662 (IGV por utilización de servicios de no domiciliados): por cada pago a un proveedor del exterior se
 * presenta un formulario con el tributo 1041, el periodo del mes del pago y el 18 % al tipo de cambio venta de ese día.
 */
@Component({
  selector: 'app-form-1662',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, MoneyPipe, ...SORTABLE],
  template: `
    <div class="flex flex-wrap justify-between items-end gap-3">
      <div>
        <h1 class="font-display text-2xl font-semibold">Formulario 1662</h1>
        <p class="text-sm text-muted mt-1 max-w-2xl">IGV de los servicios de proveedores del exterior (OpenAI, Anthropic, Google…). Cada pago lleva su propio formulario en Clave SOL. Los gastos aparecen aquí cuando los marcas como "Servicio de un proveedor del exterior" en <a class="underline" routerLink="/admin/expenses">Gastos</a>.</p>
      </div>
      <input class="field" style="width:auto" type="month" [ngModel]="period" (ngModelChange)="period=$event;load()" aria-label="Mes del pago">
    </div>

    <ng-container *ngIf="data() as d">
      <div class="grid gap-4 mt-6 md:grid-cols-3">
        <div class="card p-6"><p class="stat-label">IGV a pagar del mes</p><p class="stat-value mt-2">{{ d.totalIgvPen | money }}</p><p class="text-xs text-muted mt-2">{{ d.items.length }} {{ d.items.length === 1 ? 'pago' : 'pagos' }} · {{ d.pendientes }} sin pagar</p></div>
        <div class="card p-6 md:col-span-2">
          <p class="stat-label">Datos de cada formulario</p>
          <dl class="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-3 text-sm">
            <div><dt class="text-muted text-xs">Periodo</dt><dd class="font-semibold tabular-nums">{{ d.periodo }}</dd></div>
            <div><dt class="text-muted text-xs">Código de tributo</dt><dd class="font-semibold">{{ d.tributo }}</dd></div>
            <div><dt class="text-muted text-xs">Tasa</dt><dd class="font-semibold">{{ d.igvRate | percent:'1.0-2' }}</dd></div>
            <div><dt class="text-muted text-xs">Crédito fiscal</dt><dd><span class="pill" [ngClass]="d.usedAsCredit ? 'pill-success' : 'pill-neutral'">{{ d.usedAsCredit ? 'Se usa' : 'No se usa' }}</span></dd></div>
          </dl>
          <p class="text-xs text-muted mt-3">Monto a pagar: 18 % del valor del servicio al tipo de cambio venta SUNAT del día del pago. <a *ngIf="!d.usedAsCredit" class="underline" routerLink="/admin/tax-settings">Activa el crédito fiscal</a><span *ngIf="!d.usedAsCredit"> cuando empieces a declarar el 1662.</span></p>
        </div>
      </div>

      <div class="card mt-4 overflow-x-auto">
        <table class="p-table w-full" appSort="date" #s="appSort" *ngIf="d.items.length; else empty">
          <thead><tr><th sortKey="date">Pago</th><th sortKey="supplier">Proveedor</th><th class="num" sortKey="amount">Monto</th><th class="num" sortKey="exchangeRate">TC venta</th><th class="num" sortKey="basePen">Base en soles</th><th class="num" sortKey="igvPen">IGV (1041)</th><th sortKey="paidAt">1662</th></tr></thead>
          <tbody>
            <tr *ngFor="let x of d.items | sortBy:s.key():s.dir()">
              <td class="whitespace-nowrap">{{ x.date | date:'dd/MM/yyyy' }}<span class="block text-xs text-muted">{{ x.description }}</span></td>
              <td><span class="font-medium">{{ x.supplier || '—' }}</span><span class="block text-xs text-muted">{{ x.country || 'País sin indicar' }}</span></td>
              <td class="num">{{ x.amount | money:x.currency }}</td>
              <td class="num">{{ x.currency === 'PEN' ? '—' : (x.exchangeRate | number:'1.3-3') }}</td>
              <td class="num">{{ x.basePen | money }}</td>
              <td class="num font-medium">{{ x.igvPen | money }}</td>
              <td>
                <ng-container *ngIf="x.paidAt; else unpaid"><span class="pill pill-success">Pagado</span><span class="block text-xs text-muted mt-1">{{ x.paidAt | date:'dd/MM/yyyy' }}{{ x.number ? ' · N° ' + x.number : '' }}</span><button class="btn btn-ghost btn-sm mt-1" (click)="unmark(x)">Desmarcar</button></ng-container>
                <ng-template #unpaid><button class="btn btn-primary btn-sm" (click)="startPay(x)">Marcar pagado</button></ng-template>
              </td>
            </tr>
          </tbody>
        </table>
        <ng-template #empty><p class="p-6 text-muted">No hay pagos a proveedores del exterior en este mes.</p></ng-template>
      </div>
    </ng-container>
    <p *ngIf="error()" class="text-sm text-red-600 mt-3">{{ error() }}</p>

    <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4" *ngIf="paying">
      <form class="card p-6 w-full max-w-sm space-y-3" role="dialog" aria-modal="true" aria-label="Registrar pago del Formulario 1662" (ngSubmit)="pay()">
        <h2 class="font-display text-xl">1662 pagado</h2>
        <p class="text-sm text-muted">{{ paying.supplier || paying.description }} · IGV {{ paying.igvPen | money }}</p>
        <label class="field-label">Fecha de pago<input class="field" type="date" [(ngModel)]="paidAt" name="paidAt" required></label>
        <label class="field-label">N° de orden (opcional)<input class="field" [(ngModel)]="number" name="number" maxlength="40"></label>
        <div class="flex justify-end gap-2"><button type="button" class="btn btn-ghost btn-sm" (click)="paying=null">Cancelar</button><button class="btn btn-primary btn-sm" [disabled]="busy()">Guardar</button></div>
      </form>
    </div>
  `,
})
export class Form1662Component implements OnInit {
  private api = inject(PortalApiService); private ui = inject(PortalUiService);
  period = new Date().toLocaleDateString('sv-SE').slice(0, 7);
  data = signal<Form1662Dto | null>(null);
  error = signal(''); busy = signal(false);
  paying: Form1662Item | null = null; paidAt = ''; number = '';

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Formulario 1662' }); this.load(); }

  load() {
    const [year, month] = this.period.split('-').map(Number);
    this.error.set('');
    this.api.getForm1662(year, month).subscribe({ next: d => this.data.set(d), error: e => this.error.set(e?.error?.message ?? 'No se pudo cargar el mes.') });
  }

  startPay(x: Form1662Item) { this.paying = x; this.paidAt = new Date().toLocaleDateString('sv-SE'); this.number = ''; this.error.set(''); }
  pay() {
    if (!this.paying) return;
    this.busy.set(true);
    this.api.markForm1662Paid(this.paying.id, { paidAt: this.paidAt, number: this.number.trim() || null }).subscribe({
      next: () => { this.busy.set(false); this.paying = null; this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo guardar.'); this.paying = null; },
    });
  }
  unmark(x: Form1662Item) { this.api.unmarkForm1662Paid(x.id).subscribe({ next: () => this.load(), error: e => this.error.set(e?.error?.message ?? 'No se pudo desmarcar.') }); }
}
