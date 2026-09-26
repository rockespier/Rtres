import { Component, Input, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { StatusPillComponent } from '../status-pill/status-pill.component';
import { TicketTypePillComponent } from '../ticket-type-pill/ticket-type-pill.component';
import { ProjectDto, TicketDto } from '../../core/portal-api.service';

@Component({
  selector: 'app-ticket-table',
  standalone: true,
  imports: [CommonModule, RouterLink, StatusPillComponent, TicketTypePillComponent],
  template: `<div class="card overflow-x-auto mt-6">
    <table class="p-table">
      <thead><tr><th>Ticket</th><th class="hidden sm:table-cell">Tipo</th><th class="hidden md:table-cell">Proyecto</th><th class="hidden lg:table-cell">GitHub</th><th>Estado</th><th class="hidden sm:table-cell">Actualizado</th></tr></thead>
      <tbody>
        <tr *ngIf="!tickets.length"><td colspan="6" class="text-muted text-sm">No hay tickets que coincidan.</td></tr>
        <tr *ngFor="let t of tickets" class="cursor-pointer" (click)="open(t)">
          <td><a [routerLink]="['/tickets', t.id]" class="font-medium hover:underline" (click)="$event.stopPropagation()">{{ t.title }}</a><p class="text-xs text-muted">#{{ t.code }}</p></td>
          <td class="hidden sm:table-cell"><app-ticket-type-pill [type]="t.type"/></td>
          <td class="hidden md:table-cell text-muted">{{ projectName(t.projectId) }}</td>
          <td class="hidden lg:table-cell"><a *ngIf="t.githubIssueUrl" [href]="t.githubIssueUrl" target="_blank" rel="noopener" class="text-accent" (click)="$event.stopPropagation()">issue #{{ t.githubIssueNumber }}</a><span *ngIf="!t.githubIssueUrl" class="text-muted">—</span></td>
          <td><app-status-pill [status]="t.status"/></td>
          <td class="hidden sm:table-cell text-muted">{{ t.updatedAt | date:'short' }}</td>
        </tr>
      </tbody>
    </table>
  </div>`,
})
export class TicketTableComponent {
  private router = inject(Router);
  @Input() tickets: TicketDto[] = [];
  @Input() projects: ProjectDto[] = [];

  projectName(id: string): string { return this.projects.find(p => p.id === id)?.slug ?? '—'; }
  open(t: TicketDto): void { this.router.navigate(['/tickets', t.id]); }
}
