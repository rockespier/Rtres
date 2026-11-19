import { SORTABLE } from '../../core/sortable';
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService, TeamUserDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { TeamInviteDialogComponent } from '../team-invite-dialog/team-invite-dialog.component';
import { ConfirmDialogComponent } from '../confirm-dialog/confirm-dialog.component';

const EMPTY_GUID = '00000000-0000-0000-0000-000000000000';

@Component({
  selector: 'app-team',
  standalone: true,
  imports: [...SORTABLE,CommonModule, FormsModule, TeamInviteDialogComponent, ConfirmDialogComponent],
  template: `<div class="flex items-center justify-between">
    <h1 class="font-display text-2xl font-semibold">Equipo</h1>
    <button type="button" class="btn btn-primary btn-sm" *ngIf="!showInvite" (click)="showInvite = true">+ Invitar</button>
  </div>
  <p class="text-muted mt-1">Gestiona quién tiene acceso al portal de tu empresa. Los <strong>Admin</strong> ven todo (servicios, pagos y equipo); los <strong>miembros</strong>, solo los tickets y su cuenta.</p>

  <app-team-invite-dialog *ngIf="showInvite" (closed)="showInvite = false" (done)="showInvite = false; load()"/>

  <p *ngIf="error" class="text-sm text-red-600 mt-3">{{ error }}</p>

  <div *ngIf="resetResult as r" class="card mt-6 p-5">
    <p *ngIf="r.emailSent" class="text-sm">Enviamos a <strong>{{ r.email }}</strong> un correo con una contraseña temporal nueva; la anterior ya no funciona. La tienes aquí por si no le llega — no se volverá a mostrar.</p>
    <p *ngIf="!r.emailSent" class="text-sm text-red-600">No se pudo enviar el correo a {{ r.email }}. Comparte esta contraseña temporal con {{ r.name }} — no se volverá a mostrar.</p>
    <div class="flex items-center gap-3 mt-3">
      <code class="field flex-1">{{ r.temporaryPassword }}</code>
      <button type="button" class="btn btn-ghost btn-sm" (click)="copy(r.temporaryPassword)">Copiar</button>
    </div>
    <div class="flex justify-end mt-4"><button type="button" class="btn btn-primary btn-sm" (click)="resetResult = null">Listo</button></div>
  </div>

  <app-confirm-dialog *ngIf="resetTarget as t" title="Restablecer acceso"
    [message]="'Se creará una contraseña temporal nueva para ' + t.name + ' y se enviará a ' + t.email + '. La contraseña actual dejará de funcionar.'"
    confirmLabel="Restablecer" busyLabel="Restableciendo…" [busy]="resetBusy" [error]="resetError"
    (confirmed)="resetAccess(t)" (cancelled)="resetTarget = null"/>

  <div class="fixed inset-0 z-50 bg-black/40 grid place-items-center p-4" *ngIf="editing as e">
    <form class="card p-6 w-full max-w-lg space-y-3 max-h-[90vh] overflow-y-auto" (ngSubmit)="save()">
      <div>
        <h2 class="font-display text-xl">Editar usuario</h2>
        <p class="text-sm text-muted break-all">{{ e.user.name }} · {{ e.user.email }}</p>
      </div>
      <label class="field-label">Área<input class="field" maxlength="100" [(ngModel)]="e.area" name="area"></label>
      <label class="field-label">Cargo<input class="field" maxlength="100" [(ngModel)]="e.jobTitle" name="jobTitle"></label>
      <label class="field-label">Jefe inmediato<select class="field" [(ngModel)]="e.managerId" name="managerId"><option value="">Sin jefe</option><option *ngIf="inactiveManager(e.user) as m" [value]="m.id">{{ m.name }} (inactivo)</option><option *ngFor="let m of managerOptions(e.user)" [value]="m.id">{{ m.name }}</option></select></label>
      <label class="field-label">Rol<select class="field" [(ngModel)]="e.role" name="role"><option value="Cliente">Miembro: solo tickets y su cuenta</option><option value="Admin">Admin: todo (servicios, pagos y equipo)</option></select></label>
      <p *ngIf="editError" class="text-sm text-red-600">{{ editError }}</p>
      <div class="flex gap-2 pt-1">
        <button class="btn btn-primary btn-sm" [disabled]="saving">{{ saving ? 'Guardando…' : 'Guardar' }}</button>
        <button type="button" class="btn btn-ghost btn-sm" (click)="editing = null">Cancelar</button>
      </div>
    </form>
  </div>

  <div class="card mt-6 overflow-x-auto">
    <table class="p-table w-full min-w-[820px]" appSort="name" #s="appSort">
      <thead><tr><th sortKey="name">Usuario</th><th sortKey="area">Área y cargo</th><th [sortKey]="managerName">Jefe inmediato</th><th sortKey="role">Rol</th><th sortKey="isActive">Estado</th><th><span class="sr-only">Acciones</span></th></tr></thead>
      <tbody>
        <tr *ngFor="let x of users | sortBy:s.key():s.dir()" class="align-top">
          <td>
            <div class="font-medium">{{ x.name }}</div>
            <div class="text-muted text-xs break-all">{{ x.email }}</div>
          </td>
          <td>
            <div>{{ x.area || '—' }}</div>
            <div class="text-muted text-xs">{{ x.jobTitle || 'Sin cargo' }}</div>
          </td>
          <td>{{ managerName(x) || '—' }}</td>
          <td class="whitespace-nowrap">
            <span class="pill" [class.pill-info]="x.role === 'Admin'" [class.pill-neutral]="x.role !== 'Admin'">{{ x.role === 'Admin' ? 'Admin' : 'Miembro' }}</span>
            <div class="text-muted text-xs mt-1">{{ x.role === 'Admin' ? 'Ve todo' : 'Tickets y su cuenta' }}</div>
          </td>
          <td class="whitespace-nowrap"><span class="pill" [class.pill-success]="x.isActive" [class.pill-neutral]="!x.isActive">{{ x.isActive ? 'Activo' : 'Inactivo' }}</span></td>
          <td>
            <div class="flex flex-wrap justify-end gap-1">
              <button type="button" class="btn btn-ghost btn-sm" (click)="openEdit(x)" [attr.aria-label]="'Editar ' + x.name">Editar</button>
              <button type="button" class="btn btn-ghost btn-sm" *ngIf="x.isActive" (click)="resetTarget = x; resetError = ''" title="Envía una contraseña temporal nueva a quien olvidó la suya">Restablecer acceso</button>
              <button type="button" class="btn btn-ghost btn-sm" (click)="toggle(x)">{{ x.isActive ? 'Desactivar' : 'Activar' }}</button>
            </div>
          </td>
        </tr>
      </tbody>
    </table>
  </div>`,
})
export class TeamComponent implements OnInit {
  private readonly api = inject(PortalApiService);
  private readonly ui = inject(PortalUiService);

  users: TeamUserDto[] = [];
  showInvite = false;
  error = '';
  /** Restablecer acceso: usuario a confirmar, estado de la petición y contraseña temporal resultante. */
  resetTarget: TeamUserDto | null = null;
  resetBusy = false;
  resetError = '';
  resetResult: { name: string; email: string; temporaryPassword: string; emailSent: boolean } | null = null;

  /** Usuario en edición: copia de sus campos hasta guardar. */
  editing: { user: TeamUserDto; area: string; jobTitle: string; managerId: string; role: TeamUserDto['role'] } | null = null;
  saving = false;
  editError = '';

  /** Nombre del jefe inmediato; también ordena esa columna. */
  managerName = (x: TeamUserDto) => this.users.find(u => u.id === x.managerId)?.name ?? '';

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Equipo' });
    this.load();
  }

  load(): void {
    this.api.getTeam().subscribe(x => this.users = x);
  }

  /** Otros usuarios activos que pueden ser jefe de este: se excluye él mismo y quienes dependen de él (cerrarían un ciclo). */
  managerOptions(user: TeamUserDto): TeamUserDto[] {
    return this.users.filter(u => u.isActive && u.id !== user.id && !this.reportsTo(u, user.id));
  }

  /** Jefe actual que ya no está activo: se muestra aparte para que el select refleje lo guardado. */
  inactiveManager(user: TeamUserDto): TeamUserDto | undefined {
    return this.users.find(u => u.id === user.managerId && !u.isActive);
  }

  openEdit(user: TeamUserDto): void {
    this.editError = '';
    this.editing = { user, area: user.area ?? '', jobTitle: user.jobTitle ?? '', managerId: user.managerId ?? '', role: user.role };
  }

  /** Guarda todos los campos en un solo cambio; si el API lo rechaza, el diálogo queda abierto con su mensaje. */
  save(): void {
    const e = this.editing;
    if (!e) return;
    this.saving = true;
    this.editError = '';
    this.api.updateTeam(e.user.id, { area: e.area, jobTitle: e.jobTitle, managerId: e.managerId || EMPTY_GUID, role: e.role }).subscribe({
      next: () => { this.saving = false; this.editing = null; this.load(); },
      error: err => { this.saving = false; this.editError = err?.error?.message ?? 'No se pudo guardar el cambio.'; },
    });
  }

  private reportsTo(user: TeamUserDto, managerId: string): boolean {
    const seen = new Set<string>();
    for (let current = user.managerId; current && !seen.has(current); current = this.users.find(u => u.id === current)?.managerId ?? null) {
      if (current === managerId) return true;
      seen.add(current);
    }
    return false;
  }

  resetAccess(user: TeamUserDto): void {
    this.resetBusy = true;
    this.resetError = '';
    this.api.resetTeamAccess(user.id).subscribe({
      next: r => { this.resetResult = { name: user.name, email: user.email, ...r }; this.resetTarget = null; this.resetBusy = false; },
      error: e => { this.resetError = e?.error?.message ?? 'No se pudo restablecer el acceso.'; this.resetBusy = false; },
    });
  }

  copy(text: string): void {
    void navigator.clipboard?.writeText(text);
  }

  toggle(user: TeamUserDto): void {
    this.error = '';
    this.api.updateTeam(user.id, { isActive: !user.isActive }).subscribe({ next: () => { user.isActive = !user.isActive; }, error: e => { this.error = e?.error?.message ?? 'No se pudo guardar el cambio.'; } });
  }
}
