import { SORTABLE } from '../../core/sortable';
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService, TeamUserDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { TeamInviteDialogComponent } from '../team-invite-dialog/team-invite-dialog.component';

const EMPTY_GUID = '00000000-0000-0000-0000-000000000000';

@Component({
  selector: 'app-team',
  standalone: true,
  imports: [...SORTABLE,CommonModule, FormsModule, TeamInviteDialogComponent],
  template: `<div class="flex items-center justify-between">
    <h1 class="font-display text-2xl font-semibold">Equipo</h1>
    <button type="button" class="btn btn-primary btn-sm" *ngIf="!showInvite" (click)="showInvite = true">+ Invitar</button>
  </div>
  <p class="text-muted mt-1">Gestiona quién tiene acceso al portal de tu empresa.</p>

  <app-team-invite-dialog *ngIf="showInvite" (closed)="showInvite = false" (done)="showInvite = false; load()"/>

  <p *ngIf="error" class="text-sm text-red-600 mt-3">{{ error }}</p>

  <div class="card mt-6 overflow-x-auto">
    <table class="p-table w-full" appSort #s="appSort">
      <thead><tr><th sortKey="name">Nombre</th><th sortKey="email">Email</th><th sortKey="area">Área</th><th sortKey="jobTitle">Cargo</th><th [sortKey]="managerName">Jefe inmediato</th><th sortKey="role">Rol</th><th sortKey="isActive">Estado</th><th></th></tr></thead>
      <tbody>
        <tr *ngFor="let x of users | sortBy:s.key():s.dir()">
          <td>{{ x.name }}</td>
          <td class="text-muted">{{ x.email }}</td>
          <td><input class="field" maxlength="100" [(ngModel)]="x.area" (change)="update(x, { area: x.area ?? '' })" aria-label="Área"></td>
          <td><input class="field" maxlength="100" [(ngModel)]="x.jobTitle" (change)="update(x, { jobTitle: x.jobTitle ?? '' })" aria-label="Cargo"></td>
          <td><select class="field" [ngModel]="x.managerId ?? ''" (ngModelChange)="updateManager(x, $event)" aria-label="Jefe inmediato"><option value="">Sin jefe</option><option *ngFor="let m of managerOptions(x)" [value]="m.id">{{ m.name }}</option></select></td>
          <td><select class="field" [(ngModel)]="x.role" (change)="updateRole(x)"><option value="Cliente">Cliente</option><option value="Admin">Admin</option></select></td>
          <td><span class="pill" [class.pill-success]="x.isActive" [class.pill-neutral]="!x.isActive">{{ x.isActive ? 'Activo' : 'Inactivo' }}</span></td>
          <td><button type="button" class="btn btn-ghost btn-sm" (click)="toggle(x)">{{ x.isActive ? 'Desactivar' : 'Activar' }}</button></td>
        </tr>
      </tbody>
    </table>
  </div>`,
})
export class TeamComponent implements OnInit {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);

  users: TeamUserDto[] = [];
  showInvite = false;
  error = '';

  /** Ordena la columna Jefe inmediato por el nombre del jefe. */
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

  updateManager(user: TeamUserDto, managerId: string): void {
    user.managerId = managerId || null;
    this.update(user, { managerId: managerId || EMPTY_GUID });
  }

  /** Guarda un cambio; si el API lo rechaza muestra su mensaje y recarga para que la tabla refleje la base. */
  update(user: TeamUserDto, body: { area?: string; jobTitle?: string; managerId?: string }): void {
    this.error = '';
    this.api.updateTeam(user.id, body).subscribe({ error: e => { this.error = e?.error?.message ?? 'No se pudo guardar el cambio.'; this.load(); } });
  }

  private reportsTo(user: TeamUserDto, managerId: string): boolean {
    const seen = new Set<string>();
    for (let current = user.managerId; current && !seen.has(current); current = this.users.find(u => u.id === current)?.managerId ?? null) {
      if (current === managerId) return true;
      seen.add(current);
    }
    return false;
  }

  updateRole(user: TeamUserDto): void {
    this.api.updateTeam(user.id, { role: user.role }).subscribe();
  }

  toggle(user: TeamUserDto): void {
    this.api.updateTeam(user.id, { isActive: !user.isActive }).subscribe(() => { user.isActive = !user.isActive; });
  }
}
