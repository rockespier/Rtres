import { Component, EventEmitter, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService } from '../../core/portal-api.service';

@Component({
  selector: 'app-team-invite-dialog',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `<div class="card mt-6 p-5">
    <div *ngIf="!temporaryPassword()">
      <label class="field-label">Nombre<input class="field mt-1" [(ngModel)]="name"></label>
      <label class="field-label mt-3 block">Email<input class="field mt-1" type="email" [(ngModel)]="email"></label>
      <p *ngIf="error()" class="text-red-600 text-sm mt-2">{{ error() }}</p>
      <div class="flex justify-end gap-3 mt-4">
        <button type="button" class="btn btn-ghost btn-sm" (click)="closed.emit()">Cancelar</button>
        <button type="button" class="btn btn-primary btn-sm" [disabled]="inviting()" (click)="invite()">{{ inviting() ? 'Creando…' : 'Crear invitación' }}</button>
      </div>
    </div>
    <div *ngIf="temporaryPassword()">
      <p class="text-sm text-muted">Comparte esta contraseña temporal con {{ name }} — no se volverá a mostrar.</p>
      <div class="flex items-center gap-3 mt-3">
        <code class="field flex-1">{{ temporaryPassword() }}</code>
        <button type="button" class="btn btn-ghost btn-sm" (click)="copy()">Copiar</button>
      </div>
      <div class="flex justify-end mt-4">
        <button type="button" class="btn btn-primary btn-sm" (click)="done.emit()">Listo</button>
      </div>
    </div>
  </div>`,
})
export class TeamInviteDialogComponent {
  private api = inject(PortalApiService);

  @Output() closed = new EventEmitter<void>();
  @Output() done = new EventEmitter<void>();

  name = '';
  email = '';
  inviting = signal(false);
  error = signal('');
  temporaryPassword = signal('');

  invite(): void {
    if (!this.name.trim() || !this.email.trim()) { this.error.set('Completa nombre y email.'); return; }
    this.inviting.set(true);
    this.error.set('');
    this.api.inviteTeam(this.name, this.email).subscribe({
      next: r => { this.temporaryPassword.set(r.temporaryPassword); this.inviting.set(false); },
      error: () => { this.error.set('No se pudo crear la invitación.'); this.inviting.set(false); },
    });
  }

  copy(): void {
    navigator.clipboard?.writeText(this.temporaryPassword());
  }
}
