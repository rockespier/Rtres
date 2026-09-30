import { Directive, Input, Pipe, PipeTransform, inject, signal } from '@angular/core';

/** Columna por la que se ordena: ruta de propiedad ('client.name') o función que devuelve el valor de la fila. */
export type SortKey<T = any> = string | ((row: T) => unknown);
export type SortDir = 'asc' | 'desc';

/**
 * Tabla ordenable: `<table appSort #s="appSort">` + `<th sortKey="campo">` en las cabeceras y
 * `*ngFor="let x of items | sortBy:s.key():s.dir()"` en las filas. Cada clic alterna ascendente → descendente → sin orden.
 * Con `[sortKey]` como función, pasar siempre la misma referencia (propiedad del componente), no una lambda en el template.
 */
@Directive({ selector: 'table[appSort]', standalone: true, exportAs: 'appSort' })
export class SortableTableDirective {
  readonly key = signal<SortKey | null>(null);
  readonly dir = signal<SortDir>('asc');

  /** Orden inicial opcional, ej. `appSort="date:desc"` (solo claves de texto). */
  @Input() set appSort(initial: string) {
    if (!initial) return;
    const [key, dir] = initial.split(':');
    this.key.set(key); this.dir.set(dir === 'desc' ? 'desc' : 'asc');
  }

  toggle(key: SortKey) {
    if (this.key() !== key) { this.key.set(key); this.dir.set('asc'); }
    else if (this.dir() === 'asc') this.dir.set('desc');
    else this.key.set(null);
  }
}

@Directive({
  selector: 'th[sortKey]',
  standalone: true,
  host: {
    class: 'sortable',
    tabindex: '0',
    '[class.sort-asc]': "active() && table.dir() === 'asc'",
    '[class.sort-desc]': "active() && table.dir() === 'desc'",
    '[attr.aria-sort]': "active() ? (table.dir() === 'asc' ? 'ascending' : 'descending') : 'none'",
    '(click)': 'table.toggle(sortKey)',
    '(keydown.enter)': 'table.toggle(sortKey)',
    '(keydown.space)': '$event.preventDefault(); table.toggle(sortKey)',
  },
})
export class SortHeaderDirective {
  @Input({ required: true }) sortKey!: SortKey;
  readonly table = inject(SortableTableDirective);
  active() { return this.table.key() === this.sortKey; }
}

const collator = new Intl.Collator('es', { numeric: true, sensitivity: 'base' });

function valueOf(row: unknown, key: SortKey): unknown {
  if (typeof key === 'function') return key(row);
  return key.split('.').reduce<any>((value, part) => value?.[part], row);
}

/** Compara números, booleanos, fechas y textos (en español, "item 2" antes que "item 10"). */
function compare(a: unknown, b: unknown): number {
  if (typeof a === 'number' && typeof b === 'number') return a - b;
  if (typeof a === 'boolean' && typeof b === 'boolean') return Number(a) - Number(b);
  if (a instanceof Date && b instanceof Date) return a.getTime() - b.getTime();
  return collator.compare(String(a), String(b));
}

/** Filas ordenadas por la columna activa; los vacíos (null, '') siempre al final. Sin columna activa, el orden original. */
@Pipe({ name: 'sortBy', standalone: true })
export class SortByPipe implements PipeTransform {
  transform<T>(rows: readonly T[] | null | undefined, key: SortKey<T> | null, dir: SortDir = 'asc'): T[] {
    if (!rows) return [];
    if (!key) return rows as T[];
    const sign = dir === 'asc' ? 1 : -1;
    return [...rows].sort((x, y) => {
      const a = valueOf(x, key), b = valueOf(y, key);
      const emptyA = a == null || a === '', emptyB = b == null || b === '';
      if (emptyA || emptyB) return emptyA === emptyB ? 0 : emptyA ? 1 : -1;
      return compare(a, b) * sign;
    });
  }
}

export const SORTABLE = [SortableTableDirective, SortHeaderDirective, SortByPipe] as const;
