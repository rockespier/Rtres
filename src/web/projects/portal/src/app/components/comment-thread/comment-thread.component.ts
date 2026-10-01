import { Component, input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TicketCommentDto } from '../../core/portal-api.service';

@Component({
  selector: 'app-comment-thread',
  standalone: true,
  imports: [CommonModule],
  template: `<p *ngIf="!comments().length" class="text-sm text-muted">Aún no hay comentarios.</p>
    <ol class="space-y-4">
      <li *ngFor="let c of comments()" class="border-b pb-4 last:border-b-0 last:pb-0">
        <div class="flex flex-wrap items-center gap-2 text-sm">
          <span class="font-medium">{{ c.fromGithub ? 'Equipo Rtres' : (c.authorName || 'Cliente') }}</span>
          <span class="text-xs text-muted">{{ c.createdAt | date:'short' }}</span>
        </div>
        <p class="text-sm mt-2 whitespace-pre-line">{{ c.body }}</p>
      </li>
    </ol>`,
})
export class CommentThreadComponent {
  comments = input<TicketCommentDto[]>([]);
}
