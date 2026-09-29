import { Component, OnInit, inject } from '@angular/core'; import { CommonModule } from '@angular/common'; import { FormsModule } from '@angular/forms'; import { PortalApiService } from '../../core/portal-api.service'; import { PortalUiService } from '../../core/portal-ui.service';
@Component({selector:'app-tax-settings',standalone:true,imports:[CommonModule,FormsModule],template:`<h1 class="font-display text-2xl font-semibold">Configuración de tasas</h1><p class="text-muted mt-2 max-w-2xl">Estas tasas son configurables por ti — el sistema no valida tu régimen tributario real ante SUNAT, solo aplica la tasa configurada para estimar los reportes. Confirma con tu contador antes de declarar.</p><form class="card p-6 mt-6 max-w-md space-y-4" (ngSubmit)="save()"><label class="field-label">IGV (%)<input class="field" type="number" step="0.01" min="0" max="100" [(ngModel)]="igvPercent" name="igv" required></label><label class="field-label">Renta (%)<input class="field" type="number" step="0.01" min="0" max="100" [(ngModel)]="rentaPercent" name="renta" required></label><h2 class="font-display text-lg pt-2">Comprobantes</h2><p class="text-sm text-muted">Se numeran solos al registrar un pago de un cliente en Perú. El correlativo avanza de uno en uno por serie; si ya emitiste comprobantes en otro sistema, indica desde qué número continuar.</p><div class="flex gap-3"><label class="field-label flex-1">Serie de facturas<input class="field uppercase" [(ngModel)]="facturaSeries" name="facturaSeries" maxlength="4" required placeholder="F001"></label><label class="field-label flex-1">Próximo correlativo<input class="field" type="number" min="1" step="1" [(ngModel)]="facturaNextNumber" name="facturaNext" required></label></div><div class="flex gap-3"><label class="field-label flex-1">Serie de recibos por honorarios<input class="field uppercase" [(ngModel)]="reciboSeries" name="reciboSeries" maxlength="4" required placeholder="E001"></label><label class="field-label flex-1">Próximo correlativo<input class="field" type="number" min="1" step="1" [(ngModel)]="reciboNextNumber" name="reciboNext" required></label></div><p *ngIf="error" class="text-sm text-red-600">{{error}}</p><div class="flex items-center gap-3"><button class="btn btn-primary btn-sm" [disabled]="saving">Guardar</button><span *ngIf="saved" class="text-sm text-muted">Guardado.</span></div></form>`})
export class TaxSettingsComponent implements OnInit {
  api = inject(PortalApiService); ui = inject(PortalUiService);
  igvPercent = 18; rentaPercent = 10; facturaSeries = 'F001'; facturaNextNumber = 1; reciboSeries = 'E001'; reciboNextNumber = 1;
  saving = false; saved = false; error: string | null = null;
  ngOnInit() { this.ui.breadcrumb.set({ current: 'Configuración de tasas' }); this.api.getTaxSettings().subscribe(x => this.apply(x)); }
  save() {
    this.saving = true; this.saved = false; this.error = null;
    this.api.updateTaxSettings({ igvRate: this.igvPercent / 100, rentaRate: this.rentaPercent / 100, facturaSeries: this.facturaSeries, facturaNextNumber: this.facturaNextNumber, reciboSeries: this.reciboSeries, reciboNextNumber: this.reciboNextNumber }).subscribe({
      next: x => { this.apply(x); this.saving = false; this.saved = true; },
      error: e => { this.saving = false; this.error = e?.error?.message ?? 'No se pudo guardar.'; },
    });
  }
  private apply(x: { igvRate: number; rentaRate: number; facturaSeries: string; facturaNextNumber: number; reciboSeries: string; reciboNextNumber: number }) {
    this.igvPercent = x.igvRate * 100; this.rentaPercent = x.rentaRate * 100;
    this.facturaSeries = x.facturaSeries; this.facturaNextNumber = x.facturaNextNumber; this.reciboSeries = x.reciboSeries; this.reciboNextNumber = x.reciboNextNumber;
  }
}
