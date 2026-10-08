import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { BankAccountDto, BankAccountRequest, PortalApiService } from '../../core/portal-api.service';
import { PaymentMethodsService } from '../../core/payment-methods.service';
import { SORTABLE } from '../../core/sortable';
import { ConfirmDialogComponent } from '../confirm-dialog/confirm-dialog.component';

const CURRENCY_NAMES: Record<string, string> = { PEN: 'Soles', USD: 'Dólares', EUR: 'Euros' };

/** Configuración → Medios de pago: activar o pausar PayPal y la transferencia, y las cuentas bancarias que ven los clientes. */
@Component({
  selector: 'app-payment-settings',
  standalone: true,
  imports: [CommonModule, FormsModule, ConfirmDialogComponent, ...SORTABLE],
  template: `
    <div class="grid gap-4 mt-4 md:grid-cols-2 max-w-3xl">
      <label class="card p-5 flex items-start gap-3 cursor-pointer">
        <input type="checkbox" class="mt-1" [checked]="methods().bankTransfer" [disabled]="saving()" (change)="toggle('bankTransfer', $any($event.target))">
        <span><span class="font-semibold">Transferencia bancaria</span><span class="block text-sm text-muted mt-1">El cliente transfiere a una de tus cuentas y reporta el pago; tú lo confirmas en Pagos por confirmar.</span></span>
      </label>
      <label class="card p-5 flex items-start gap-3 cursor-pointer">
        <input type="checkbox" class="mt-1" [checked]="methods().payPal" [disabled]="saving()" (change)="toggle('payPal', $any($event.target))">
        <span><span class="font-semibold">PayPal</span><span class="block text-sm text-muted mt-1">Pago con tarjeta o cuenta PayPal, activación inmediata. Las suscripciones ya activas siguen cobrándose.</span></span>
      </label>
    </div>
    <p *ngIf="settingsError()" class="text-sm text-red-600 mt-2">{{ settingsError() }}</p>

    <div class="flex flex-wrap items-end justify-between gap-3 mt-8 max-w-5xl">
      <div><h3 class="font-display text-base font-semibold">Cuentas bancarias</h3><p class="text-sm text-muted mt-1">Las activas se muestran al cliente, primero las de la moneda del producto.</p></div>
      <button class="btn btn-primary btn-sm" (click)="openNew()">Agregar cuenta</button>
    </div>
    <div class="card mt-3 overflow-x-auto max-w-5xl">
      <table class="p-table w-full" appSort #s="appSort" *ngIf="accounts().length; else empty">
        <thead><tr><th sortKey="bankName">Banco</th><th sortKey="currency">Moneda</th><th sortKey="type">Tipo</th><th sortKey="accountNumber">N° de cuenta</th><th sortKey="cci">CCI</th><th sortKey="isActive">Estado</th></tr></thead>
        <tbody>
          <tr *ngFor="let a of accounts() | sortBy:s.key():s.dir()" (click)="edit(a)" class="cursor-pointer">
            <td><span class="font-medium">{{ a.bankName }}</span><span class="block text-xs text-muted">{{ a.holder }}</span></td>
            <td>{{ currencyName(a.currency) }}</td>
            <td>{{ a.type === 'Corriente' ? 'Corriente' : 'Ahorros' }}</td>
            <td class="tabular-nums">{{ a.accountNumber }}</td>
            <td class="tabular-nums">{{ a.cci || '—' }}</td>
            <td><span class="pill" [ngClass]="a.isActive ? 'pill-success' : 'pill-neutral'">{{ a.isActive ? 'Activa' : 'Inactiva' }}</span></td>
          </tr>
        </tbody>
      </table>
      <ng-template #empty><p class="p-6 text-muted">Aún no hay cuentas. Agrega al menos una para que los clientes puedan pagar por transferencia.</p></ng-template>
    </div>

    <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4 overflow-y-auto" *ngIf="form">
      <form class="card p-6 w-full max-w-lg space-y-3 my-8" role="dialog" aria-modal="true" [attr.aria-label]="editingId ? 'Editar cuenta' : 'Agregar cuenta'" (ngSubmit)="save()">
        <h2 class="font-display text-xl">{{ editingId ? 'Editar cuenta' : 'Agregar cuenta' }}</h2>
        <div class="grid gap-3 sm:grid-cols-2">
          <label class="field-label">Banco<input class="field" [(ngModel)]="form.bankName" name="bank" maxlength="100" required placeholder="BCP, Interbank, BBVA…"></label>
          <label class="field-label">Moneda<select class="field" [(ngModel)]="form.currency" name="currency"><option value="PEN">Soles (PEN)</option><option value="USD">Dólares (USD)</option><option value="EUR">Euros (EUR)</option></select></label>
        </div>
        <label class="field-label">Titular<input class="field" [(ngModel)]="form.holder" name="holder" maxlength="200" required placeholder="Razón social que verá el cliente"></label>
        <label class="field-label">Tipo de cuenta<select class="field" [(ngModel)]="form.type" name="type"><option value="Ahorros">Ahorros</option><option value="Corriente">Corriente</option></select></label>
        <label class="field-label">Número de cuenta<input class="field tabular-nums" [(ngModel)]="form.accountNumber" name="number" maxlength="50" required></label>
        <label class="field-label">CCI (interbancario)<input class="field tabular-nums" [(ngModel)]="form.cci" name="cci" maxlength="30" placeholder="20 dígitos"></label>
        <label class="flex items-center gap-2 text-sm"><input type="checkbox" [(ngModel)]="form.isActive" name="active"> Visible para los clientes</label>
        <p *ngIf="formError()" class="text-sm text-red-600">{{ formError() }}</p>
        <div class="flex flex-wrap justify-between gap-2 pt-2">
          <button *ngIf="editingId" type="button" class="btn btn-ghost btn-sm text-red-600" (click)="confirmingDelete=true">Eliminar</button>
          <span class="flex gap-2 ml-auto"><button type="button" class="btn btn-ghost btn-sm" (click)="form=null">Cancelar</button><button class="btn btn-primary btn-sm" [disabled]="saving()">Guardar</button></span>
        </div>
      </form>
    </div>
    <app-confirm-dialog *ngIf="confirmingDelete" title="Eliminar cuenta" message="La cuenta dejará de mostrarse a los clientes. Si ya tiene pagos reportados, desactívala en lugar de eliminarla." confirmLabel="Eliminar" busyLabel="Eliminando…" [danger]="true" [busy]="saving()" [error]="deleteError" (confirmed)="remove()" (cancelled)="confirmingDelete=false"/>
  `,
})
export class PaymentSettingsComponent implements OnInit {
  private api = inject(PortalApiService);
  private payments = inject(PaymentMethodsService);
  methods = this.payments.methods;
  accounts = signal<BankAccountDto[]>([]);
  saving = signal(false); settingsError = signal(''); formError = signal('');
  form: BankAccountRequest | null = null; editingId: string | null = null;
  confirmingDelete = false; deleteError = '';

  ngOnInit() { this.payments.load(); this.loadAccounts(); }
  loadAccounts() { this.api.getBankAccounts().subscribe(x => this.accounts.set(x)); }
  currencyName(code: string) { return CURRENCY_NAMES[code] ?? code; }

  toggle(method: 'payPal' | 'bankTransfer', checkbox: HTMLInputElement) {
    const enabled = checkbox.checked;
    this.saving.set(true); this.settingsError.set('');
    this.api.updatePaymentSettings({ [method]: enabled }).subscribe({
      next: x => { this.saving.set(false); this.payments.set(x); },
      // El checkbox ya cambió en pantalla: se devuelve a su valor guardado.
      error: e => { this.saving.set(false); this.settingsError.set(e?.error?.message ?? 'No se pudo guardar.'); checkbox.checked = !enabled; },
    });
  }

  openNew() { this.editingId = null; this.formError.set(''); this.form = { bankName: '', holder: '', currency: 'PEN', type: 'Ahorros', accountNumber: '', cci: '', isActive: true }; }
  edit(a: BankAccountDto) { this.editingId = a.id; this.formError.set(''); this.form = { bankName: a.bankName, holder: a.holder, currency: a.currency, type: a.type, accountNumber: a.accountNumber, cci: a.cci ?? '', isActive: a.isActive }; }

  save() {
    if (!this.form) return;
    this.saving.set(true); this.formError.set('');
    const body = { ...this.form, cci: this.form.cci?.trim() || null };
    (this.editingId ? this.api.updateBankAccount(this.editingId, body) : this.api.createBankAccount(body)).subscribe({
      next: () => { this.saving.set(false); this.form = null; this.loadAccounts(); },
      error: e => { this.saving.set(false); this.formError.set(e?.error?.message ?? 'No se pudo guardar la cuenta.'); },
    });
  }

  remove() {
    if (!this.editingId) return;
    this.saving.set(true); this.deleteError = '';
    this.api.deleteBankAccount(this.editingId).subscribe({
      next: () => { this.saving.set(false); this.confirmingDelete = false; this.form = null; this.loadAccounts(); },
      error: e => { this.saving.set(false); this.deleteError = e?.error?.message ?? 'No se pudo eliminar la cuenta.'; },
    });
  }
}
