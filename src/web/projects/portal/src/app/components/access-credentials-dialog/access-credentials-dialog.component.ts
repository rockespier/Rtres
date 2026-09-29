import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ClientAccessDto } from '../../core/portal-api.service';

/** Muestra una sola vez las credenciales generadas (alta, importación o "Generar acceso") para copiarlas y entregarlas. */
@Component({
  selector: 'app-access-credentials-dialog',
  standalone: true,
  imports: [CommonModule],
  // Con muchos clientes importados la tabla crece: el diálogo se limita al alto de la pantalla y solo la tabla hace
  // scroll, así el título y los botones (Listo) siempre quedan visibles.
  template: `<div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4">
    <div class="card p-6 w-full max-w-5xl max-h-[90vh] flex flex-col gap-4" role="dialog" aria-modal="true" [attr.aria-label]="accesses.length === 1 ? 'Acceso del cliente' : 'Accesos de los clientes'">
      <div class="shrink-0 space-y-2">
        <h2 class="font-display text-xl">{{ accesses.length === 1 ? 'Acceso del cliente' : 'Accesos de los clientes (' + accesses.length + ')' }}</h2>
        <p class="text-sm text-muted">Cada cliente recibe por correo su usuario y contraseña temporal. Si el correo no salió, entrégaselos tú por un canal seguro: <strong>la contraseña no se volverá a mostrar</strong>. El cliente puede cambiarla en Perfil. Portal: <code>{{ portalUrl }}</code></p>
      </div>
      <div class="overflow-auto min-h-0 flex-1 border border-[var(--border)] rounded-lg">
        <table class="p-table w-full">
          <thead class="sticky top-0 z-10 portal-surface"><tr><th>Cliente</th><th>Usuario (email)</th><th>Contraseña temporal</th><th>Correo</th><th></th></tr></thead>
          <tbody>
            <tr *ngFor="let a of accesses">
              <td>{{ a.clientName }}</td>
              <td class="whitespace-nowrap">{{ a.email }}</td>
              <td class="whitespace-nowrap"><code>{{ a.temporaryPassword }}</code></td>
              <td><span class="pill whitespace-nowrap" [class.pill-success]="a.emailSent" [class.pill-danger]="!a.emailSent">{{ a.emailSent ? 'Enviado' : 'No enviado' }}</span></td>
              <td class="text-right"><button type="button" class="btn btn-ghost btn-sm" (click)="copy(a)">{{ copied === a ? 'Copiado' : 'Copiar' }}</button></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="shrink-0 flex justify-end gap-2">
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
