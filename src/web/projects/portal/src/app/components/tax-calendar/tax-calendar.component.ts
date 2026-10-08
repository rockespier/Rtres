import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { PortalApiService, TaxCalendarDto, TaxDueDateDto, TaxDueDateRequest, TaxSummaryReportDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { MoneyPipe } from '../../core/money.pipe';
import { SORTABLE } from '../../core/sortable';

type DigitKey = keyof TaxDueDateRequest;
/** Columnas del cronograma en el orden en que SUNAT las publica. */
const COLUMNS: { key: DigitKey; label: string }[] = [
  { key: 'digit0', label: '0' }, { key: 'digit1', label: '1' }, { key: 'digit2And3', label: '2 y 3' }, { key: 'digit4And5', label: '4 y 5' },
  { key: 'digit6And7', label: '6 y 7' }, { key: 'digit8And9', label: '8 y 9' }, { key: 'goodTaxpayer', label: 'Buenos contrib.' },
];
const MONTHS = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'setiembre', 'octubre', 'noviembre', 'diciembre'];

interface Row extends TaxDueDateDto { label: string; status: 'Presentada' | 'Vencida' | 'Próxima' | 'Pendiente'; }

/** Cronograma SUNAT de la declaración mensual (IGV-Renta): qué vence, cuándo y qué ya se presentó. */
@Component({
  selector: 'app-tax-calendar',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, MoneyPipe, ...SORTABLE],
  template: `
    <div class="flex flex-wrap justify-between items-end gap-3">
      <div>
        <h1 class="font-display text-2xl font-semibold">Vencimientos SUNAT</h1>
        <p class="text-sm text-muted mt-1 max-w-2xl">Declaración y pago mensual de IGV y Renta (Formulario Virtual 621) según el cronograma de SUNAT y el último dígito de tu RUC. Te avisamos por correo y en la campana 7, 3 y 1 día antes, y el mismo día.</p>
      </div>
      <div class="flex gap-2 items-center" *ngIf="data">
        <select class="field w-auto" [ngModel]="data.year" (ngModelChange)="load($event)" aria-label="Año del cronograma">
          <option *ngFor="let y of data.years" [ngValue]="y">{{y}}</option>
        </select>
        <button class="btn btn-ghost btn-sm" (click)="openNew()">Agregar periodo</button>
      </div>
    </div>

    <form *ngIf="data && (!data.ruc && !data.isGoodTaxpayer || editingRuc)" class="card p-6 mt-6 max-w-2xl" (ngSubmit)="saveRuc()">
      <p class="stat-label">Tu RUC</p>
      <p class="text-sm text-muted mt-1">El último dígito define qué columna del cronograma te toca. Sin RUC no podemos calcular tus vencimientos ni enviarte avisos.</p>
      <div class="flex flex-wrap items-end gap-3 mt-4">
        <label class="field-label flex-1 min-w-[180px]">RUC<input class="field tabular-nums" [(ngModel)]="ruc" name="ruc" inputmode="numeric" maxlength="11" placeholder="20xxxxxxxxx"></label>
        <label class="flex items-center gap-2 text-sm pb-2"><input type="checkbox" [(ngModel)]="goodTaxpayer" name="good"> Soy buen contribuyente</label>
        <button class="btn btn-primary btn-sm" [disabled]="savingRuc">Guardar</button>
        <button *ngIf="editingRuc" type="button" class="btn btn-ghost btn-sm" (click)="editingRuc=false">Cancelar</button>
      </div>
      <p *ngIf="rucError" class="text-sm text-red-600 mt-3">{{rucError}}</p>
    </form>

    <section *ngIf="data?.next as next" class="card p-6 mt-6 grid gap-6 lg:grid-cols-[1.3fr_1fr]">
      <div>
        <p class="stat-label">Próximo vencimiento · periodo {{monthLabel(next.period)}}</p>
        <p class="font-display text-5xl md:text-6xl font-semibold mt-3 leading-none capitalize">{{fmt(next.dueDate, { weekday: 'short', day: 'numeric', month: 'short' })}}</p>
        <div class="flex flex-wrap items-center gap-3 mt-4">
          <span class="pill" [ngClass]="daysLeft(next) <= 1 ? 'pill-danger' : daysLeft(next) <= 7 ? 'pill-warn' : 'pill-info'"><i class="pill-dot"></i>{{whenLabel(daysLeft(next))}}</span>
          <span class="text-sm text-muted">RUC {{data!.ruc || '—'}}{{data!.isGoodTaxpayer ? ' · buen contribuyente' : ''}} · <button type="button" class="underline" (click)="editRuc()">cambiar</button></span>
        </div>
        <button class="btn btn-primary btn-sm mt-6" (click)="toggleFiled(next, true)" [disabled]="busy">Marcar como presentada</button>
      </div>
      <div class="border-t lg:border-t-0 lg:border-l pt-6 lg:pt-0 lg:pl-6">
        <p class="stat-label">A pagar en esa declaración (estimado)</p>
        <div *ngIf="summary; else loadingSummary" class="mt-3 divide-y">
          <div class="flex justify-between py-2"><span>IGV a pagar</span><span class="tabular-nums font-medium">{{summary.igv.igvAPagar | money}}</span></div>
          <div class="flex justify-between py-2"><span>Renta (pago a cuenta {{summary.tasa.rentaRate | percent:'1.0-2'}})</span><span class="tabular-nums font-medium">{{summary.rentaEstimada | money}}</span></div>
          <div class="flex justify-between py-2 font-semibold"><span>Total</span><span class="tabular-nums">{{summary.igv.igvAPagar + summary.rentaEstimada | money}}</span></div>
        </div>
        <ng-template #loadingSummary><p class="text-sm text-muted mt-3">Calculando…</p></ng-template>
        <p class="text-xs text-muted mt-3">Estimación con tus ventas y compras registradas, no una liquidación oficial. <a class="underline" [routerLink]="['/admin/reports']">Ver en Reportes</a>.</p>
      </div>
    </section>

    <div *ngIf="data?.overdue?.length" class="card p-4 mt-4 flex flex-wrap items-center justify-between gap-3 border-l-4" style="border-left-color:var(--warn-ink)">
      <p class="text-sm"><span class="font-medium">{{data!.overdue.length}} {{data!.overdue.length === 1 ? 'periodo vencido' : 'periodos vencidos'}} sin marcar como presentados:</span> <span class="text-muted">{{data!.overdue.join(', ')}}</span></p>
      <button class="btn btn-ghost btn-sm" (click)="markOverdue()" [disabled]="busy">Ya los presenté todos</button>
    </div>
    <div *ngIf="data?.missingNextYear" class="card p-4 mt-4 border-l-4 text-sm" style="border-left-color:var(--info-ink)">
      SUNAT publica en diciembre el cronograma de {{data!.year + 1}}. Cárgalo con "Agregar periodo" para seguir recibiendo avisos desde enero.
    </div>

    <div class="card mt-6 overflow-x-auto" *ngIf="data">
      <table class="p-table w-full" appSort #s="appSort" *ngIf="rows.length; else empty">
        <thead><tr>
          <th sortKey="period">Periodo</th><th sortKey="dueDate">Tu vencimiento</th><th sortKey="status">Estado</th>
          <th *ngFor="let c of columns" class="text-center whitespace-nowrap" [class.mine]="c.key === myColumn">{{c.label}}</th>
          <th><span class="sr-only">Acciones</span></th>
        </tr></thead>
        <tbody>
          <tr *ngFor="let r of rows | sortBy:s.key():s.dir()" [class.is-next]="r.id === data.next?.id">
            <td class="capitalize whitespace-nowrap font-medium">{{r.label}}</td>
            <td class="whitespace-nowrap tabular-nums">{{r.dueDate ? fmt(r.dueDate, { weekday: 'short', day: '2-digit', month: '2-digit', year: 'numeric' }) : '—'}}</td>
            <td><span class="pill" [ngClass]="tone(r.status)"><i class="pill-dot"></i>{{r.status}}</span><span *ngIf="r.filedAt" class="block text-xs text-muted mt-1">{{r.filedAt | date:'dd/MM/yyyy'}}</span></td>
            <td *ngFor="let c of columns" class="text-center tabular-nums whitespace-nowrap" [class.mine]="c.key === myColumn">{{r[c.key] | date:'dd/MM'}}</td>
            <td class="whitespace-nowrap text-right">
              <button class="btn btn-ghost btn-sm" (click)="toggleFiled(r, !r.filedAt)" [disabled]="busy">{{r.filedAt ? 'Desmarcar' : 'Presentada'}}</button>
              <button class="btn btn-ghost btn-sm" (click)="edit(r)">Editar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <ng-template #empty><p class="p-6 text-muted">No hay cronograma cargado para {{data.year}}. Agrega sus periodos con las fechas que publica SUNAT.</p></ng-template>
    </div>
    <p class="text-xs text-muted mt-3">Cronograma 2026: Anexo I de la R.S. N.º 000281-2022/SUNAT. Verifica las fechas en sunat.gob.pe; si SUNAT las modifica (feriados, prórrogas), corrígelas con "Editar".</p>

    <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4 overflow-y-auto" *ngIf="form">
      <form class="card p-6 w-full max-w-2xl space-y-4 my-8" role="dialog" aria-modal="true" aria-label="Fechas del periodo" (ngSubmit)="saveForm()">
        <h2 class="font-display text-xl">{{formIsNew ? 'Agregar periodo' : 'Editar ' + monthLabel(formPeriod)}}</h2>
        <label class="field-label max-w-[220px]" *ngIf="formIsNew">Periodo tributario<input class="field" type="month" [(ngModel)]="formPeriod" name="period" required></label>
        <p class="text-sm text-muted">Fecha de vencimiento por último dígito del RUC, tal como figura en el cronograma de SUNAT.</p>
        <div class="grid gap-3 grid-cols-2 sm:grid-cols-4">
          <label *ngFor="let c of columns" class="field-label">{{c.key === 'goodTaxpayer' ? 'Buenos contribuyentes' : 'Dígito ' + c.label}}<input class="field" type="date" [(ngModel)]="form[c.key]" [name]="c.key" required></label>
        </div>
        <p *ngIf="formError" class="text-sm text-red-600">{{formError}}</p>
        <div class="flex justify-end gap-2"><button type="button" class="btn btn-ghost btn-sm" (click)="form=null">Cancelar</button><button class="btn btn-primary btn-sm" [disabled]="busy">Guardar</button></div>
      </form>
    </div>
  `,
  styles: [`
    th.mine, td.mine { background: var(--surface-tint); font-weight: 600; }
    tr.is-next td { box-shadow: inset 0 1px 0 var(--primary), inset 0 -1px 0 var(--primary); }
  `],
})
export class TaxCalendarComponent implements OnInit {
  private api = inject(PortalApiService); private ui = inject(PortalUiService);
  readonly columns = COLUMNS;
  data: TaxCalendarDto | null = null; rows: Row[] = []; summary: TaxSummaryReportDto | null = null;
  myColumn: DigitKey | null = null;
  busy = false;
  ruc = ''; goodTaxpayer = false; editingRuc = false; savingRuc = false; rucError: string | null = null;
  form: TaxDueDateRequest | null = null; formPeriod = ''; formIsNew = false; formError: string | null = null;

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Vencimientos SUNAT' }); this.load(); }

  load(year?: number) {
    this.api.getTaxCalendar(year).subscribe(d => {
      this.data = d; this.ruc = d.ruc ?? ''; this.goodTaxpayer = d.isGoodTaxpayer;
      this.myColumn = columnFor(d.ruc, d.isGoodTaxpayer);
      this.rows = d.rows.map(r => ({ ...r, label: this.monthLabel(r.period), status: statusOf(r, d) }));
      const next = d.next?.period;
      if (next && next !== this.summaryPeriod) {
        this.summary = null; this.summaryPeriod = next;
        const [y, m] = next.split('-').map(Number);
        this.api.getTaxSummaryReport(m, y).subscribe({ next: s => this.summary = s, error: () => {} });
      }
    });
  }
  private summaryPeriod: string | null = null;

  /** Fecha yyyy-MM-dd en español, sin pasar por UTC (sería el día anterior en Lima). */
  fmt(date: string | null, options: Intl.DateTimeFormatOptions) { if (!date) return ''; const [y, m, d] = date.split('-').map(Number); return new Date(y, m - 1, d).toLocaleDateString('es-PE', options).replace(/\./g, ''); }
  monthLabel(period: string) { const [y, m] = period.split('-').map(Number); return `${MONTHS[m - 1]} ${y}`; }
  daysLeft(r: TaxDueDateDto) { return r.dueDate && this.data ? dayDiff(this.data.today, r.dueDate) : 0; }
  whenLabel(days: number) { return days <= 0 ? 'Vence hoy' : days === 1 ? 'Vence mañana' : `Faltan ${days} días`; }
  tone(status: Row['status']) { return { Presentada: 'pill-success', Vencida: 'pill-danger', Próxima: 'pill-warn', Pendiente: 'pill-neutral' }[status]; }

  editRuc() { this.editingRuc = true; this.rucError = null; }
  saveRuc() {
    this.savingRuc = true; this.rucError = null;
    this.api.updateTaxSettings({ ruc: this.ruc.trim(), isGoodTaxpayer: this.goodTaxpayer }).subscribe({
      next: () => { this.savingRuc = false; this.editingRuc = false; this.load(this.data?.year); },
      error: e => { this.savingRuc = false; this.rucError = e?.error?.message ?? 'No se pudo guardar.'; },
    });
  }

  toggleFiled(r: TaxDueDateDto, filed: boolean) {
    this.busy = true;
    this.api.setTaxPeriodFiled(r.id, filed).subscribe({ next: () => { this.busy = false; this.load(this.data?.year); }, error: () => this.busy = false });
  }
  markOverdue() {
    this.busy = true;
    this.api.markOverdueTaxPeriodsFiled().subscribe({ next: () => { this.busy = false; this.load(this.data?.year); }, error: () => this.busy = false });
  }

  openNew() {
    // Propone el periodo siguiente al último cargado.
    const last = this.data?.rows.at(-1)?.period;
    const [y, m] = last ? last.split('-').map(Number) : [this.data?.year ?? new Date().getFullYear(), 0];
    this.formPeriod = m === 12 ? `${y + 1}-01` : `${y}-${String(m + 1).padStart(2, '0')}`;
    this.form = { digit0: '', digit1: '', digit2And3: '', digit4And5: '', digit6And7: '', digit8And9: '', goodTaxpayer: '' };
    this.formIsNew = true; this.formError = null;
  }
  edit(r: TaxDueDateDto) {
    this.form = Object.fromEntries(COLUMNS.map(c => [c.key, r[c.key]])) as TaxDueDateRequest;
    this.formPeriod = r.period; this.formIsNew = false; this.formError = null;
  }
  saveForm() {
    if (!this.form) return;
    this.busy = true; this.formError = null;
    this.api.saveTaxDueDate(this.formPeriod, this.form).subscribe({
      next: () => { this.busy = false; this.form = null; this.load(Number(this.formPeriod.slice(0, 4))); },
      error: e => { this.busy = false; this.formError = e?.error?.message ?? 'No se pudo guardar.'; },
    });
  }
}

/** Misma regla que TaxDueDate.DueFor en el API. */
function columnFor(ruc: string | null, good: boolean): DigitKey | null {
  if (good) return 'goodTaxpayer';
  const d = ruc?.trim().slice(-1);
  if (!d || !/\d/.test(d)) return null;
  return (['digit0', 'digit1', 'digit2And3', 'digit2And3', 'digit4And5', 'digit4And5', 'digit6And7', 'digit6And7', 'digit8And9', 'digit8And9'] as DigitKey[])[Number(d)];
}

function dayDiff(from: string, to: string) { return Math.round((Date.parse(to) - Date.parse(from)) / 86_400_000); }

function statusOf(r: TaxDueDateDto, d: TaxCalendarDto): Row['status'] {
  if (r.filedAt) return 'Presentada';
  if (!r.dueDate) return 'Pendiente';
  if (r.dueDate < d.today) return 'Vencida';
  return r.id === d.next?.id ? 'Próxima' : 'Pendiente';
}
