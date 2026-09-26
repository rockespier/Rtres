import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService, TeamUserDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { TeamInviteDialogComponent } from '../team-invite-dialog/team-invite-dialog.component';

@Component({
  selector: 'app-team',
  standalone: true,
  imports: [CommonModule, FormsModule, TeamInviteDialogComponent],
  template: `<div class="flex items-center justify-between">
    <h1 class="font-display text-2xl font-semibold">Equipo</h1>
    <button type="button" class="btn btn-primary btn-sm" *ngIf="!showInvite" (click)="showInvite = true">+ Invitar</button>
  </div>
  <p class="text-muted mt-1">Gestiona quién tiene acceso al portal de tu empresa.</p>

  <app-team-invite-dialog *ngIf="showInvite" (closed)="showInvite = false" (done)="showInvite = false; load()"/>

  <div class="card mt-6 overflow-x-auto">
    <table class="p-table w-full">
      <thead><tr><th>Nombre</th><th>Email</th><th>Rol</th><th>Estado</th><th></th></tr></thead>
      <tbody>
        <tr *ngFor="let x of users">
          <td>{{ x.name }}</td>
          <td class="text-muted">{{ x.email }}</td>
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

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: 'Equipo' });
    this.load();
  }

  load(): void {
    this.api.getTeam().subscribe(x => this.users = x);
  }

  updateRole(user: TeamUserDto): void {
    this.api.updateTeam(user.id, { role: user.role }).subscribe();
  }

  toggle(user: TeamUserDto): void {
    this.api.updateTeam(user.id, { isActive: !user.isActive }).subscribe(() => { user.isActive = !user.isActive; });
  }
}
