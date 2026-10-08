import { Component, Input, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MoneyPipe } from '../../core/money.pipe';
import { BankTransferInfo } from '../../core/portal-api.service';

/** Datos para pagar por transferencia: el monto y las cuentas activas de Rtres (las de la moneda del producto primero). */
@Component({
  selector: 'app-bank-transfer-info',
  standalone: true,
  imports: [MoneyPipe, CommonModule],
  template: `<div class="rounded-lg border border-[var(--border)] p-4 text-sm">
    <p *ngIf="info.amount != null" class="stat-label">Monto a transferir{{ info.years && info.years > 1 ? ' por ' + info.years + ' años' : '' }}</p>
    <p *ngIf="info.amount != null" class="font-display text-2xl font-semibold tabular-nums mt-1">{{ info.amount | money:info.currency }}<span *ngIf="info.includesIgv" class="text-sm font-normal text-muted"> incluye IGV</span></p>

    <ul *ngIf="info.accounts?.length; else noAccounts" class="mt-4 divide-y border-t">
      <li *ngFor="let a of info.accounts" class="py-3">
        <div class="flex flex-wrap items-baseline justify-between gap-2">
          <span class="font-semibold">{{ a.bankName }} · {{ currencyName(a.currency) }}</span>
          <span class="pill" [class.pill-success]="a.currency === info.currency" [class.pill-neutral]="a.currency !== info.currency">{{ a.type === 'Corriente' ? 'Cuenta corriente' : 'Cuenta de ahorros' }}</span>
        </div>
        <p class="text-muted text-xs mt-0.5">Titular: {{ a.holder }}</p>
        <dl class="grid grid-cols-[auto_1fr_auto] gap-x-3 gap-y-1 mt-2 items-center">
          <dt class="text-muted">Cuenta</dt><dd class="tabular-nums font-medium break-all">{{ a.accountNumber }}</dd>
          <dd><button type="button" class="btn btn-ghost btn-sm" (click)="copy(a.accountNumber, a.id + 'n')">{{ copied() === a.id + 'n' ? 'Copiado' : 'Copiar' }}</button></dd>
          <ng-container *ngIf="a.cci">
            <dt class="text-muted">CCI</dt><dd class="tabular-nums font-medium break-all">{{ a.cci }}</dd>
            <dd><button type="button" class="btn btn-ghost btn-sm" (click)="copy(a.cci, a.id + 'c')">{{ copied() === a.id + 'c' ? 'Copiado' : 'Copiar' }}</button></dd>
          </ng-container>
        </dl>
        <p *ngIf="a.approxAmount != null" class="text-xs text-muted mt-1">Aprox. {{ a.approxAmount | money:a.currency }} al tipo de cambio de hoy; tu banco puede aplicar otro.</p>
      </li>
    </ul>
    <ng-template #noAccounts><p class="mt-3">Rtres te enviará los datos de la cuenta por correo.</p></ng-template>
    <p *ngIf="info.instructions" class="whitespace-pre-line text-muted mt-3">{{ info.instructions }}</p>
  </div>`,
})
export class BankTransferInfoComponent {
  @Input({ required: true }) info!: BankTransferInfo;
  copied = signal<string | null>(null);

  currencyName(code: string) { return ({ PEN: 'Soles', USD: 'Dólares', EUR: 'Euros' } as Record<string, string>)[code] ?? code; }

  copy(value: string, key: string) {
    navigator.clipboard?.writeText(value).then(() => { this.copied.set(key); setTimeout(() => this.copied() === key && this.copied.set(null), 2000); }, () => {});
  }
}
