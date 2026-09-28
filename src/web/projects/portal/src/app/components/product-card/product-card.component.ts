import { Component, Input, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClientProductApiDto, PortalApiService } from '../../core/portal-api.service';

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

@Component({
  selector: 'app-product-card',
  standalone: true,
  imports: [CommonModule],
  template: `<article class="card p-6">
    <p class="text-muted text-sm">{{ typeLabel() }}</p>
    <h3 class="font-display text-lg font-semibold mt-2">{{ displayName() }}</h3>
    <span class="pill mt-4" [class]="pillClass()">{{ statusLabel() }}</span>
    <p class="mt-4 text-sm">{{ dateLabel() }}</p>
    <p *ngIf="error" class="text-sm text-red-600 mt-3">{{ error }}</p>
    <div *ngIf="canPay() || canRenew() || canCancel()" class="flex gap-2 mt-5"><button *ngIf="canPay()" class="btn btn-primary btn-sm" [disabled]="busy" (click)="completePayment()">{{ busy ? 'Verificando…' : 'Completar pago' }}</button><button *ngIf="canRenew()" class="btn btn-primary btn-sm" (click)="renew()">Renovar ahora</button><button *ngIf="canCancel()" class="btn btn-ghost btn-sm" (click)="cancel()">Cancelar suscripción</button></div>
  </article>`,
})
export class ProductCardComponent {
  private api = inject(PortalApiService);
  @Input({ required: true }) product!: ClientProductApiDto;

  displayName = computed(() => this.product.domainName || this.product.product.name);
  typeLabel = computed(() => TYPE_LABELS[this.product.product.type] ?? this.product.product.type);
  statusLabel = computed(() => STATUS_LABELS[this.product.status] ?? this.product.status);
  pillClass = computed(() => STATUS_PILL_CLASS[this.product.status] ?? 'pill-neutral');
  canRenew = computed(() => !this.product.isManualBilling && (this.product.status === 'PorVencer' || this.product.status === 'Vencido') && (this.product.billingCycle === 'Anual' || this.product.billingCycle === 'Unico'));
  canCancel = computed(() => !this.product.isManualBilling && this.product.status === 'Activo' && this.product.billingCycle === 'Mensual' && !!this.product.payPalSubscriptionId);
  canPay = computed(() => !this.product.isManualBilling && this.product.status === 'Pendiente');
  busy = false;
  error = '';
  renew(){this.api.renewProduct(this.product.id).subscribe({next:r=>location.assign(r.approvalUrl),error:e=>this.error=e?.error?.message??'No se pudo iniciar el pago.'});}
  /** Pago que quedó a medias: primero intenta confirmarlo (ya aprobado en PayPal); si no, inicia un pago nuevo. */
  completePayment(){this.busy=true;this.error='';this.api.captureClientProduct(this.product.id).subscribe({next:r=>{if(r.status==='Activo'){location.reload();return;}this.renew();},error:()=>this.renew()});}
  cancel(){if(confirm('¿Cancelar esta suscripción?'))this.api.cancelProduct(this.product.id).subscribe(()=>location.reload());}
  dateLabel = computed(() => {
    const p = this.product;
    if (p.priceLabelOverride) return p.priceLabelOverride;
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
