import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { PortalApiService, TicketCommentDto, TicketDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { AuthService } from '../../core/auth.service';
import { StatusPillComponent } from '../status-pill/status-pill.component';
import { TicketTypePillComponent } from '../ticket-type-pill/ticket-type-pill.component';
import { CommentThreadComponent } from '../comment-thread/comment-thread.component';
import { CommentFormComponent } from '../comment-form/comment-form.component';

@Component({
  selector: 'app-ticket-detail',
  standalone: true,
  imports: [CommonModule, StatusPillComponent, TicketTypePillComponent, CommentThreadComponent, CommentFormComponent],
  template: `<p *ngIf="notFound()" class="text-muted">No encontramos este ticket.</p>
    <ng-container *ngIf="ticket() as t">
      <div class="flex flex-wrap items-center gap-2 text-sm text-muted">
        <span>#{{ t.code }}</span><app-ticket-type-pill [type]="t.type"/><app-status-pill [status]="t.status"/>
      </div>
      <h1 class="font-display text-2xl font-semibold mt-2">{{ t.title }}</h1>
      <p class="text-sm text-muted mt-1">
        Creado {{ t.createdAt | date:'medium' }} · Actualizado {{ t.updatedAt | date:'medium' }}
        <ng-container *ngIf="t.githubIssueUrl"> · <a [href]="t.githubIssueUrl" target="_blank" rel="noopener" class="text-accent">issue #{{ t.githubIssueNumber }} en GitHub</a></ng-container>
      </p>
      <div class="grid lg:grid-cols-[1fr_360px] gap-6 mt-6">
        <div class="card p-6 space-y-5">
          <section *ngFor="let f of fields(t)">
            <h2 class="field-label">{{ f.label }}</h2>
            <p class="text-sm whitespace-pre-line">{{ f.value }}</p>
          </section>
        </div>
        <div class="card p-6">
          <h2 class="font-display text-lg font-semibold mb-4">Comentarios</h2>
          <app-comment-thread [comments]="comments()"/>
          <app-comment-form *ngIf="canComment()" [ticketId]="t.id" (added)="onAdded($event)"/>
        </div>
      </div>
    </ng-container>`,
})
export class TicketDetailComponent implements OnInit {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  private auth = inject(AuthService);
  private route = inject(ActivatedRoute);

  ticket = signal<TicketDto | null>(null);
  comments = signal<TicketCommentDto[]>([]);
  notFound = signal(false);

  ngOnInit(): void {
    this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: 'Detalle' });
    this.api.getTicket(this.route.snapshot.paramMap.get('id')!).subscribe({
      next: r => {
        this.ticket.set(r.ticket);
        this.comments.set(r.comments);
        this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: r.ticket.code });
      },
      error: () => this.notFound.set(true),
    });
  }

  canComment(): boolean { return this.auth.user()?.role !== 'SuperAdmin'; }

  onAdded(comment: TicketCommentDto): void { this.comments.update(list => [...list, comment]); }

  fields(t: TicketDto): { label: string; value: string }[] {
    const all: [string, string | null][] = [
      ['Descripción', t.description],
      ['Comportamiento actual', t.currentBehavior],
      ['Comportamiento esperado', t.expectedBehavior],
      ['Pasos para reproducir', t.stepsToReproduce],
      ['Entorno', t.environment],
      ['Criterios de aceptación', t.acceptanceCriteria],
      ['Impacto / alcance estimado', t.estimatedImpact],
    ];
    return all.filter(([, v]) => !!v?.trim()).map(([label, value]) => ({ label, value: value! }));
  }
}
