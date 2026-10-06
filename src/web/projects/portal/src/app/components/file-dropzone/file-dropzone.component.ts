import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

/** Mismos límites que PortalController.CreateTicket: se validan aquí para avisar antes de enviar. */
export const MAX_ATTACHMENTS = 5;
export const MAX_ATTACHMENT_BYTES = 10 * 1024 * 1024;

@Component({
  selector: 'app-file-dropzone',
  standalone: true,
  imports: [CommonModule],
  template: `<label class="block border border-dashed rounded-xl px-4 py-6 text-center text-sm cursor-pointer transition-colors"
      [class.text-muted]="!dragging()" [style.background]="dragging() ? 'var(--neutral-bg)' : null" [style.border-color]="dragging() ? 'var(--ink, currentColor)' : null"
      (dragenter)="onDrag($event, true)" (dragover)="onDrag($event, true)" (dragleave)="onDrag($event, false)" (drop)="onDrop($event)">
      {{ dragging() ? 'Suelta los archivos aquí' : 'Arrastra capturas, logs o haz clic para adjuntar' }}
      <span class="block text-xs text-muted mt-1">Hasta {{ max }} archivos de 10 MB. También puedes pegar una captura (Ctrl+V).</span>
      <input class="hidden" type="file" multiple (change)="onSelect($event)">
    </label>
    <p *ngIf="error()" class="text-sm text-red-600 mt-2">{{ error() }}</p>
    <ul *ngIf="files().length" class="mt-2 space-y-1">
      <li *ngFor="let f of files(); let i = index" class="flex items-center justify-between gap-2 text-sm rounded-md border px-3 py-1.5">
        <span class="truncate">{{ f.name }} <span class="text-xs text-muted">· {{ size(f.size) }}</span></span>
        <button type="button" class="btn btn-ghost btn-sm" [attr.aria-label]="'Quitar ' + f.name" (click)="remove(i)">Quitar</button>
      </li>
    </ul>`,
  host: { '(document:paste)': 'onPaste($event)' },
})
export class FileDropzoneComponent {
  readonly max = MAX_ATTACHMENTS;
  files = signal<File[]>([]);
  dragging = signal(false);
  error = signal('');

  onDrag(e: DragEvent, over: boolean) {
    e.preventDefault();
    // dragleave también salta al pasar sobre un hijo: solo se apaga si se sale del label.
    if (!over && e.currentTarget instanceof Node && e.relatedTarget instanceof Node && e.currentTarget.contains(e.relatedTarget)) return;
    this.dragging.set(over);
  }

  onDrop(e: DragEvent) {
    e.preventDefault();
    this.dragging.set(false);
    this.add(Array.from(e.dataTransfer?.files ?? []));
  }

  onSelect(e: Event) {
    const input = e.target as HTMLInputElement;
    this.add(Array.from(input.files ?? []));
    input.value = ''; // permite volver a elegir el mismo archivo tras quitarlo
  }

  /** Capturas pegadas desde el portapapeles (sin nombre propio). */
  onPaste(e: ClipboardEvent) {
    const pasted = Array.from(e.clipboardData?.files ?? []);
    if (!pasted.length) return;
    e.preventDefault();
    this.add(pasted.map((f, i) => new File([f], f.name && f.name !== 'image.png' ? f.name : `captura-${Date.now()}${i ? '-' + i : ''}.png`, { type: f.type })));
  }

  remove(i: number) {
    this.files.update(list => list.filter((_, j) => j !== i));
    this.error.set('');
  }

  size(bytes: number) {
    return bytes < 1024 * 1024 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1024 / 1024).toFixed(1)} MB`;
  }

  private add(incoming: File[]) {
    this.error.set('');
    const tooBig = incoming.filter(f => f.size > MAX_ATTACHMENT_BYTES || f.size === 0);
    const valid = incoming.filter(f => !tooBig.includes(f));
    const room = MAX_ATTACHMENTS - this.files().length;
    if (tooBig.length) this.error.set(`${tooBig.map(f => f.name).join(', ')}: vacío o mayor a 10 MB.`);
    if (valid.length > room) this.error.set(`Máximo ${MAX_ATTACHMENTS} archivos por ticket.`);
    this.files.update(list => [...list, ...valid.slice(0, Math.max(0, room))]);
  }
}
