import { PagerComponent } from '../pager/pager.component';
import { SORTABLE } from '../../core/sortable';
import { MoneyPipe } from '../../core/money.pipe';
import { Component, OnInit, inject } from '@angular/core'; import { CommonModule } from '@angular/common'; import { FormsModule } from '@angular/forms'; import { ExpenseCategory, ExpenseDto, ExpenseType, ImportResult, PortalApiService } from '../../core/portal-api.service'; import { PortalUiService } from '../../core/portal-ui.service'; import { EnumLabelPipe } from '../../core/enum-labels'; import { ImportDialogComponent } from '../import-dialog/import-dialog.component';
@Component({selector:'app-expenses',standalone:true,imports:[PagerComponent,MoneyPipe,...SORTABLE,CommonModule,FormsModule,EnumLabelPipe,ImportDialogComponent],template:`<div class="flex justify-between gap-3"><h1 class="font-display text-2xl font-semibold">Gastos</h1><div class="flex gap-2"><button class="btn btn-ghost btn-sm" (click)="importing=true">Importar Excel</button><button class="btn btn-primary btn-sm" (click)="openNew()">Nuevo gasto</button></div></div><p *ngIf="importError" class="text-sm neg mt-3">{{importError}}</p><div class="flex gap-3 mt-4"><input class="field w-auto" type="month" [(ngModel)]="period" (ngModelChange)="load()" aria-label="Mes"><select class="field" [(ngModel)]="category" (ngModelChange)="load()"><option value="">Todas las categorías</option><option *ngFor="let c of categories" [value]="c">{{c | enumLabel:'expenseCategory'}}</option></select></div><div class="grid gap-4 mt-4 md:grid-cols-3"><div class="card p-6"><p class="stat-label">Total del periodo</p><p class="stat-value mt-2">{{total|money}}</p><p class="text-xs text-muted mt-2">{{items.length}} {{items.length===1?'gasto':'gastos'}} · en soles al tipo de cambio de cada fecha</p></div><div class="card p-6"><p class="stat-label">Pagados</p><p class="stat-value mt-2">{{paid|money}}</p><p class="text-xs text-muted mt-2">{{paidCount}} con fecha de pago hasta hoy</p></div><div class="card p-6"><p class="stat-label">Por pagar</p><p class="stat-value mt-2" [class.neg]="pending>0">{{pending|money}}</p><p class="text-xs text-muted mt-2">{{items.length-paidCount}} con fecha de pago posterior a hoy</p></div></div><div class="card mt-4 overflow-x-auto"><table class="p-table w-full" appSort="date:asc" #s="appSort" *ngIf="items.length;else empty"><thead><tr><th sortKey="date">Fecha</th><th sortKey="description">Descripción</th><th sortKey="category">Categoría</th><th sortKey="type">Tipo</th><th class="num" sortKey="amount">Monto</th><th class="num" sortKey="amountPen">En soles</th></tr></thead><tbody><tr *ngFor="let x of (items | sortBy:s.key():s.dir()) | slice:(page-1)*pageSize:page*pageSize" (click)="edit(x)" class="cursor-pointer"><td class="whitespace-nowrap">{{x.date|date:'dd/MM/yyyy'}}<span *ngIf="isPending(x)" class="pill pill-warn ml-2">Por pagar</span></td><td class="font-medium">{{x.description}}</td><td>{{x.category | enumLabel:'expenseCategory'}}</td><td><span class="pill" [class.pill-info]="x.type==='Fijo'" [class.pill-neutral]="x.type!=='Fijo'">{{x.type | enumLabel:'expenseType'}}</span></td><td class="num">{{x.amount|money:x.currency}}</td><td class="num font-medium">{{x.amountPen|money}}</td></tr></tbody><tfoot><tr><td colspan="5">Total</td><td class="num">{{total|money}}</td></tr></tfoot></table><ng-template #empty><p class="p-6 text-muted">No hay gastos registrados para este filtro.</p></ng-template></div><app-pager [total]="items.length" [page]="page" [pageSize]="pageSize" (pageChange)="page=$event"/><div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4" *ngIf="editing"><form class="card p-6 w-full max-w-lg space-y-3" (ngSubmit)="save()"><h2 class="font-display text-xl">{{editingId?'Editar gasto':'Nuevo gasto'}}</h2><label class="field-label">Descripción<input class="field" [(ngModel)]="editing.description" name="description" required></label><div class="flex gap-3"><label class="field-label flex-1">Categoría<select class="field" [(ngModel)]="editing.category" name="category"><option *ngFor="let c of categories" [value]="c">{{c | enumLabel:'expenseCategory'}}</option></select></label><label class="field-label flex-1">Tipo<select class="field" [(ngModel)]="editing.type" name="type"><option value="Fijo">Fijo</option><option value="Variable">Variable</option></select></label></div><div class="flex gap-3"><label class="field-label flex-1">Monto<input class="field" type="number" step="0.01" [(ngModel)]="editing.amount" name="amount" required></label><label class="field-label flex-1">Moneda<select class="field" [(ngModel)]="editing.currency" name="currency" required><option value="PEN">S/ Soles</option><option value="USD">US$ Dólares</option><option value="EUR">€ Euros</option></select></label></div><label class="field-label">Fecha<input class="field" type="date" [(ngModel)]="editing.date" name="date" required></label><label class="flex items-center gap-2"><input type="checkbox" [(ngModel)]="editing.recurring" name="recurring"> Es recurrente</label><label class="field-label" *ngIf="editing.recurring">Ciclo<select class="field" [(ngModel)]="editing.recurrenceCycle" name="recurrenceCycle"><option value="Mensual">Mensual</option><option value="Anual">Anual</option></select></label><p *ngIf="error" class="text-sm text-red-600">{{error}}</p><div class="flex gap-2"><button class="btn btn-primary btn-sm" [disabled]="saving">Guardar</button><button type="button" class="btn btn-ghost btn-sm" (click)="editing=null">Cancelar</button></div></form></div><app-import-dialog *ngIf="importing" label="gastos" [result]="importResult" (upload)="upload($event)" (template)="downloadTemplate()" (close)="closeImport()"/>`})
export class ExpensesComponent implements OnInit {
  api = inject(PortalApiService); ui = inject(PortalUiService);
  categories: ExpenseCategory[] = ['Hosting', 'Dominios', 'SuscripcionesIA', 'ApisPorUso', 'Sueldos', 'Comisiones', 'ImpuestoRenta', 'Otros'];
  items: ExpenseDto[] = []; period = new Date().toISOString().slice(0, 7); category = ''; total = 0;
  page = 1; readonly pageSize = 20; paid = 0; pending = 0; paidCount = 0;
  /** La fecha del gasto es su fecha de pago: si aún no llega, está por pagar. */
  private readonly today = new Date().toLocaleDateString('sv-SE');
  isPending(x: ExpenseDto) { return x.date.slice(0, 10) > this.today; }
  editingId: string | null = null; editing: (Omit<ExpenseDto, 'id' | 'amountPen'>) | null = null; saving = false; error: string | null = null;
  importing = false; importResult: ImportResult | null = null; importError: string | null = null;
  ngOnInit() { this.ui.breadcrumb.set({ current: 'Gastos' }); this.load(); }
  upload(file: File) {
    this.importError = null;
    this.api.importExpenses(file).subscribe({
      next: x => { this.importResult = x; this.load(); },
      error: e => { this.importing = false; this.importError = e?.error?.message ?? 'No se pudo importar el archivo.'; },
    });
  }
  downloadTemplate() { this.api.expenseTemplate().subscribe(b => { const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = 'gastos-plantilla.xlsx'; a.click(); URL.revokeObjectURL(a.href); }); }
  closeImport() { this.importing = false; this.importResult = null; }
  load() {
    const [year, month] = this.period ? this.period.split('-').map(Number) : [undefined, undefined];
    this.page = 1;
    this.api.getExpenses({ month, year, category: this.category || undefined }).subscribe(x => {
      this.items = x; this.total = x.reduce((sum, e) => sum + e.amountPen, 0);
      const pending = x.filter(e => this.isPending(e));
      this.pending = pending.reduce((sum, e) => sum + e.amountPen, 0); this.paid = this.total - this.pending; this.paidCount = x.length - pending.length;
    });
  }
  openNew() { this.error = null; this.editingId = null; this.editing = { description: '', category: 'Otros', type: 'Variable', amount: 0, currency: 'PEN', date: new Date().toISOString().slice(0, 10), recurring: false, recurrenceCycle: null }; }
  edit(x: ExpenseDto) { this.error = null; this.editingId = x.id; const { id, amountPen, ...rest } = x; this.editing = { ...rest, date: rest.date.slice(0, 10) }; }
  save() {
    if (!this.editing) return;
    this.saving = true; this.error = null;
    const request = this.editingId ? this.api.updateExpense(this.editingId, this.editing) : this.api.createExpense(this.editing);
    request.subscribe({
      next: () => { this.saving = false; this.editing = null; this.load(); },
      error: e => { this.saving = false; this.error = e?.error?.message ?? 'No se pudo guardar el gasto.'; },
    });
  }
}
