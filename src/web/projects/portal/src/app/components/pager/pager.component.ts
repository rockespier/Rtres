import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

/**
 * Paginación en el cliente: el padre ordena la lista completa y muestra la página con
 * `| slice:(page-1)*pageSize:page*pageSize`, así el orden por columna abarca todas las filas y no solo la página.
 */
@Component({
  selector: 'app-pager',
  standalone: true,
  imports: [CommonModule],
  template: `<div *ngIf="total > pageSize" class="flex items-center justify-between gap-3 flex-wrap mt-4 text-sm text-muted">
    <span class="tabular-nums">{{ from() }}–{{ to() }} de {{ total }}</span>
    <div class="flex items-center gap-2">
      <button type="button" class="btn btn-ghost btn-sm" [disabled]="page <= 1" (click)="go(page - 1)">Anterior</button>
      <span class="tabular-nums">Página {{ page }} de {{ pages() }}</span>
      <button type="button" class="btn btn-ghost btn-sm" [disabled]="page >= pages()" (click)="go(page + 1)">Siguiente</button>
    </div>
  </div>`,
})
export class PagerComponent {
  @Input() total = 0;
  @Input() page = 1;
  @Input() pageSize = 20;
  @Output() pageChange = new EventEmitter<number>();
  pages() { return Math.max(1, Math.ceil(this.total / this.pageSize)); }
  from() { return this.total ? (this.page - 1) * this.pageSize + 1 : 0; }
  to() { return Math.min(this.total, this.page * this.pageSize); }
  go(page: number) { this.pageChange.emit(Math.min(Math.max(1, page), this.pages())); }
}
