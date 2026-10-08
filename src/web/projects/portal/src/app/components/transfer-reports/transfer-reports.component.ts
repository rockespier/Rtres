import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService, TransferReportDto, TransferReportStatus } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { MoneyPipe } from '../../core/money.pipe';
import { SORTABLE } from '../../core/sortable';

const STATUS_LABEL: Record<TransferReportStatus, string> = { Pendiente: 'Por confirmar', Aprobado: 'Confirmado', Rechazado: 'Rechazado' };
const STATUS_PILL: Record<TransferReportStatus, string> = { Pendiente: 'pill-warn', Aprobado: 'pill-success', Rechazado: 'pill-danger' };

/**
 * Pagos por transferencia que reportaron los clientes. Rtres revisa la constancia contra su banco y confirma (se registra
 * el cobro y el producto se activa o renueva) o rechaza con un motivo que le llega al cliente por correo.
 */
@Component({
  selector: 'app-transfer-reports',
  standalone: true,
  imports: [CommonModule, FormsModule, MoneyPipe, ...SORTABLE],
  template: `
    <h1 class="font-display text-2xl font-semibold">Pagos por confirmar</h1>
    <p class="text-sm text-muted mt-1 max-w-2xl">Transferencias que reportaron tus clientes. Verifica el abono en tu banco antes de confirmar: al hacerlo se registra el pago, se emite el comprobante y el producto se activa o renueva.</p>

    <div class="flex flex-wrap items-end justify-between gap-4 mt-6">
      <div class="card p-5 min-w-[220px]"><p class="stat-label">Por confirmar</p><p class="stat-value mt-2">{{ pendingCount() }}</p></div>
      <div class="flex gap-1" role="tablist" aria-label="Filtrar por estado">
        <button *ngFor="let f of filters" type="button" role="tab" class="btn btn-sm" [class.btn-primary]="status() === f.value" [class.btn-ghost]="status() !== f.value" [attr.aria-selected]="status() === f.value" (click)="setStatus(f.value)">{{ f.label }}</button>
      </div>
    </div>

    <div class="card mt-4 overflow-x-auto">
      <table class="p-table w-full" appSort #s="appSort" *ngIf="items().length; else empty">
        <thead><tr><th sortKey="createdAt">Reportado</th><th sortKey="company">Cliente</th><th sortKey="product">Producto</th><th class="num" sortKey="amount">Monto</th><th sortKey="account">Cuenta</th><th sortKey="operationNumber">N° operación</th><th sortKey="status">Estado</th></tr></thead>
        <tbody>
          <tr *ngFor="let r of items() | sortBy:s.key():s.dir()" class="cursor-pointer" (click)="open(r)">
            <td class="whitespace-nowrap">{{ r.createdAt | date:'dd/MM/yyyy HH:mm' }}<span class="block text-xs text-muted">pagó el {{ r.paidAt | date:'dd/MM/yyyy' }}</span></td>
            <td class="font-medium">{{ r.company }}</td>
            <td>{{ r.domainName || r.product }}<span *ngIf="r.years > 1" class="block text-xs text-muted">{{ r.years }} años</span></td>
            <td class="num font-medium">{{ r.amount | money:r.currency }}</td>
            <td class="text-sm">{{ r.account || '—' }}</td>
            <td class="tabular-nums">{{ r.operationNumber || '—' }}<span *ngIf="r.hasReceipt" class="block text-xs text-muted">con constancia</span></td>
            <td><span class="pill" [ngClass]="pill(r.status)">{{ label(r.status) }}</span></td>
          </tr>
        </tbody>
      </table>
      <ng-template #empty><p class="p-6 text-muted">{{ status() === 'Pendiente' ? 'No hay pagos por confirmar.' : 'No hay pagos en este filtro.' }}</p></ng-template>
    </div>

    <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4 overflow-y-auto" *ngIf="selected() as r">
      <section class="card p-6 w-full max-w-3xl my-8" role="dialog" aria-modal="true" aria-label="Revisar pago">
        <div class="flex flex-wrap items-start justify-between gap-3">
          <div><h2 class="font-display text-xl">{{ r.company }}</h2><p class="text-sm text-muted">{{ r.domainName || r.product }}{{ r.years > 1 ? ' · ' + r.years + ' años' : '' }}</p></div>
          <span class="pill" [ngClass]="pill(r.status)">{{ label(r.status) }}</span>
        </div>

        <div class="grid gap-6 mt-5 md:grid-cols-2">
          <div>
            <p class="stat-label">Constancia</p>
            <div class="mt-2 rounded-lg border min-h-[160px] grid place-items-center overflow-hidden bg-[var(--neutral-bg)]">
              <img *ngIf="receiptUrl() && isImage(r)" [src]="receiptUrl()" alt="Constancia de transferencia" class="max-h-[420px] w-full object-contain">
              <a *ngIf="receiptUrl() && !isImage(r)" [href]="receiptUrl()" target="_blank" rel="noopener" class="btn btn-ghost btn-sm">Abrir PDF</a>
              <p *ngIf="!r.hasReceipt" class="text-sm text-muted p-4 text-center">El cliente no subió constancia; revisa el N° de operación.</p>
              <p *ngIf="r.hasReceipt && !receiptUrl()" class="text-sm text-muted">Cargando…</p>
            </div>
            <a *ngIf="receiptUrl() && isImage(r)" [href]="receiptUrl()" target="_blank" rel="noopener" class="text-xs underline mt-1 inline-block">Ver en tamaño completo</a>
          </div>

          <div class="text-sm">
            <p class="stat-label">Reportado por el cliente</p>
            <p class="font-display text-3xl font-semibold tabular-nums mt-2">{{ r.amount | money:r.currency }}</p>
            <dl class="mt-3 divide-y">
              <div class="flex justify-between gap-3 py-2"><dt class="text-muted">Cuenta</dt><dd class="text-right">{{ r.account || '—' }}</dd></div>
              <div class="flex justify-between gap-3 py-2"><dt class="text-muted">Fecha de pago</dt><dd>{{ r.paidAt | date:'dd/MM/yyyy' }}</dd></div>
              <div class="flex justify-between gap-3 py-2"><dt class="text-muted">N° de operación</dt><dd class="tabular-nums">{{ r.operationNumber || '—' }}</dd></div>
              <div *ngIf="r.currency !== r.productCurrency" class="py-2 text-xs text-muted">El producto está en {{ r.productCurrency }}: pagó en otra moneda.</div>
              <div *ngIf="r.rejectionReason" class="py-2"><dt class="text-muted">Motivo del rechazo</dt><dd class="mt-1">{{ r.rejectionReason }}</dd></div>
            </dl>

            <form *ngIf="r.status === 'Pendiente' && mode === 'approve'" class="mt-4 space-y-3 rounded-lg border p-3" (ngSubmit)="approve(r)">
              <p class="font-semibold">Confirmar con lo que ves en tu banco</p>
              <div class="grid gap-3 grid-cols-2">
                <label class="field-label">Monto recibido ({{ r.currency }})<input class="field tabular-nums" type="number" min="0.01" step="0.01" [(ngModel)]="amount" name="amount" required></label>
                <label class="field-label">Fecha<input class="field" type="date" [(ngModel)]="paidAt" name="paidAt" required></label>
              </div>
              <label class="field-label">N° de operación<input class="field" [(ngModel)]="operationNumber" name="operation" maxlength="60"></label>
              <div class="flex gap-2"><button class="btn btn-primary btn-sm" [disabled]="busy()">{{ busy() ? 'Confirmando…' : 'Confirmar pago' }}</button><button type="button" class="btn btn-ghost btn-sm" (click)="mode=null">Volver</button></div>
            </form>
            <form *ngIf="r.status === 'Pendiente' && mode === 'reject'" class="mt-4 space-y-3 rounded-lg border p-3" (ngSubmit)="reject(r)">
              <label class="field-label">Motivo (le llega al cliente por correo)<textarea class="field" rows="3" [(ngModel)]="reason" name="reason" maxlength="500" required placeholder="Ej.: no encontramos el abono en la cuenta; el monto no coincide."></textarea></label>
              <div class="flex gap-2"><button class="btn btn-primary btn-sm" [disabled]="busy()">{{ busy() ? 'Enviando…' : 'Rechazar y avisar' }}</button><button type="button" class="btn btn-ghost btn-sm" (click)="mode=null">Volver</button></div>
            </form>
            <p *ngIf="error()" class="text-sm text-red-600 mt-3">{{ error() }}</p>
          </div>
        </div>

        <div class="flex flex-wrap justify-end gap-2 mt-6 pt-4 border-t">
          <ng-container *ngIf="r.status === 'Pendiente' && !mode">
            <button class="btn btn-ghost btn-sm" (click)="mode='reject';error.set('')">Rechazar</button>
            <button class="btn btn-primary btn-sm" (click)="mode='approve';error.set('')">Confirmar pago</button>
          </ng-container>
          <button class="btn btn-ghost btn-sm" (click)="close()">Cerrar</button>
        </div>
      </section>
    </div>
  `,
})
export class TransferReportsComponent implements OnInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  readonly filters: { value: TransferReportStatus | null; label: string }[] = [
    { value: 'Pendiente', label: 'Por confirmar' }, { value: 'Aprobado', label: 'Confirmados' }, { value: 'Rechazado', label: 'Rechazados' }, { value: null, label: 'Todos' },
  ];
  status = signal<TransferReportStatus | null>('Pendiente');
  items = signal<TransferReportDto[]>([]);
  pendingCount = signal(0);
  selected = signal<TransferReportDto | null>(null);
  receiptUrl = signal<string | null>(null);
  mode: 'approve' | 'reject' | null = null;
  amount: number | null = null; paidAt = ''; operationNumber = ''; reason = '';
  busy = signal(false); error = signal('');

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Pagos por confirmar' }); this.load(); }
  ngOnDestroy() { this.revokeReceipt(); }

  load() {
    this.api.getTransferReports(this.status() ?? undefined).subscribe(x => this.items.set(x));
    this.api.getTransferReports('Pendiente').subscribe(x => this.pendingCount.set(x.length));
  }
  setStatus(value: TransferReportStatus | null) { this.status.set(value); this.load(); }
  label(s: TransferReportStatus) { return STATUS_LABEL[s]; }
  pill(s: TransferReportStatus) { return STATUS_PILL[s]; }
  isImage(r: TransferReportDto) { return !!r.receiptContentType?.startsWith('image/'); }

  open(r: TransferReportDto) {
    this.selected.set(r); this.mode = null; this.error.set(''); this.reason = '';
    this.amount = r.amount; this.paidAt = r.paidAt; this.operationNumber = r.operationNumber ?? '';
    this.revokeReceipt();
    // La constancia va con el token (interceptor): se pide como blob y se muestra con una URL local.
    if (r.hasReceipt) this.api.getTransferReceipt(r.id).subscribe({ next: blob => this.receiptUrl.set(URL.createObjectURL(blob)), error: () => this.error.set('No se pudo cargar la constancia.') });
  }
  close() { this.selected.set(null); this.revokeReceipt(); }
  private revokeReceipt() { const url = this.receiptUrl(); if (url) URL.revokeObjectURL(url); this.receiptUrl.set(null); }

  approve(r: TransferReportDto) {
    if (!this.amount || this.amount <= 0) { this.error.set('Indica el monto recibido.'); return; }
    this.busy.set(true); this.error.set('');
    this.api.approveTransfer(r.id, { amount: this.amount, paidAt: this.paidAt, operationNumber: this.operationNumber.trim() || undefined }).subscribe({
      next: () => { this.busy.set(false); this.close(); this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo confirmar el pago.'); },
    });
  }

  reject(r: TransferReportDto) {
    if (!this.reason.trim()) { this.error.set('Indica el motivo.'); return; }
    this.busy.set(true); this.error.set('');
    this.api.rejectTransfer(r.id, this.reason.trim()).subscribe({
      next: () => { this.busy.set(false); this.close(); this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo rechazar el pago.'); },
    });
  }
}
