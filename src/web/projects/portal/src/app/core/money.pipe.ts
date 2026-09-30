import { Pipe, PipeTransform } from '@angular/core';

/** Símbolos fijos: Intl muestra "USD" en es-PE según el navegador, y aquí siempre se quiere el símbolo. */
const SYMBOLS: Record<string, string> = { PEN: 'S/', USD: 'US$', EUR: '€' };
const amount = new Intl.NumberFormat('es-PE', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const compactAmount = new Intl.NumberFormat('es-PE', { notation: 'compact', maximumFractionDigits: 1 });

/** Importe con símbolo de moneda en formato peruano: S/ 1,234.56 · US$ 1,234.56 · € 1,234.56. `compact` abrevia (S/ 12.5 K) para gráficos. */
export function formatMoney(value: number | null | undefined, currency = 'PEN', compact = false): string {
  if (value == null) return '—';
  const symbol = SYMBOLS[currency?.toUpperCase()] ?? currency;
  const text = (compact ? compactAmount : amount).format(Math.abs(value));
  return `${value < 0 ? '-' : ''}${symbol} ${text}`;
}

@Pipe({ name: 'money', standalone: true })
export class MoneyPipe implements PipeTransform {
  transform(value: number | null | undefined, currency = 'PEN', compact = false): string { return formatMoney(value, currency, compact); }
}
