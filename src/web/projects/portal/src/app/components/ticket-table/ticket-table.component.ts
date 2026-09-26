import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StatusPillComponent } from '../status-pill/status-pill.component';
import { TicketDto } from '../../core/portal-api.service';

@Component({
  selector: 'app-ticket-table',
  standalone: true,
  imports: [CommonModule, StatusPillComponent],
  template: `<div class="card overflow-x-auto mt-6">
    <table class="p-table">
      <thead><tr><th>Ticket</th><th class="hidden sm:table-cell">Tipo</th><th class="hidden md:table-cell">Proyecto</th><th class="hidden lg:table-cell">GitHub</th><th>Estado</th><th class="hidden sm:table-cell">Actualizado</th></tr></thead>
      <tbody>
        <tr *ngFor="let t of tickets">
          <td><p class="font-medium">{{ t.title }}</p><p class="text-xs text-muted">#{{ t.code }}</p></td>
          <td class="hidden sm:table-cell text-muted">{{ t.type }}</td>
          <td class="hidden md:table-cell text-muted">cabalgatas-andinas-web</td>
          <td class="hidden lg:table-cell"><a *ngIf="t.githubIssueUrl" [href]="t.githubIssueUrl" class="text-accent">issue #{{ t.githubIssueNumber }}</a><span *ngIf="!t.githubIssueUrl" class="text-muted">—</span></td>
          <td><app-status-pill [status]="t.status"/></td>
          <td class="hidden sm:table-cell text-muted">{{ t.updatedAt | date:'short' }}</td>
        </tr>
      </tbody>
    </table>
  </div>`,
})
export class TicketTableComponent {
  @Input() tickets: TicketDto[] = [];
}
