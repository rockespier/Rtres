import { Component, OnInit, inject, input, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Observable } from 'rxjs';
import { CategoryDto, PortalApiService } from '../../core/portal-api.service';

/** Lista editable de categorías (gastos o productos): agregar, renombrar y eliminar las que no están en uso. */
@Component({
  selector: 'app-category-manager',
  standalone: true,
  imports: [FormsModule],
  template: `<section class="card">
    <header class="px-6 py-4 border-b border-[var(--border)]">
      <h2 class="font-display text-base font-semibold">{{ title() }}</h2>
      <p class="text-xs text-muted mt-1">{{ hint() }}</p>
    </header>
    <ul class="divide-y divide-[var(--border)]">
      @for (c of items(); track c.id) {
        <li class="px-6 py-3 flex items-center gap-3 min-h-[56px]">
          @if (renamingId() === c.id) {
            <form class="flex flex-1 gap-2" (ngSubmit)="rename(c)">
              <input class="field flex-1" [(ngModel)]="renameValue" name="rename" [attr.aria-label]="'Nuevo nombre de ' + c.name" maxlength="100" autofocus>
              <button class="btn btn-primary btn-sm" [disabled]="busy() || !renameValue.trim()">Guardar</button>
              <button type="button" class="btn btn-ghost btn-sm" (click)="renamingId.set(null)">Cancelar</button>
            </form>
          } @else if (deletingId() === c.id) {
            <p class="flex-1 text-sm">¿Eliminar «{{ c.name }}»?</p>
            <button type="button" class="btn btn-danger btn-sm" [disabled]="busy()" (click)="remove(c)">Eliminar</button>
            <button type="button" class="btn btn-ghost btn-sm" (click)="deletingId.set(null)">Cancelar</button>
          } @else {
            <div class="flex-1 min-w-0">
              <p class="text-sm font-medium truncate">{{ c.name }}
                @if (c.isIncomeTax) { <span class="pill pill-info ml-1" title="En los reportes se resta como impuesto, no como gasto operativo">Impuesto</span> }
                @if (c.isSystem) { <span class="pill pill-neutral ml-1" title="Categoría del sistema: se puede renombrar, no eliminar">Sistema</span> }
              </p>
              <p class="text-xs text-muted">{{ c.usageCount === 0 ? 'Sin uso' : c.usageCount + ' ' + (c.usageCount === 1 ? unit()[0] : unit()[1]) }}</p>
            </div>
            <button type="button" class="btn btn-ghost btn-sm" (click)="startRename(c)">Renombrar</button>
            @if (!c.isSystem) {
              <button type="button" class="btn btn-ghost btn-sm text-red-600" [disabled]="c.usageCount > 0" [title]="c.usageCount > 0 ? 'Tiene ' + unit()[1] + ': cámbialos de categoría primero' : ''" (click)="startDelete(c)">Eliminar</button>
            }
          }
        </li>
      } @empty {
        <li class="px-6 py-5 text-sm text-muted">Aún no hay categorías.</li>
      }
    </ul>
    <form class="px-6 py-4 border-t border-[var(--border)] flex gap-2" (ngSubmit)="add()">
      <input class="field flex-1" [(ngModel)]="newName" name="newName" placeholder="Nueva categoría" aria-label="Nombre de la nueva categoría" maxlength="100">
      <button class="btn btn-primary btn-sm" [disabled]="busy() || !newName.trim()">Agregar</button>
    </form>
    @if (error()) { <p class="px-6 pb-4 text-sm text-red-600">{{ error() }}</p> }
  </section>`,
})
export class CategoryManagerComponent implements OnInit {
  private api = inject(PortalApiService);
  kind = input.required<'expense' | 'product'>();
  title = input('');
  hint = input('');

  items = signal<CategoryDto[]>([]);
  busy = signal(false);
  error = signal('');
  renamingId = signal<string | null>(null);
  deletingId = signal<string | null>(null);
  newName = '';
  renameValue = '';

  unit() { return this.kind() === 'expense' ? ['gasto', 'gastos'] : ['producto', 'productos']; }

  ngOnInit() { this.load(); }

  load() { this.api.getCategories(this.kind()).subscribe(x => this.items.set(x)); }

  startRename(c: CategoryDto) { this.error.set(''); this.deletingId.set(null); this.renameValue = c.name; this.renamingId.set(c.id); }
  startDelete(c: CategoryDto) { this.error.set(''); this.renamingId.set(null); this.deletingId.set(c.id); }

  add() { this.run(this.api.createCategory(this.kind(), this.newName.trim()), () => this.newName = ''); }
  rename(c: CategoryDto) { this.run(this.api.renameCategory(this.kind(), c.id, this.renameValue.trim()), () => this.renamingId.set(null)); }
  remove(c: CategoryDto) { this.run(this.api.deleteCategory(this.kind(), c.id), () => this.deletingId.set(null)); }

  private run(call: Observable<unknown>, done: () => void) {
    this.busy.set(true); this.error.set('');
    call.subscribe({
      next: () => { this.busy.set(false); done(); this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo guardar la categoría.'); },
    });
  }
}
