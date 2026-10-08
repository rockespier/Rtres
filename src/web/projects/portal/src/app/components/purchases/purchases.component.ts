import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CategoryDto, ImportResult, OTHER_EXPENSE_CATEGORY_ID, PortalApiService, PurchaseDocumentType, PurchaseDto, PurchaseRequest, PurchasesPageDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { MoneyPipe } from '../../core/money.pipe';
import { SORTABLE } from '../../core/sortable';
import { PagerComponent } from '../pager/pager.component';
import { ImportDialogComponent } from '../import-dialog/import-dialog.component';

const DOC_TYPES: { value: PurchaseDocumentType; label: string }[] = [
  { value: 'Factura', label: 'Factura' },
  { value: 'NotaCredito', label: 'Nota de crédito' },
  { value: 'NotaDebito', label: 'Nota de débito' },
  { value: 'Boleta', label: 'Boleta de venta' },
  { value: 'ReciboPorHonorarios', label: 'Recibo por honorarios' },
  { value: 'Extranjero', label: 'Comprobante del exterior' },
  { value: 'Otro', label: 'Otro' },
];
/** Mismo criterio que Purchase.AllowsTaxCredit en el API. */
const CREDIT_TYPES: PurchaseDocumentType[] = ['Factura', 'NotaCredito', 'NotaDebito'];
const NO_IGV_TYPES: PurchaseDocumentType[] = ['Boleta', 'ReciboPorHonorarios'];

/** Registro de Compras: el IGV de las facturas de proveedores es crédito fiscal y reduce el IGV a pagar. */
@Component({
  selector: 'app-purchases',
  standalone: true,
  imports: [CommonModule, FormsModule, MoneyPipe, ...SORTABLE, PagerComponent, ImportDialogComponent],
  template: `
    <div class="flex flex-wrap justify-between items-end gap-3">
      <div>
        <h1 class="font-display text-2xl font-semibold">Compras</h1>
        <p class="text-sm text-muted mt-1 max-w-2xl">Facturas de proveedores con IGV: ese IGV es crédito fiscal y se resta del IGV de tus ventas en Reportes. Anota cada comprobante electrónico en el mes en que fue emitido.</p>
      </div>
      <div class="flex gap-2">
        <button class="btn btn-ghost btn-sm" (click)="importing=true">Importar Excel</button>
        <button class="btn btn-primary btn-sm" (click)="openNew()">Registrar compra</button>
      </div>
    </div>
    <p *ngIf="importError" class="text-sm text-red-600 mt-3">{{importError}}</p>

    <div class="flex gap-3 mt-4"><input class="field w-auto" type="month" [(ngModel)]="period" (ngModelChange)="load()" aria-label="Periodo de anotación"></div>

    <div class="grid gap-4 mt-4 md:grid-cols-3" *ngIf="page">
      <div class="card p-6"><p class="stat-label">Compras del periodo</p><p class="stat-value mt-2">{{page.totalPen|money}}</p><p class="text-xs text-muted mt-2">{{page.items.length}} {{page.items.length===1?'comprobante':'comprobantes'}} · en soles al tipo de cambio de cada fecha</p></div>
      <div class="card p-6"><p class="stat-label">Crédito fiscal</p><p class="stat-value mt-2">{{page.creditoFiscalPen|money}}</p><p class="text-xs text-muted mt-2">IGV que se resta del IGV de tus ventas</p></div>
      <div class="card p-6"><p class="stat-label">IGV sin crédito</p><p class="stat-value mt-2">{{page.igvSinCreditoPen|money}}</p><p class="text-xs text-muted mt-2">Compras no destinadas a ventas gravadas</p></div>
    </div>

    <div class="card mt-4 overflow-x-auto">
      <table class="p-table w-full" appSort="issueDate:desc" #s="appSort" *ngIf="page?.items?.length; else empty">
        <thead><tr><th sortKey="issueDate">Emisión</th><th sortKey="supplierName">Proveedor</th><th sortKey="documentType">Comprobante</th><th class="num" sortKey="taxBase">Base</th><th class="num" sortKey="igv">IGV</th><th class="num" sortKey="total">Total</th><th class="num" sortKey="taxCreditPen">Crédito fiscal</th></tr></thead>
        <tbody>
          <tr *ngFor="let x of (page!.items | sortBy:s.key():s.dir()) | slice:(pageIndex-1)*pageSize:pageIndex*pageSize" (click)="edit(x)">
            <td class="whitespace-nowrap">{{x.issueDate|date:'dd/MM/yyyy'}}</td>
            <td><span class="font-medium">{{x.supplierName}}</span><span class="block text-xs text-muted">{{x.supplierTaxId}}</span></td>
            <td class="whitespace-nowrap">{{label(x.documentType)}}<span class="block text-xs text-muted">{{x.series ? x.series + '-' : ''}}{{x.number}}</span></td>
            <td class="num">{{x.taxBase|money:x.currency}}</td>
            <td class="num">{{x.igv|money:x.currency}}<span *ngIf="x.igvWarning" class="block text-xs text-amber-700" title="El IGV no coincide con la tasa configurada sobre la base">revisar</span></td>
            <td class="num font-medium">{{x.total|money:x.currency}}</td>
            <td class="num">
              <span *ngIf="x.givesTaxCredit; else noCredit" class="font-medium">{{x.taxCreditPen|money}}</span>
              <ng-template #noCredit><span class="text-muted">—</span></ng-template>
              <span *ngIf="x.expenseId" class="block text-xs text-muted">con gasto</span>
            </td>
          </tr>
        </tbody>
        <tfoot><tr><td colspan="6">Crédito fiscal del periodo</td><td class="num">{{page!.creditoFiscalPen|money}}</td></tr></tfoot>
      </table>
      <ng-template #empty><p class="p-6 text-muted">No hay compras anotadas en este periodo.</p></ng-template>
    </div>
    <app-pager *ngIf="page" [total]="page.items.length" [page]="pageIndex" [pageSize]="pageSize" (pageChange)="pageIndex=$event"/>

    <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4 overflow-y-auto" *ngIf="form">
      <form class="card p-6 w-full max-w-2xl space-y-3 my-8" role="dialog" aria-modal="true" [attr.aria-label]="editingId ? 'Editar compra' : 'Registrar compra'" (ngSubmit)="save()">
        <h2 class="font-display text-xl">{{editingId ? 'Editar compra' : 'Registrar compra'}}</h2>
        <div class="grid gap-3 sm:grid-cols-3">
          <label class="field-label">Comprobante<select class="field" [(ngModel)]="form.documentType" name="documentType" (ngModelChange)="typeChanged()">
            <option *ngFor="let t of types" [ngValue]="t.value">{{t.label}}</option></select></label>
          <label class="field-label">Serie<input class="field uppercase" [(ngModel)]="form.series" name="series" maxlength="20" [placeholder]="foreign() ? 'Opcional' : 'F001'"></label>
          <label class="field-label">Número<input class="field" [(ngModel)]="form.number" name="number" maxlength="20" required></label>
        </div>
        <div class="grid gap-3 sm:grid-cols-[1fr_2fr]">
          <label class="field-label">{{foreign() ? 'Identificación' : 'RUC'}}<input class="field" [(ngModel)]="form.supplierTaxId" name="supplierTaxId" [attr.inputmode]="foreign() ? null : 'numeric'" [maxlength]="foreign() ? 20 : 11" required></label>
          <label class="field-label">Proveedor<input class="field" [(ngModel)]="form.supplierName" name="supplierName" maxlength="200" required></label>
        </div>
        <div class="grid gap-3 sm:grid-cols-3">
          <label class="field-label">Fecha de emisión<input class="field" type="date" [(ngModel)]="form.issueDate" name="issueDate" (ngModelChange)="form.period = null" required></label>
          <label class="field-label">Periodo de anotación<input class="field" type="month" [ngModel]="form.period ?? form.issueDate.slice(0,7)" (ngModelChange)="form.period = $event" name="period"></label>
          <label class="field-label">Moneda<select class="field" [(ngModel)]="form.currency" name="currency"><option value="PEN">S/ Soles</option><option value="USD">US$ Dólares</option><option value="EUR">€ Euros</option></select></label>
        </div>
        <div class="grid gap-3 sm:grid-cols-4">
          <label class="field-label">Base imponible<input class="field" type="number" step="0.01" min="0" [(ngModel)]="form.taxBase" name="taxBase" (ngModelChange)="baseChanged()"></label>
          <label class="field-label">IGV<input class="field" type="number" step="0.01" min="0" [(ngModel)]="form.igv" name="igv" [disabled]="noIgv()" (ngModelChange)="igvTouched = true"></label>
          <label class="field-label">Inafecto / exonerado<input class="field" type="number" step="0.01" min="0" [(ngModel)]="form.nonTaxable" name="nonTaxable"></label>
          <div class="field-label">Total<p class="field bg-[var(--neutral-bg)] font-semibold tabular-nums">{{total()|money:form.currency}}</p></div>
        </div>
        <p *ngIf="igvOff()" class="text-xs text-amber-700">El IGV no es {{igvRate*100}}% de la base. Revísalo contra el comprobante.</p>
        <label *ngIf="creditType()" class="flex items-start gap-2 text-sm"><input type="checkbox" class="mt-1" [(ngModel)]="form.usedForTaxedOperations" name="taxed">
          <span>La compra es para mis ventas gravadas <span class="block text-xs text-muted">Su IGV es crédito fiscal. Desmárcalo si es un gasto personal o para ventas al exterior.</span></span></label>
        <div *ngIf="form.documentType !== 'NotaCredito'" class="rounded-[var(--radius-sm)] border border-[var(--border)] p-3 space-y-2">
          <label class="flex items-center gap-2 text-sm"><input type="checkbox" [(ngModel)]="form.createExpense" name="createExpense" [disabled]="!!linkedExpense"> {{linkedExpense ? 'Tiene un gasto vinculado (se actualiza con la compra)' : 'Registrar también como gasto'}}</label>
          <label *ngIf="form.createExpense || linkedExpense" class="field-label">Categoría del gasto<select class="field" [(ngModel)]="form.expenseCategoryId" name="expenseCategoryId"><option *ngIf="linkedExpense" [ngValue]="null">Sin cambios</option><option *ngFor="let c of categories" [ngValue]="c.id">{{c.name}}</option></select></label>
          <p *ngIf="form.createExpense || linkedExpense" class="text-xs text-muted">Monto del gasto: {{expenseAmount()|money:form.currency}} {{gaveCredit() ? '(sin el IGV, que se recupera como crédito fiscal)' : '(total del comprobante)'}}</p>
        </div>
        <label class="field-label">Notas <span class="font-normal">(opcional)</span><input class="field" [(ngModel)]="form.notes" name="notes" maxlength="500"></label>
        <p *ngIf="error" class="text-sm text-red-600">{{error}}</p>
        <div *ngIf="deleting; else actions" class="rounded-[var(--radius-sm)] border border-[var(--danger-border)] bg-[var(--danger-bg)] p-4 text-sm space-y-3">
          <p>¿Eliminar el comprobante {{form.series ? form.series + '-' : ''}}{{form.number}} de {{form.supplierName}}?</p>
          <label *ngIf="linkedExpense" class="flex items-center gap-2"><input type="checkbox" [(ngModel)]="deleteExpense" name="deleteExpense"> Eliminar también el gasto vinculado</label>
          <div class="flex gap-2"><button type="button" class="btn btn-danger btn-sm" [disabled]="saving" (click)="remove()">Eliminar</button><button type="button" class="btn btn-ghost btn-sm" (click)="deleting=false">Volver</button></div>
        </div>
        <ng-template #actions><div class="flex gap-2">
          <button class="btn btn-primary btn-sm" [disabled]="saving">{{saving ? 'Guardando…' : 'Guardar'}}</button>
          <button type="button" class="btn btn-ghost btn-sm" (click)="form=null">Cancelar</button>
          <button *ngIf="editingId" type="button" class="btn btn-ghost btn-sm text-red-600 ml-auto" (click)="deleting=true">Eliminar</button>
        </div></ng-template>
      </form>
    </div>
    <app-import-dialog *ngIf="importing" label="compras" [result]="importResult" (upload)="upload($event)" (template)="downloadTemplate()" (close)="importing=false;importResult=null"/>
  `,
})
export class PurchasesComponent implements OnInit {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  readonly types = DOC_TYPES;
  period = new Date().toISOString().slice(0, 7);
  page: PurchasesPageDto | null = null;
  pageIndex = 1; readonly pageSize = 20;
  categories: CategoryDto[] = [];
  igvRate = 0.18;

  form: PurchaseRequest | null = null; editingId: string | null = null; linkedExpense: string | null = null;
  igvTouched = false; saving = false; deleting = false; deleteExpense = true; error: string | null = null;
  importing = false; importResult: ImportResult | null = null; importError: string | null = null;

  ngOnInit() {
    this.ui.breadcrumb.set({ current: 'Compras' });
    this.api.getCategories('expense').subscribe(x => this.categories = x);
    this.api.getTaxSettings().subscribe(x => this.igvRate = x.igvRate);
    this.load();
  }

  load() {
    const [year, month] = this.period.split('-').map(Number);
    this.pageIndex = 1;
    this.api.getPurchases(year, month).subscribe(x => this.page = x);
  }

  label(type: PurchaseDocumentType) { return DOC_TYPES.find(t => t.value === type)?.label ?? type; }
  foreign() { return this.form?.documentType === 'Extranjero' || this.form?.documentType === 'Otro'; }
  creditType() { return !!this.form && CREDIT_TYPES.includes(this.form.documentType); }
  noIgv() { return !!this.form && NO_IGV_TYPES.includes(this.form.documentType); }
  total() { const f = this.form; return f ? round((f.taxBase || 0) + (f.igv || 0) + (f.nonTaxable || 0)) : 0; }
  gaveCredit() { const f = this.form; return !!f && this.creditType() && f.usedForTaxedOperations && (f.igv || 0) > 0; }
  expenseAmount() { const f = this.form; return f ? (this.gaveCredit() ? round((f.taxBase || 0) + (f.nonTaxable || 0)) : this.total()) : 0; }
  igvOff() { const f = this.form; return !!f && (f.igv || 0) > 0 && Math.abs((f.igv || 0) - (f.taxBase || 0) * this.igvRate) > 1; }

  /** Mientras no se edite a mano, el IGV se calcula con la tasa configurada. */
  baseChanged() { if (this.form && !this.igvTouched && !this.noIgv() && this.form.documentType !== 'Extranjero') this.form.igv = round((this.form.taxBase || 0) * this.igvRate); }
  typeChanged() {
    if (!this.form) return;
    if (this.noIgv() || this.form.documentType === 'Extranjero') this.form.igv = 0; else this.baseChanged();
    if (this.form.documentType === 'NotaCredito') this.form.createExpense = false;
  }

  openNew() {
    this.editingId = null; this.linkedExpense = null; this.igvTouched = false; this.deleting = false; this.error = null;
    this.form = { issueDate: new Date().toLocaleDateString('sv-SE'), period: null, documentType: 'Factura', series: '', number: '', supplierTaxId: '', supplierName: '', currency: 'PEN', taxBase: 0, igv: 0, nonTaxable: 0, usedForTaxedOperations: true, createExpense: true, expenseCategoryId: OTHER_EXPENSE_CATEGORY_ID, notes: null };
  }

  edit(x: PurchaseDto) {
    this.editingId = x.id; this.linkedExpense = x.expenseId; this.igvTouched = true; this.deleting = false; this.deleteExpense = true; this.error = null;
    this.form = { issueDate: x.issueDate.slice(0, 10), period: x.period, documentType: x.documentType, series: x.series, number: x.number, supplierTaxId: x.supplierTaxId, supplierName: x.supplierName, currency: x.currency, taxBase: x.taxBase, igv: x.igv, nonTaxable: x.nonTaxable, usedForTaxedOperations: x.givesTaxCredit || !CREDIT_TYPES.includes(x.documentType) || x.igv === 0, createExpense: false, expenseCategoryId: null, notes: x.notes };
  }

  save() {
    if (!this.form) return;
    this.saving = true; this.error = null;
    this.api.savePurchase(this.editingId, this.form).subscribe({
      next: () => { this.saving = false; this.form = null; this.load(); },
      error: e => { this.saving = false; this.error = e?.error?.message ?? 'No se pudo guardar la compra.'; },
    });
  }

  remove() {
    if (!this.editingId) return;
    this.saving = true;
    this.api.deletePurchase(this.editingId, this.deleteExpense).subscribe({
      next: () => { this.saving = false; this.form = null; this.load(); },
      error: e => { this.saving = false; this.error = e?.error?.message ?? 'No se pudo eliminar la compra.'; },
    });
  }

  upload(file: File) {
    this.importError = null;
    this.api.importPurchases(file).subscribe({
      next: x => { this.importResult = x; this.load(); },
      error: e => { this.importing = false; this.importError = e?.error?.message ?? 'No se pudo importar el archivo.'; },
    });
  }

  downloadTemplate() { this.api.purchaseTemplate().subscribe(b => { const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = 'compras-plantilla.xlsx'; a.click(); URL.revokeObjectURL(a.href); }); }
}

function round(n: number) { return Math.round(n * 100) / 100; }
