import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { AnnualRentaDto, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { MoneyPipe } from '../../core/money.pipe';
import { SORTABLE } from '../../core/sortable';

const MONTHS = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Setiembre', 'Octubre', 'Noviembre', 'Diciembre'];

/**
 * Estimación de la Renta anual de la MYPE (Régimen MYPE Tributario): renta neta, impuesto por tramos, pagos a cuenta y
 * el saldo a regularizar en la declaración jurada anual; con proyección al cierre si el año está en curso.
 */
@Component({
  selector: 'app-annual-renta',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink, MoneyPipe, ...SORTABLE],
  template: `
    <div class="flex flex-wrap justify-between items-end gap-3">
      <div>
        <h1 class="font-display text-2xl font-semibold">Renta anual</h1>
        <p class="text-sm text-muted mt-1 max-w-2xl">Estimación del Impuesto a la Renta de tu MYPE para la declaración jurada anual: 10 % hasta 15 UIT de renta neta y 29.5 % por el exceso, menos los pagos a cuenta del año.</p>
      </div>
      <select class="field" style="width:auto" [ngModel]="year()" (ngModelChange)="load($event)" aria-label="Ejercicio">
        <option *ngFor="let y of years" [ngValue]="y">{{ y }}</option>
      </select>
    </div>

    <div *ngIf="error()" class="card p-6 mt-6 max-w-2xl"><p>{{ error() }}</p><a class="btn btn-primary btn-sm mt-4" routerLink="/admin/tax-settings" fragment="renta-anual">Ir a Configuración</a></div>

    <ng-container *ngIf="data() as d">
      <section class="card mt-6 grid lg:grid-cols-[1fr_1.4fr] overflow-hidden">
        <div class="p-6 rep-feature">
          <p class="stat-label">{{ d.saldoPen >= 0 ? 'Saldo a pagar en la declaración' : 'Saldo a favor' }} · {{ d.year }}</p>
          <p class="font-display rep-hero tabular-nums mt-3" [style.color]="d.saldoPen < 0 ? 'var(--success-ink)' : null">{{ abs(d.saldoPen) | money }}</p>
          <p class="text-sm text-muted mt-3">Impuesto {{ d.impuesto.total | money }} − pagos a cuenta {{ d.pagosACuentaPen | money }}</p>
          <span *ngIf="d.pagosEstimados" class="pill pill-warn mt-3" title="Meses sin el monto pagado registrado en Vencimientos SUNAT: se usa el 1 % estimado">{{ d.pagosEstimados }} {{ d.pagosEstimados === 1 ? 'pago a cuenta estimado' : 'pagos a cuenta estimados' }}</span>
          <dl class="rep-facts mt-6">
            <div><dt>UIT {{ d.year }}</dt><dd>{{ d.uit | money }}</dd></div>
            <div><dt>Límite del tramo 1 ({{ d.tasas.thresholdUits }} UIT)</dt><dd>{{ d.impuesto.limit | money }}</dd></div>
            <div><dt>Pago a cuenta mensual</dt><dd>{{ d.tasas.pagoACuenta | percent:'1.0-2' }}</dd></div>
          </dl>
        </div>
        <div class="p-6">
          <p class="stat-label">Cálculo a la fecha</p>
          <div class="rep-statement mt-4">
            <div class="rep-line"><span>Ventas sin IGV de la MYPE <span class="block text-xs text-muted">Facturas y cobros sin comprobante</span></span><span class="tabular-nums">{{ d.ventasMypePen | money }}</span></div>
            <div class="rep-line"><span>− Gastos deducibles</span><span class="tabular-nums">{{ d.gastosDeduciblesPen | money }}</span></div>
            <div class="rep-line rep-subtotal"><span>Renta neta imponible</span><span class="tabular-nums">{{ d.rentaNetaPen | money }}</span></div>
            <div class="rep-line"><span>Tramo 1: {{ d.impuesto.lowBase | money }} × {{ d.tasas.lowRate | percent:'1.0-1' }}</span><span class="tabular-nums">{{ d.impuesto.lowTax | money }}</span></div>
            <div class="rep-line"><span>Tramo 2: {{ d.impuesto.highBase | money }} × {{ d.tasas.highRate | percent:'1.0-1' }}</span><span class="tabular-nums">{{ d.impuesto.highTax | money }}</span></div>
            <div class="rep-line rep-subtotal"><span>Impuesto anual</span><span class="tabular-nums">{{ d.impuesto.total | money }}</span></div>
            <div class="rep-line"><span>− Pagos a cuenta del año</span><span class="tabular-nums">{{ d.pagosACuentaPen | money }}</span></div>
            <div class="rep-line rep-total"><span>{{ d.saldoPen >= 0 ? 'Saldo a pagar' : 'Saldo a favor' }}</span><span class="tabular-nums">{{ abs(d.saldoPen) | money }}</span></div>
          </div>
        </div>
      </section>

      <section *ngIf="d.proyeccion as p" class="card p-6 mt-4">
        <div class="flex flex-wrap items-baseline justify-between gap-3">
          <p class="stat-label">Proyección al cierre de {{ d.year }}</p>
          <span class="text-xs text-muted">Promedio de {{ p.mesesBase }} {{ p.mesesBase === 1 ? 'mes cerrado' : 'meses cerrados' }} × 12</span>
        </div>
        <div class="grid gap-4 mt-4 sm:grid-cols-4">
          <div><p class="text-xs text-muted">Ventas</p><p class="font-display text-xl font-semibold tabular-nums">{{ p.ventasPen | money }}</p></div>
          <div><p class="text-xs text-muted">Renta neta</p><p class="font-display text-xl font-semibold tabular-nums">{{ p.rentaNetaPen | money }}</p></div>
          <div><p class="text-xs text-muted">Impuesto anual</p><p class="font-display text-xl font-semibold tabular-nums">{{ p.impuesto.total | money }}</p></div>
          <div><p class="text-xs text-muted">{{ p.saldoPen >= 0 ? 'Saldo a pagar estimado' : 'Saldo a favor estimado' }}</p><p class="font-display text-xl font-semibold tabular-nums">{{ abs(p.saldoPen) | money }}</p></div>
        </div>
        <p class="text-xs text-muted mt-3">Si el saldo es alto, conviene separar ese monto desde ahora: la declaración anual vence entre marzo y abril de {{ d.year + 1 }}.</p>
      </section>

      <div class="grid gap-4 mt-4 lg:grid-cols-[1.6fr_1fr] items-start">
        <section class="card overflow-x-auto">
          <table class="p-table w-full" appSort #s="appSort">
            <thead><tr><th sortKey="mes">Mes</th><th class="num" sortKey="ventasPen">Ventas MYPE</th><th class="num" sortKey="gastosPen">Gastos deducibles</th><th class="num" sortKey="pagoACuentaPen">Pago a cuenta</th></tr></thead>
            <tbody>
              <tr *ngFor="let m of d.meses | sortBy:s.key():s.dir()">
                <td>{{ monthName(m.mes) }}</td>
                <td class="num">{{ m.ventasPen | money }}</td>
                <td class="num">{{ m.gastosPen | money }}</td>
                <td class="num">{{ m.pagoACuentaPen | money }}<span *ngIf="m.estimado" class="block text-xs text-muted">estimado</span></td>
              </tr>
            </tbody>
          </table>
          <p class="text-xs text-muted px-4 py-3 border-t">Registra lo pagado cada mes al marcarlo como presentado en <a class="underline" routerLink="/admin/tax-calendar">Vencimientos SUNAT</a>: así el cálculo deja de usar el estimado.</p>
        </section>

        <div class="space-y-4">
          <section class="card p-6">
            <p class="stat-label">No deducibles (no se restan)</p>
            <p class="font-display text-2xl font-semibold tabular-nums mt-2">{{ d.noDeduciblesPen | money }}</p>
            <ul class="mt-3 text-sm divide-y">
              <li *ngFor="let x of d.noDeducibles" class="flex justify-between gap-3 py-2"><span class="truncate">{{ x.descripcion }}</span><span class="tabular-nums">{{ x.monto | money }}</span></li>
            </ul>
            <p *ngIf="!d.noDeducibles.length" class="text-sm text-muted mt-2">Ningún gasto marcado como no deducible.</p>
          </section>
          <section class="card p-6">
            <p class="stat-label">Como persona natural (recibos por honorarios)</p>
            <p class="text-sm text-muted mt-1">No entran en la Renta de la MYPE: se declaran como rentas de cuarta categoría.</p>
            <dl class="rep-facts mt-4">
              <div><dt>Ingresos</dt><dd>{{ d.personaNatural.ingresosPen | money }}</dd></div>
              <div><dt>Retenciones (8 %)</dt><dd>{{ d.personaNatural.retencionesPen | money }}</dd></div>
            </dl>
          </section>
        </div>
      </div>
      <p class="text-xs text-muted mt-4 max-w-3xl">{{ d.disclaimer }}</p>
    </ng-container>
  `,
  styles: [`
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
  `],
})
export class AnnualRentaComponent implements OnInit {
  private api = inject(PortalApiService); private ui = inject(PortalUiService);
  readonly years = Array.from({ length: 4 }, (_, i) => new Date().getFullYear() - i);
  year = signal(new Date().getFullYear());
  data = signal<AnnualRentaDto | null>(null);
  error = signal('');
  readonly abs = Math.abs;

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Renta anual' }); this.load(this.year()); }

  load(year: number) {
    this.year.set(year); this.error.set('');
    this.api.getAnnualRenta(year).subscribe({ next: d => this.data.set(d), error: e => { this.data.set(null); this.error.set(e?.error?.message ?? 'No se pudo calcular la Renta anual.'); } });
  }

  monthName(mes: string) { return MONTHS[Number(mes.slice(5, 7)) - 1]; }
}
