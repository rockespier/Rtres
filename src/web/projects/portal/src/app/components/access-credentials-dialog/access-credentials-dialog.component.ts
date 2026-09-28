import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClientAccessDto } from '../../core/portal-api.service';

/** Muestra una sola vez las credenciales generadas (alta, importación o "Generar acceso") para copiarlas y entregarlas. */
@Component({
  selector: 'app-access-credentials-dialog',
  standalone: true,
  imports: [CommonModule],
  template: `<div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4">
    <div class="card p-6 w-full max-w-2xl space-y-4">
      <h2 class="font-display text-xl">{{ accesses.length === 1 ? 'Acceso del cliente' : 'Accesos de los clientes' }}</h2>
      <p class="text-sm text-muted">Entrega estos datos a cada cliente por un canal seguro. <strong>La contraseña temporal no se volverá a mostrar</strong>; el cliente puede cambiarla en Perfil. Portal: <code>{{ portalUrl }}</code></p>
      <div class="overflow-x-auto">
        <table class="p-table w-full">
          <thead><tr><th>Cliente</th><th>Usuario (email)</th><th>Contraseña temporal</th><th></th></tr></thead>
          <tbody>
            <tr *ngFor="let a of accesses">
              <td>{{ a.clientName }}</td>
              <td>{{ a.email }}</td>
              <td><code>{{ a.temporaryPassword }}</code></td>
              <td><button type="button" class="btn btn-ghost btn-sm" (click)="copy(a)">{{ copied === a ? 'Copiado' : 'Copiar' }}</button></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="flex justify-end gap-2">
        <button *ngIf="accesses.length > 1" type="button" class="btn btn-ghost btn-sm" (click)="copyAll()">Copiar todo</button>
        <button type="button" class="btn btn-primary btn-sm" (click)="done.emit()">Listo</button>
      </div>
    </div>
  </div>`,
})
export class AccessCredentialsDialogComponent {
  @Input({ required: true }) accesses: ClientAccessDto[] = [];
  @Output() done = new EventEmitter<void>();
  portalUrl = location.origin;
  copied: ClientAccessDto | null = null;

  private text(a: ClientAccessDto): string {
    return `Portal de clientes Rtres: ${this.portalUrl}\nUsuario: ${a.email}\nContraseña temporal: ${a.temporaryPassword}`;
  }
  copy(a: ClientAccessDto): void { navigator.clipboard?.writeText(this.text(a)); this.copied = a; }
  copyAll(): void { navigator.clipboard?.writeText(this.accesses.map(a => `${a.clientName}\n${this.text(a)}`).join('\n\n')); }
}
