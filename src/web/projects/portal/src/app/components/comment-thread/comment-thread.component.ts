import { Component, input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { TicketCommentDto } from '../../core/portal-api.service';

@Component({
  selector: 'app-comment-thread',
  standalone: true,
  imports: [CommonModule],
  template: `@if (!comments().length) {
      <p class="text-sm text-muted">Aún no hay mensajes. Si necesitas añadir contexto, escríbelo abajo.</p>
    }
    <ol class="space-y-5">
      @for (c of comments(); track c.id) {
        <li class="flex gap-3">
          <span class="grid place-items-center w-8 h-8 rounded-full text-xs font-semibold shrink-0"
            [style.background]="c.fromGithub ? 'var(--night)' : 'var(--lime)'" [style.color]="c.fromGithub ? 'var(--on-night)' : 'var(--on-lime)'">{{ initials(c) }}</span>
          <div class="min-w-0 flex-1">
            <div class="flex flex-wrap items-baseline gap-x-2">
              <span class="text-sm font-semibold">{{ author(c) }}</span>
              @if (c.fromGithub) { <span class="text-[11px] font-medium text-muted uppercase tracking-wider">Equipo</span> }
              <time class="text-xs text-muted" [attr.datetime]="c.createdAt">{{ c.createdAt | date:"d MMM, HH:mm" }}</time>
            </div>
            <p class="text-[14px] leading-relaxed mt-1.5 whitespace-pre-line rounded-[var(--radius-sm)] px-4 py-3"
              [style.background]="c.fromGithub ? 'var(--neutral-bg)' : 'var(--surface-tint)'">{{ c.body }}</p>
          </div>
        </li>
      }
    </ol>`,
})
export class CommentThreadComponent {
  comments = input<TicketCommentDto[]>([]);

  author(c: TicketCommentDto): string { return c.fromGithub ? 'Equipo Rtres' : (c.authorName || 'Cliente'); }

  initials(c: TicketCommentDto): string {
    if (c.fromGithub) return 'R3';
    return this.author(c).split(/[\s@.]+/).filter(Boolean).slice(0, 2).map(w => w[0]).join('').toUpperCase();
  }
}
