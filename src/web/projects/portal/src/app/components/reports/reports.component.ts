import { SORTABLE } from '../../core/sortable';
import { Component, OnInit, inject } from '@angular/core'; import { CommonModule } from '@angular/common'; import { FormsModule } from '@angular/forms'; import { Router, RouterLink } from '@angular/router'; import { ClientsReportDto, ExpensesReportDto, NetReportDto, PortalApiService, SalesReportDto, TaxSummaryReportDto } from '../../core/portal-api.service'; import { PortalUiService } from '../../core/portal-ui.service'; import { EnumLabelPipe } from '../../core/enum-labels'; import { MoneyPipe, formatMoney } from '../../core/money.pipe';
@Component({selector:'app-reports',standalone:true,imports:[RouterLink,...SORTABLE,CommonModule,FormsModule,EnumLabelPipe,MoneyPipe],template:`
<header class="flex justify-between items-end gap-4 flex-wrap">
  <div>
    <p class="stat-label">Reporte financiero</p>
    <h1 class="font-display text-3xl font-semibold mt-1">{{periodLabel()}}</h1>
    <p class="text-muted text-sm mt-1">Importes en soles (S/) sin IGV, convertidos al tipo de cambio de cada operación.</p>
  </div>
  <div class="flex items-center gap-2 flex-wrap">
    <div class="segmented" role="group" aria-label="Periodo">
      <button type="button" [class.active]="mode==='month'" (click)="setMode('month')">Mes</button>
      <button type="button" [class.active]="mode==='year'" (click)="setMode('year')">Año</button>
    </div>
    <input *ngIf="mode==='month'" class="field rep-control" type="month" [(ngModel)]="period" (ngModelChange)="load()" aria-label="Mes">
    <select *ngIf="mode==='year'" class="field rep-control" [(ngModel)]="year" (ngModelChange)="load()" aria-label="Año"><option *ngFor="let y of years" [ngValue]="y">{{y}}</option></select>
    <select class="field rep-control" [(ngModel)]="currency" (ngModelChange)="load()" aria-label="Moneda de los cobros" title="Moneda en la que se muestran los cobros"><option value="PEN">Cobros en S/</option><option value="USD">Cobros en US$</option><option value="EUR">Cobros en €</option></select>
    <button class="btn btn-ghost btn-sm" [disabled]="exporting" (click)="export()">{{exporting?'Exportando…':'Exportar Excel'}}</button>
  </div>
</header>

<p *ngIf="error" class="neg text-sm mt-4">{{error}}</p>
<p *ngIf="!net && !error" class="text-muted text-sm mt-8">Cargando reporte…</p>

<section class="card mt-6 grid lg:grid-cols-[minmax(0,5fr)_minmax(0,7fr)] overflow-hidden" *ngIf="net">
  <div class="p-6 lg:p-8 rep-feature">
    <p class="stat-label">Utilidad neta</p>
    <p class="font-display rep-hero tabular-nums mt-2" [class.neg]="net.utilidadNetaPen<0">{{net.utilidadNetaPen|money}}</p>
    <span class="pill mt-4" [ngClass]="net.margen>=0?'pill-success':'pill-danger'">Margen {{net.margen|number:'1.1-1'}} %</span>
    <dl class="rep-facts mt-8" *ngIf="sales">
      <div><dt>Cobrado ({{currency}})</dt><dd class="tabular-nums">{{sales.total|money:currency}}</dd></div>
      <div><dt>Base imponible</dt><dd class="tabular-nums">{{sales.baseImponible|money:currency}}</dd></div>
      <div><dt>IGV cobrado</dt><dd class="tabular-nums">{{sales.igv|money:currency}}</dd></div>
    </dl>
  </div>
  <div class="p-6 lg:p-8">
    <h2 class="font-display text-lg font-semibold">Estado de resultados</h2>
    <div class="rep-statement mt-4">
      <div class="rep-line"><span>Ingresos <span class="text-muted">(sin IGV)</span></span><span class="tabular-nums">{{net.ventasPen|money}}</span></div>
      <div class="rep-line"><span>Gastos operativos</span><span class="tabular-nums">− {{net.gastosPen|money}}</span></div>
      <div class="rep-line rep-subtotal"><span>Utilidad operativa</span><span class="tabular-nums" [class.neg]="net.utilidadOperativaPen<0">{{net.utilidadOperativaPen|money}}</span></div>
      <div class="rep-line">
        <span>Renta · pago a cuenta {{net.rentaRate|percent:'1.0-2'}}<span class="block text-xs text-muted mt-0.5">{{net.rentaRate|percent:'1.0-2'}} de los ingresos sin IGV de cada mes (MYPE)</span></span>
        <span class="tabular-nums">− {{net.impuestosPen|money}}</span>
      </div>
      <div class="rep-line rep-total"><span>Utilidad neta</span><span class="tabular-nums" [class.neg]="net.utilidadNetaPen<0">{{net.utilidadNetaPen|money}}</span></div>
    </div>
  </div>
</section>

<section class="card p-6 mt-6" *ngIf="net && net.serie.length>1">
  <div class="flex justify-between items-baseline gap-4 flex-wrap">
    <h2 class="font-display text-lg font-semibold">Evolución mensual</h2>
    <p class="text-muted text-xs flex items-center gap-4"><span class="flex items-center gap-1.5"><i class="rep-key bar-income"></i>Ingresos</span><span class="flex items-center gap-1.5"><i class="rep-key bar-expense"></i>Gastos + Renta</span><span>Cifra superior: utilidad neta</span></p>
  </div>
  <div class="rep-chart mt-6">
    <div class="rep-grid" aria-hidden="true"><span *ngFor="let t of ticks()" [style.bottom.%]="t.pct"><em>{{t.value|money:'PEN':true}}</em></span></div>
    <div class="rep-bars">
      <div *ngFor="let p of net.serie" class="rep-col" [title]="monthLabel(p.mes)+' · ingresos '+money(p.ventasPen)+' · gastos '+money(p.gastosPen)+' · Renta '+money(p.impuestosPen)+' · utilidad '+money(p.utilidadNetaPen)">
        <span class="rep-col-value tabular-nums" [class.neg]="p.utilidadNetaPen<0">{{p.utilidadNetaPen|money:'PEN':true}}</span>
        <div class="rep-col-bars"><div class="bar-income" [style.height.%]="pct(p.ventasPen)"></div><div class="bar-expense" [style.height.%]="pct(p.gastosPen+p.impuestosPen)"></div></div>
        <span class="text-xs text-muted">{{monthLabel(p.mes)}}</span>
      </div>
    </div>
  </div>
</section>

<section class="card mt-6 overflow-x-auto" *ngIf="clients">
  <div class="px-6 pt-6 flex justify-between items-baseline gap-4 flex-wrap">
    <div><h2 class="font-display text-lg font-semibold">Clientes que más aportan</h2><p class="text-muted text-sm mt-1">Ingresos sin IGV · variación contra {{mode==='month'?'el mes':'el año'}} anterior</p></div>
    <p class="text-sm text-muted" *ngIf="clients.clientes.length">Total <span class="font-semibold tabular-nums" style="color:var(--ink)">{{clients.totalPen|money}}</span></p>
  </div>
  <table class="p-table w-full mt-4" appSort #s="appSort" *ngIf="clients.clientes.length;else noClients">
    <thead><tr><th class="w-10 num" [sortKey]="rankKey">#</th><th sortKey="clientName">Cliente</th><th class="num" sortKey="ingresosPen">Ingresos</th><th class="w-1/4" sortKey="porcentaje">Participación</th><th class="num" sortKey="porcentajeAcumulado">Acumulado</th><th class="num" sortKey="cobros">Cobros</th><th sortKey="ultimoCobro">Último cobro</th><th class="num" sortKey="variacionPorcentaje">Variación</th></tr></thead>
    <tbody><tr *ngFor="let c of clients.clientes | sortBy:s.key():s.dir()" (click)="openClient(c.clientId)">
      <td class="num text-muted">{{rankKey(c)}}</td>
      <td class="font-medium">{{c.clientName}}</td>
      <td class="num font-medium">{{c.ingresosPen|money}}</td>
      <td><div class="flex items-center gap-3"><div class="rep-track"><div class="bar-income" [style.width.%]="c.porcentaje"></div></div><span class="text-xs tabular-nums w-12 text-right">{{c.porcentaje|number:'1.1-1'}} %</span></div></td>
      <td class="num text-muted">{{c.porcentajeAcumulado|number:'1.1-1'}} %</td>
      <td class="num">{{c.cobros}}</td>
      <td class="text-muted whitespace-nowrap">{{c.ultimoCobro|date:'dd/MM/yyyy'}}</td>
      <td class="num"><span *ngIf="c.variacionPorcentaje!=null;else isNew" class="pill tabular-nums" [ngClass]="c.variacionPorcentaje<0?'pill-danger':'pill-success'">{{c.variacionPorcentaje>0?'▲ ':c.variacionPorcentaje<0?'▼ ':''}}{{abs(c.variacionPorcentaje)|number:'1.1-1'}} %</span><ng-template #isNew><span class="pill pill-info">Nuevo</span></ng-template></td>
    </tr></tbody>
  </table>
  <ng-template #noClients><p class="px-6 pb-6 pt-4 text-muted">No hay cobros en este periodo.</p></ng-template>
</section>

<div class="grid gap-6 mt-6 lg:grid-cols-2" *ngIf="taxSummary && expenses">
  <section class="card p-6">
    <div class="flex justify-between items-baseline gap-4"><h2 class="font-display text-lg font-semibold">Gastos por categoría</h2><span class="font-display text-lg tabular-nums">{{expenses.total|money}}</span></div>
    <ul class="mt-4 rep-rows" *ngIf="expenses.porCategoria.length;else noExpenses">
      <li *ngFor="let c of sortedCategories()">
        <div class="flex justify-between gap-3 text-sm"><span>{{c.categoria}}</span><span class="tabular-nums"><span class="text-muted text-xs mr-2">{{share(c.monto)|number:'1.0-0'}} %</span>{{c.monto|money}}</span></div>
        <div class="rep-track mt-2"><div class="bar-expense-strong" [style.width.%]="share(c.monto)"></div></div>
      </li>
    </ul>
    <ng-template #noExpenses><p class="text-muted text-sm mt-4">No hay gastos en este periodo.</p></ng-template>
  </section>
  <section class="card p-6">
    <div class="flex justify-between items-baseline gap-4"><h2 class="font-display text-lg font-semibold">IGV y Renta estimados</h2><span class="font-display text-lg tabular-nums">{{(taxSummary.igv.igvAPagar+taxSummary.rentaEstimada)|money}}</span></div>
    <div class="rep-statement mt-4">
      <div class="rep-line"><span>IGV de ventas <span class="text-muted">(débito, {{taxSummary.tasa.igvRate|percent:'1.0-2'}})</span></span><span class="tabular-nums">{{taxSummary.igv.debitoFiscal|money}}</span></div>
      <div class="rep-line"><span>− Crédito fiscal <span class="text-muted">(IGV de compras · <a routerLink="/admin/purchases" class="underline">registrar</a>)</span></span><span class="tabular-nums">{{taxSummary.igv.creditoFiscal|money}}</span></div>
      <div class="rep-line" *ngIf="taxSummary.igv.saldoAFavorAnterior"><span>− Saldo a favor del periodo anterior</span><span class="tabular-nums">{{taxSummary.igv.saldoAFavorAnterior|money}}</span></div>
      <div class="rep-line rep-subtotal"><span>IGV a pagar</span><span class="tabular-nums">{{taxSummary.igv.igvAPagar|money}}</span></div>
      <div class="rep-line" *ngIf="taxSummary.igv.saldoAFavorSiguiente"><span>Saldo a favor para el siguiente periodo</span><span class="tabular-nums">{{taxSummary.igv.saldoAFavorSiguiente|money}}</span></div>
      <div class="rep-line"><span>Impuesto a la Renta <span class="text-muted">({{taxSummary.tasa.rentaRate|percent:'1.0-2'}})</span></span><span class="tabular-nums">{{taxSummary.rentaEstimada|money}}</span></div>
      <div class="rep-line rep-subtotal"><span>Ventas gravadas</span><span class="tabular-nums">{{taxSummary.ventasGravadasPen|money}}</span></div>
      <div class="rep-line"><span>Ventas no gravadas <span class="text-muted">(exportación)</span></span><span class="tabular-nums">{{taxSummary.ventasNoGravadasPen|money}}</span></div>
    </div>
  </section>
</div>
<p class="note mt-6" *ngIf="taxSummary">{{taxSummary.disclaimer}}</p>`,
styles:[`
.rep-hero{font-size:clamp(2.25rem,4vw,3.25rem);line-height:1;letter-spacing:-.02em;font-weight:600}
.rep-feature{background:var(--surface-tint);border-bottom:1px solid var(--border)}
@media (min-width:1024px){.rep-feature{border-bottom:none;border-right:1px solid var(--border)}}
.rep-facts{display:grid;gap:10px}
.rep-facts div{display:flex;justify-content:space-between;gap:12px;font-size:13.5px;padding-top:10px;border-top:1px solid var(--border)}
.rep-facts dt{color:var(--muted)}.rep-facts dd{font-weight:600}
.rep-statement{font-size:14px}
.rep-line{display:flex;justify-content:space-between;align-items:flex-start;gap:16px;padding:11px 0;border-bottom:1px solid var(--border)}
.rep-line>span:last-child{white-space:nowrap}
.rep-subtotal{font-weight:600;background:var(--neutral-bg);margin:0 -12px;padding:11px 12px;border-radius:var(--radius-sm);border-bottom:none}
.rep-total{font-weight:700;font-size:16px;border-top:2px solid var(--ink);border-bottom:none;margin-top:6px;padding-top:14px}
.rep-control{width:auto}
.rep-key{display:inline-block;width:10px;height:10px;border-radius:3px}
.rep-chart{position:relative;height:240px;padding-left:64px}
.rep-grid{position:absolute;inset:24px 0 22px 0}
.rep-grid span{position:absolute;left:0;right:0;border-top:1px dashed var(--border-strong)}
.rep-grid em{position:absolute;left:0;top:-8px;font-style:normal;font-size:11px;color:var(--muted-2);background:var(--surface);padding-right:6px}
.rep-bars{position:relative;display:flex;gap:10px;height:100%;overflow-x:auto}
.rep-col{flex:1;min-width:44px;display:flex;flex-direction:column;align-items:center;gap:6px;height:100%}
.rep-col-value{font-size:11px;font-weight:600;white-space:nowrap;height:18px}
.rep-col-bars{flex:1;width:100%;display:flex;align-items:flex-end;justify-content:center;gap:3px}
.rep-col-bars div{width:min(18px,45%);border-radius:4px 4px 0 0;min-height:1px}
.rep-track{flex:1;height:6px;border-radius:99px;background:var(--neutral-bg);overflow:hidden}
.rep-track div{height:100%;border-radius:99px}
.rep-rows{display:grid;gap:14px}
.bar-income{background:var(--primary)}.bar-expense{background:var(--border-strong)}.bar-expense-strong{background:var(--muted-2)}
`]})
export class ReportsComponent implements OnInit {
  api = inject(PortalApiService); ui = inject(PortalUiService); router = inject(Router);
  mode: 'month' | 'year' = 'month'; period = new Date().toISOString().slice(0, 7); year = new Date().getFullYear(); currency = 'PEN';
  years = Array.from({ length: 5 }, (_, i) => new Date().getFullYear() - i);
  sales: SalesReportDto | null = null; taxSummary: TaxSummaryReportDto | null = null; expenses: ExpensesReportDto | null = null; net: NetReportDto | null = null; clients: ClientsReportDto | null = null;
  exporting = false; error = '';
  readonly money = (value: number) => formatMoney(value);
  readonly abs = Math.abs;
  /** Puesto en el ranking por ingresos (el orden en que llega del API), aunque la tabla se ordene por otra columna. */
  readonly rankKey = (c: { clientId: string }) => (this.clients?.clientes.findIndex(x => x.clientId === c.clientId) ?? 0) + 1;
  ngOnInit() { this.ui.breadcrumb.set({ current: 'Reportes' }); this.load(); }
  setMode(mode: 'month' | 'year') { if (this.mode === mode) return; this.mode = mode; this.load(); }
  /** Mes seleccionado, o undefined para el año completo. */
  private range(): [number | undefined, number] { if (this.mode === 'year') return [undefined, this.year]; const [year, month] = this.period.split('-').map(Number); return [month, year]; }
  periodLabel() { const [month, year] = this.range(); return month ? `${MONTHS[month - 1]} ${year}` : `Año ${year}`; }
  load() {
    const [month, year] = this.range(); this.error = '';
    this.api.getSalesReport(month, year, this.currency).subscribe(x => this.sales = x);
    this.api.getTaxSummaryReport(month, year).subscribe(x => this.taxSummary = x);
    this.api.getExpensesReport(month, year).subscribe(x => this.expenses = x);
    this.api.getNetReport(month, year).subscribe({ next: x => this.net = x, error: () => this.error = 'No se pudo cargar el reporte.' });
    this.api.getClientsReport(month, year).subscribe(x => this.clients = x);
  }
  /** Mayor valor del gráfico (ingresos o gastos + Renta), redondeado hacia arriba para que las líneas guía sean cifras limpias. */
  private chartMax() { const max = Math.max(1, ...(this.net?.serie ?? []).flatMap(p => [p.ventasPen, p.gastosPen + p.impuestosPen])); const step = 10 ** Math.floor(Math.log10(max)); return Math.ceil(max / step) * step; }
  /** Altura de una barra relativa al máximo del gráfico. */
  pct(value: number) { return Math.max(0, value) / this.chartMax() * 100; }
  ticks() { const max = this.chartMax(); return [0, 0.5, 1].map(f => ({ pct: f * 100, value: max * f })); }
  sortedCategories() { return [...(this.expenses?.porCategoria ?? [])].sort((a, b) => b.monto - a.monto); }
  share(monto: number) { return this.expenses && this.expenses.total > 0 ? monto / this.expenses.total * 100 : 0; }
  monthLabel(mes: string) { return MONTHS[Number(mes.slice(5, 7)) - 1].slice(0, 3); }
  openClient(id: string) { this.router.navigate(['/admin/clients', id]); }
  export() {
    const [month, year] = this.range(); this.exporting = true;
    this.api.exportReport(month, year).subscribe({
      next: b => { const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = month ? `reporte-${year}-${String(month).padStart(2, '0')}.xlsx` : `reporte-${year}.xlsx`; a.click(); URL.revokeObjectURL(a.href); this.exporting = false; },
      error: () => { this.error = 'No se pudo exportar el reporte.'; this.exporting = false; },
    });
  }
}
const MONTHS = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre'];
