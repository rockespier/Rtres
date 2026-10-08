import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { LearningVideoDto, LearningVideoRequest, PortalApiService } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

const LANGUAGES: Record<string, string> = { es: 'Español', en: 'English', it: 'Italiano' };
const SUGGESTED_CATEGORIES = ['Marca personal', 'Disciplina y hábitos', 'Negocios', 'Tecnología', 'Ventas'];

/** Videos de YouTube de la página Recursos del sitio público: alta, edición, orden y publicación. */
@Component({
  selector: 'app-learning-videos',
  standalone: true,
  imports: [FormsModule],
  template: `
    <div class="flex flex-wrap justify-between items-end gap-3">
      <div>
        <h1 class="font-display text-2xl font-semibold">Videos del sitio</h1>
        <p class="text-sm text-muted mt-1 max-w-2xl">Se muestran en la página Recursos del sitio, en el orden de esta lista. Solo se enlazan videos públicos de YouTube: no se descargan ni se vuelven a subir.</p>
      </div>
      <button class="btn btn-primary btn-sm" (click)="openNew()">Agregar video</button>
    </div>

    <div class="card mt-6">
      @if (!videos().length) {
        <p class="p-6 text-sm text-muted">Aún no hay videos. Agrega el primero con el enlace de YouTube.</p>
      }
      <ul class="divide-y divide-[var(--border)]">
        @for (v of videos(); track v.id; let i = $index; let first = $first; let last = $last) {
          <li class="flex items-center gap-4 px-5 py-3">
            <img [src]="thumb(v.youtubeId)" alt="" class="w-28 aspect-video object-cover rounded-md bg-[var(--neutral-bg)] shrink-0" loading="lazy">
            <div class="min-w-0 flex-1">
              <p class="font-medium truncate">{{ v.title }}</p>
              <p class="text-xs text-muted mt-0.5">{{ v.category }} · {{ v.language ? languages[v.language] : 'Todos los idiomas' }}</p>
            </div>
            <span class="pill" [class.pill-success]="v.isPublished" [class.pill-neutral]="!v.isPublished">{{ v.isPublished ? 'Publicado' : 'Oculto' }}</span>
            <div class="flex gap-1">
              <button class="btn btn-ghost btn-sm" [disabled]="first || busy()" (click)="move(i, -1)" [attr.aria-label]="'Subir ' + v.title">↑</button>
              <button class="btn btn-ghost btn-sm" [disabled]="last || busy()" (click)="move(i, 1)" [attr.aria-label]="'Bajar ' + v.title">↓</button>
              <button class="btn btn-ghost btn-sm" (click)="edit(v)">Editar</button>
            </div>
          </li>
        }
      </ul>
    </div>
    @if (listError()) { <p class="text-sm text-red-600 mt-3">{{ listError() }}</p> }

    @if (editing(); as f) {
      <div class="fixed inset-0 z-50 grid place-items-center bg-black/40 p-4">
        <form class="card w-full max-w-lg p-6 space-y-3" role="dialog" aria-modal="true" [attr.aria-label]="editingId ? 'Editar video' : 'Agregar video'" (ngSubmit)="save()">
          <h2 class="font-display text-xl">{{ editingId ? 'Editar video' : 'Agregar video' }}</h2>
          <label class="field-label">Enlace de YouTube<input class="field" [(ngModel)]="f.url" name="url" required placeholder="https://www.youtube.com/watch?v=…" (ngModelChange)="url.set($event)"></label>
          @if (previewId()) { <img [src]="thumb(previewId()!)" alt="Miniatura del video" class="w-full aspect-video object-cover rounded-md"> }
          <label class="field-label">Título<input class="field" [(ngModel)]="f.title" name="title" required maxlength="200"></label>
          <div class="grid grid-cols-2 gap-3">
            <label class="field-label">Categoría<input class="field" [(ngModel)]="f.category" name="category" required list="video-categories" maxlength="100">
              <datalist id="video-categories">@for (c of categories(); track c) {<option [value]="c"></option>}</datalist></label>
            <label class="field-label">Idioma del sitio<select class="field" [(ngModel)]="f.language" name="language">
              <option [ngValue]="null">Todos</option>
              @for (l of languageCodes; track l) {<option [ngValue]="l">{{ languages[l] }}</option>}
            </select></label>
          </div>
          <label class="field-label">Descripción <span class="font-normal">(opcional)</span><textarea class="field" rows="2" [(ngModel)]="f.description" name="description" maxlength="500"></textarea></label>
          <label class="flex items-center gap-2 text-sm"><input type="checkbox" [(ngModel)]="f.isPublished" name="isPublished"> Publicado en el sitio</label>
          @if (error()) { <p class="text-sm text-red-600">{{ error() }}</p> }
          @if (confirmingDelete()) {
            <div class="rounded-[var(--radius-sm)] border border-[var(--danger-border)] bg-[var(--danger-bg)] p-4 text-sm">
              <p>¿Quitar «{{ f.title }}» de Recursos?</p>
              <div class="flex gap-2 mt-3">
                <button type="button" class="btn btn-danger btn-sm" [disabled]="busy()" (click)="remove()">Quitar</button>
                <button type="button" class="btn btn-ghost btn-sm" (click)="confirmingDelete.set(false)">Volver</button>
              </div>
            </div>
          } @else {
            <div class="flex gap-2">
              <button class="btn btn-primary btn-sm" [disabled]="busy()">{{ busy() ? 'Guardando…' : 'Guardar' }}</button>
              <button type="button" class="btn btn-ghost btn-sm" (click)="editing.set(null)">Cancelar</button>
              @if (editingId) { <button type="button" class="btn btn-ghost btn-sm text-red-600 ml-auto" (click)="confirmingDelete.set(true)">Quitar</button> }
            </div>
          }
        </form>
      </div>
    }
  `,
})
export class LearningVideosComponent implements OnInit {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  readonly languages = LANGUAGES;
  readonly languageCodes = Object.keys(LANGUAGES);

  videos = signal<LearningVideoDto[]>([]);
  editing = signal<LearningVideoRequest | null>(null);
  editingId: string | null = null;
  url = signal('');
  busy = signal(false);
  error = signal('');
  listError = signal('');
  confirmingDelete = signal(false);
  categories = computed(() => [...new Set([...SUGGESTED_CATEGORIES, ...this.videos().map(v => v.category)])].sort());
  /** Misma regla que el API (LearningVideosController.ParseYoutubeId), solo para la vista previa. */
  previewId = computed(() => {
    const v = this.url().trim();
    if (/^[A-Za-z0-9_-]{11}$/.test(v)) return v;
    return v.match(/(?:youtube\.com\/(?:watch\?(?:.*&)?v=|embed\/|shorts\/|live\/)|youtu\.be\/)([A-Za-z0-9_-]{11})/)?.[1] ?? null;
  });

  ngOnInit() { this.ui.breadcrumb.set({ current: 'Videos del sitio' }); this.load(); }
  load() { this.api.getLearningVideos().subscribe(x => this.videos.set(x)); }

  thumb(id: string) { return `https://i.ytimg.com/vi/${id}/mqdefault.jpg`; }

  openNew() { this.open(null, { url: '', title: '', category: '', language: null, description: null, isPublished: true }); }
  edit(v: LearningVideoDto) { this.open(v.id, { url: `https://www.youtube.com/watch?v=${v.youtubeId}`, title: v.title, category: v.category, language: v.language, description: v.description, isPublished: v.isPublished }); }
  private open(id: string | null, form: LearningVideoRequest) { this.editingId = id; this.error.set(''); this.confirmingDelete.set(false); this.url.set(form.url); this.editing.set(form); }

  save() {
    const form = this.editing(); if (!form) return;
    this.busy.set(true); this.error.set('');
    this.api.saveLearningVideo(this.editingId, form).subscribe({
      next: () => { this.busy.set(false); this.editing.set(null); this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo guardar el video.'); },
    });
  }

  remove() {
    if (!this.editingId) return;
    this.busy.set(true);
    this.api.deleteLearningVideo(this.editingId).subscribe({
      next: () => { this.busy.set(false); this.editing.set(null); this.load(); },
      error: e => { this.busy.set(false); this.error.set(e?.error?.message ?? 'No se pudo quitar el video.'); },
    });
  }

  move(index: number, delta: number) {
    const list = [...this.videos()];
    [list[index], list[index + delta]] = [list[index + delta], list[index]];
    this.videos.set(list); this.busy.set(true); this.listError.set('');
    this.api.reorderLearningVideos(list.map(v => v.id)).subscribe({
      next: () => this.busy.set(false),
      error: () => { this.busy.set(false); this.listError.set('No se pudo guardar el nuevo orden.'); this.load(); },
    });
  }
}
