import { Component, EventEmitter, Input, OnInit, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BankTransferInfo, PortalApiService, TransferReportSummary } from '../../core/portal-api.service';

/** Mismos límites que BankTransfersController.Report. */
const MAX_RECEIPT_BYTES = 5 * 1024 * 1024;
const RECEIPT_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/heic', 'application/pdf'];

/**
 * "Ya transferí": el cliente indica a qué cuenta pagó, cuánto y cuándo, con el N° de operación y/o la foto o PDF de la
 * constancia. Rtres lo revisa y, al confirmarlo, el producto se activa o renueva.
 */
@Component({
  selector: 'app-transfer-report-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `<form class="rounded-lg border border-[var(--border)] p-4 space-y-3 text-sm" (ngSubmit)="submit()">
    <p class="font-semibold">Reportar mi transferencia</p>
    <label class="field-label">Cuenta a la que transferiste
      <select class="field" [(ngModel)]="accountId" name="account" (ngModelChange)="onAccount()" required>
        <option *ngFor="let a of info.accounts" [value]="a.id">{{ a.bankName }} · {{ a.currency }} · {{ a.accountNumber }}</option>
      </select>
    </label>
    <div class="grid gap-3 sm:grid-cols-2">
      <label class="field-label">Monto transferido ({{ currency }})<input class="field tabular-nums" type="number" min="0.01" step="0.01" [(ngModel)]="amount" name="amount" required></label>
      <label class="field-label">Fecha<input class="field" type="date" [(ngModel)]="paidAt" name="paidAt" [max]="today" required></label>
    </div>
    <label class="field-label">N° de operación<input class="field" [(ngModel)]="operationNumber" name="operation" maxlength="60" placeholder="Figura en la constancia de tu banco"></label>
    <div>
      <span class="field-label">Constancia (foto o PDF)</span>
      <label class="flex items-center justify-between gap-3 rounded-md border border-dashed px-3 py-3 mt-1 cursor-pointer">
        <span class="truncate" [class.text-muted]="!receipt()">{{ receipt()?.name ?? 'Elegir archivo o tomar foto' }}</span>
        <span class="btn btn-ghost btn-sm">{{ receipt() ? 'Cambiar' : 'Subir' }}</span>
        <input class="hidden" type="file" accept="image/*,application/pdf" (change)="onFile($event)">
      </label>
      <img *ngIf="preview()" [src]="preview()" alt="Vista previa de la constancia" class="mt-2 max-h-48 rounded-md border">
      <p class="text-xs text-muted mt-1">Indica el N° de operación, sube la constancia o ambos. Máximo 5 MB.</p>
    </div>
    <p *ngIf="error()" class="text-sm text-red-600">{{ error() }}</p>
    <div class="flex gap-2">
      <button class="btn btn-primary btn-sm" [disabled]="sending()">{{ sending() ? 'Enviando…' : 'Enviar para confirmación' }}</button>
      <button type="button" class="btn btn-ghost btn-sm" (click)="cancelled.emit()">Cancelar</button>
    </div>
  </form>`,
})
export class TransferReportFormComponent implements OnInit {
  private api = inject(PortalApiService);
  @Input({ required: true }) clientProductId!: string;
  @Input({ required: true }) info!: BankTransferInfo;
  @Input() years = 1;
  @Output() reported = new EventEmitter<TransferReportSummary>();
  @Output() cancelled = new EventEmitter<void>();

  readonly today = localDate(new Date());
  accountId = ''; amount: number | null = null; paidAt = this.today; operationNumber = '';
  receipt = signal<File | null>(null); preview = signal<string | null>(null);
  sending = signal(false); error = signal('');

  get currency() { return this.info.accounts?.find(a => a.id === this.accountId)?.currency ?? this.info.currency; }

  ngOnInit() { this.accountId = this.info.accounts?.[0]?.id ?? ''; this.onAccount(); }

  /** Propone el monto en la moneda de la cuenta elegida (exacto en la misma moneda; aproximado si es otra). */
  onAccount() {
    const account = this.info.accounts?.find(a => a.id === this.accountId);
    this.amount = account && account.currency !== this.info.currency ? account.approxAmount ?? null : this.info.amount;
  }

  onFile(event: Event) {
    const file = (event.target as HTMLInputElement).files?.[0] ?? null;
    (event.target as HTMLInputElement).value = '';
    if (!file) return;
    if (!RECEIPT_TYPES.includes(file.type)) { this.error.set('La constancia debe ser una imagen (JPG, PNG, WEBP) o un PDF.'); return; }
    if (file.size > MAX_RECEIPT_BYTES) { this.error.set('La constancia debe pesar como máximo 5 MB.'); return; }
    this.error.set(''); this.receipt.set(file);
    const old = this.preview(); if (old) URL.revokeObjectURL(old);
    this.preview.set(file.type.startsWith('image/') ? URL.createObjectURL(file) : null);
  }

  submit() {
    if (!this.operationNumber.trim() && !this.receipt()) { this.error.set('Indica el N° de operación o sube la constancia.'); return; }
    if (!this.amount || this.amount <= 0) { this.error.set('Indica el monto transferido.'); return; }
    this.sending.set(true); this.error.set('');
    this.api.reportTransfer(this.clientProductId, { bankAccountId: this.accountId, amount: this.amount, paidAt: this.paidAt, operationNumber: this.operationNumber.trim(), years: this.years }, this.receipt()).subscribe({
      next: r => { this.sending.set(false); this.reported.emit(r); },
      error: e => { this.sending.set(false); this.error.set(e?.error?.message ?? 'No se pudo enviar el reporte.'); },
    });
  }
}

/** yyyy-MM-dd en la zona del navegador (toISOString daría el día siguiente en la noche de Lima). */
function localDate(d: Date) { return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`; }
