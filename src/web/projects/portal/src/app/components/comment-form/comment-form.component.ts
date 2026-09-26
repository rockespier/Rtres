import { Component, EventEmitter, Input, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { PortalApiService, TicketCommentDto } from '../../core/portal-api.service';

@Component({
  selector: 'app-comment-form',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  template: `<form [formGroup]="form" (ngSubmit)="submit()" class="mt-5">
    <label class="field-label" for="comment-body">Agregar comentario</label>
    <textarea id="comment-body" class="field" rows="3" formControlName="body" placeholder="Escribe tu mensaje para el equipo…"></textarea>
    <p *ngIf="error()" class="text-red-600 text-sm mt-2">{{ error() }}</p>
    <div class="flex justify-end mt-3">
      <button type="submit" class="btn btn-primary btn-sm" [disabled]="sending() || body.invalid">{{ sending() ? 'Enviando…' : 'Comentar' }}</button>
    </div>
  </form>`,
})
export class CommentFormComponent {
  private api = inject(PortalApiService);
  @Input({ required: true }) ticketId!: string;
  @Output() added = new EventEmitter<TicketCommentDto>();

  body = new FormControl('', { nonNullable: true, validators: [Validators.required, Validators.pattern(/\S/)] });
  form = new FormGroup({ body: this.body });
  sending = signal(false);
  error = signal('');

  submit(): void {
    if (this.body.invalid) return;
    this.sending.set(true);
    this.error.set('');
    this.api.addTicketComment(this.ticketId, this.body.value).subscribe({
      next: c => { this.added.emit(c); this.body.reset(); this.sending.set(false); },
      error: () => { this.error.set('No se pudo enviar el comentario.'); this.sending.set(false); },
    });
  }
}
