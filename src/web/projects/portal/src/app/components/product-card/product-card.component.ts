import { formatMoney } from '../../core/money.pipe';
import { isSubscriptionCycle } from '../../core/enum-labels';
import { Component, Input, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { BankTransferInfo, ClientProductApiDto, PREPAID_YEARS, PortalApiService } from '../../core/portal-api.service';
import { ConfirmDialogComponent } from '../confirm-dialog/confirm-dialog.component';
import { BankTransferInfoComponent } from '../bank-transfer-info/bank-transfer-info.component';

const RENEWAL_WINDOW_DAYS = 30;

const CYCLE_SUFFIX: Record<string, string> = { Mensual: ' / mes', Bimestral: ' / 2 meses', Trimestral: ' / 3 meses', Semestral: ' / 6 meses', Anual: ' / año', Unico: ' · pago único' };

const TYPE_LABELS: Record<string, string> = {
  Hosting: 'Hosting',
  Dominio: 'Dominio',
  Ssl: 'SSL',
  BackupBd: 'Backup BD',
  SoporteMensual: 'Soporte mensual',
  DesarrolloWeb: 'Desarrollo web',
};

const STATUS_LABELS: Record<string, string> = {
  Activo: 'Activo',
  PorVencer: 'Por vencer',
  Vencido: 'Vencido',
  Cancelado: 'Cancelado',
  Pendiente: 'Pendiente de pago',
};

const STATUS_PILL_CLASS: Record<string, string> = {
  Activo: 'pill-success',
  PorVencer: 'pill-warn',
  Vencido: 'pill-danger',
  Cancelado: 'pill-neutral',
  Pendiente: 'pill-warn',
};

/** Mismo criterio que el backend (ClientProductPricing): catálogo, o precio propio si el producto no tiene precio de catálogo. */
const listPrice = (p: ClientProductApiDto) => p.product.basePrice ?? p.price;
/** Fecha de fin del descuento; el año 9999 es "sin fecha" (periodo sin vencimiento). */
const endDate = (value: string | null | undefined) => value && !value.startsWith('9999') ? new Date(value) : null;
const discountActive = (p: ClientProductApiDto) => !!p.discount && (!p.discountEndsAt || p.discountEndsAt.startsWith('9999') || new Date(p.discountEndsAt).getTime() > Date.now());
/** Los precios son sin IGV: a los clientes en Perú con Factura se les suma al cobrar. */
const igvSuffix = (p: ClientProductApiDto) => p.appliedIgvRate ? ' + IGV' : '';
const currentPrice = (p: ClientProductApiDto) => { const list = listPrice(p); return list == null ? null : list - (discountActive(p) ? p.discount! : 0); };

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule, ConfirmDialogComponent, BankTransferInfoComponent],
  template: `<article class="card p-6">
    <p class="text-muted text-sm">{{ typeLabel() }}</p>
    <h3 class="font-display text-lg font-semibold mt-2">{{ displayName() }}</h3>
    <span class="pill mt-4" [class]="pillClass()">{{ statusLabel() }}</span>
    <p class="mt-4 font-display text-lg font-semibold">{{ priceLabel() }}</p>
    <p *ngIf="discountLabel()" class="mt-1 text-sm text-muted">{{ discountLabel() }}</p>
    <p *ngIf="dateLabel()" class="mt-1 text-sm text-muted">{{ dateLabel() }}</p>
    <p *ngIf="error" class="text-sm text-red-600 mt-3">{{ error }}</p>
    <label *ngIf="product.billingCycle === 'Anual' && (canPay() || canRenew() || canPayByTransfer())" class="field-label mt-5">Años a pagar<select class="field" [value]="years" (change)="setYears(+$any($event.target).value)"><option *ngFor="let y of yearOptions" [value]="y" [selected]="y === years">{{ y === 1 ? '1 año' : y + ' años por adelantado' }}</option></select></label>
    <div *ngIf="canPayByTransfer()" class="mt-5"><button *ngIf="!transferInfo" class="btn btn-primary btn-sm" [disabled]="busy" (click)="showTransfer()">{{ product.status === 'Pendiente' ? 'Cómo pagar' : 'Pagar renovación' }}</button><app-bank-transfer-info *ngIf="transferInfo" [info]="transferInfo"/></div>
    <div *ngIf="canPay() || canRenew() || canCancel()" class="flex gap-2 mt-5"><button *ngIf="canPay()" class="btn btn-primary btn-sm" [disabled]="busy" (click)="completePayment()">{{ busy ? 'Verificando…' : 'Completar pago' }}</button><button *ngIf="canRenew()" class="btn btn-primary btn-sm" (click)="renew()">Pagar renovación</button><button *ngIf="canCancel()" class="btn btn-ghost btn-sm" (click)="confirmingCancel=true;cancelError=''">Cancelar suscripción</button></div>
  </article>
  <app-confirm-dialog *ngIf="confirmingCancel" title="Cancelar suscripción" [message]="'Se cancelará la suscripción de ' + displayName() + ' en PayPal y no habrá más cobros. Esta acción no se puede deshacer.'" confirmLabel="Sí, cancelar suscripción" busyLabel="Cancelando…" [danger]="true" [busy]="cancelling" [error]="cancelError" (confirmed)="cancel()" (cancelled)="confirmingCancel=false"/>`,
})
export class ProductCardComponent {
  private api = inject(PortalApiService);
  @Input({ required: true }) product!: ClientProductApiDto;

  displayName = computed(() => this.product.domainName || this.product.product.name);
  typeLabel = computed(() => TYPE_LABELS[this.product.product.type] ?? this.product.product.type);
  statusLabel = computed(() => STATUS_LABELS[this.product.status] ?? this.product.status);
  pillClass = computed(() => STATUS_PILL_CLASS[this.product.status] ?? 'pill-neutral');
  /** Anual/Único que vence en 30 días o menos (o ya vencido): se puede pagar la renovación. Mismo criterio que el backend. */
  canRenew = computed(() => {
    const p = this.product;
    if (p.isManualBilling || !(p.billingCycle === 'Anual' || p.billingCycle === 'Unico')) return false;
    if (p.status === 'PorVencer' || p.status === 'Vencido') return true;
    return p.status === 'Activo' && !!p.renewsAt && new Date(p.renewsAt).getTime() - Date.now() <= RENEWAL_WINDOW_DAYS * 86_400_000;
  });
  priceLabel = computed(() => {
    const p = this.product;
    if (p.priceLabelOverride) return p.priceLabelOverride;
    const amount = currentPrice(p);
    if (amount == null) return '';
    const money = formatMoney(amount, p.product.currency || 'USD');
    return `${money}${igvSuffix(p)}${CYCLE_SUFFIX[p.billingCycle] ?? ''}`;
  });
  /** Precio especial del periodo actual: se avisa que la renovación va a precio de catálogo. */
  discountLabel = computed(() => {
    const p = this.product, list = listPrice(p);
    if (!discountActive(p) || list == null) return '';
    const money = formatMoney(list, p.product.currency || 'USD');
    const end = endDate(p.discountEndsAt);
    return end ? `Precio especial hasta el ${end.toLocaleDateString('es-PE')}; luego ${money}${igvSuffix(p)}.` : `Precio especial (catálogo: ${money}${igvSuffix(p)}).`;
  });
  canCancel = computed(() => !this.product.isManualBilling && this.product.status === 'Activo' && isSubscriptionCycle(this.product.billingCycle) && !!this.product.payPalSubscriptionId);
  canPay = computed(() => !this.product.isManualBilling && this.product.status === 'Pendiente');
  /** Pago por transferencia: pendiente o por renovar (Anual/Único dentro de los 30 días, o Mensual por cobrar). Lo confirma Rtres. */
  canPayByTransfer = computed(() => {
    const p = this.product;
    if (!p.isManualBilling || p.status === 'Cancelado') return false;
    if (p.status === 'Pendiente' || p.status === 'PorVencer' || p.status === 'Vencido') return true;
    const due = isSubscriptionCycle(p.billingCycle) ? p.nextChargeAt : p.renewsAt;
    return !!due && new Date(due).getTime() - Date.now() <= RENEWAL_WINDOW_DAYS * 86_400_000;
  });
  transferInfo: BankTransferInfo | null = null;
  /** Productos anuales: se pueden pagar varios años de una vez (una sola orden o transferencia por el total). */
  years = 1; yearOptions = PREPAID_YEARS;
  setYears(years: number){this.years=years;if(this.transferInfo)this.showTransfer();}
  showTransfer(){this.busy=true;this.error='';this.api.getBankTransfer(this.product.id,this.years).subscribe({next:x=>{this.busy=false;this.transferInfo=x;},error:e=>{this.busy=false;this.error=e?.error?.message??'No se pudieron cargar los datos de pago.';}});}
  busy = false;
  error = '';
  renew(){this.api.renewProduct(this.product.id,this.years).subscribe({next:r=>location.assign(r.approvalUrl),error:e=>this.error=e?.error?.message??'No se pudo iniciar el pago.'});}
  /** Pago que quedó a medias: primero intenta confirmarlo (ya aprobado en PayPal); si no, inicia un pago nuevo. */
  completePayment(){this.busy=true;this.error='';this.api.captureClientProduct(this.product.id).subscribe({next:r=>{if(r.status==='Activo'){location.reload();return;}this.renew();},error:()=>this.renew()});}
  confirmingCancel = false;
  cancelling = false;
  cancelError = '';
  cancel(){this.cancelling=true;this.cancelError='';this.api.cancelProduct(this.product.id).subscribe({next:()=>location.reload(),error:e=>{this.cancelling=false;this.cancelError=e?.error?.message??'No se pudo cancelar la suscripción.';}});}
  dateLabel = computed(() => {
    const p = this.product;
    if (p.renewsAt) return `Renueva el ${this.formatDate(p.renewsAt)}`;
    if (p.nextChargeAt) return `Próximo cobro: ${this.formatDate(p.nextChargeAt)}`;
    if (p.lastBackupAt) return `Último backup: ${this.formatDateTime(p.lastBackupAt)}`;
    return '';
  });

  private formatDate(iso: string): string {
    return new Date(iso).toLocaleDateString('es-PE', { day: 'numeric', month: 'short', year: 'numeric' });
  }
  private formatDateTime(iso: string): string {
    return new Date(iso).toLocaleString('es-PE', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });
  }
}
