import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { PortalApiService, TicketAttachmentDto, TicketCommentDto, TicketDetailDto, TicketDto } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { AuthService } from '../../core/auth.service';
import { StatusPillComponent } from '../status-pill/status-pill.component';
import { TicketTypePillComponent } from '../ticket-type-pill/ticket-type-pill.component';
import { CommentThreadComponent } from '../comment-thread/comment-thread.component';
import { CommentFormComponent } from '../comment-form/comment-form.component';
import { IconComponent } from '../icon/icon.component';

/** Flujo normal del ticket; Cerrado queda fuera porque es un cierre sin resolver. */
const STEPS: { status: TicketDto['status']; label: string }[] = [
  { status: 'Abierto', label: 'Recibido' },
  { status: 'EnProgreso', label: 'En progreso' },
  { status: 'Resuelto', label: 'Resuelto' },
  { status: 'Publicado', label: 'Publicado' },
];

@Component({
  selector: 'app-ticket-detail',
  standalone: true,
  imports: [CommonModule, RouterLink, StatusPillComponent, TicketTypePillComponent, CommentThreadComponent, CommentFormComponent, IconComponent],
  styles: [`
    .td-label{font-size:11px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);}
    .td-meta dt{font-size:12.5px;color:var(--muted);}
    .td-meta dd{font-size:13.5px;font-weight:500;text-align:right;min-width:0;overflow-wrap:anywhere;}
    .td-step{flex:1;display:flex;flex-direction:column;gap:8px;min-width:0;}
    .td-bar{height:4px;border-radius:99px;background:var(--neutral-border);}
    .td-step.done .td-bar{background:var(--primary);}
    .td-step.current .td-bar{background:linear-gradient(90deg,var(--primary) 50%,var(--neutral-border) 50%);}
    .td-thumb{aspect-ratio:4/3;border-radius:var(--radius-sm);border:1px solid var(--border);overflow:hidden;background:var(--neutral-bg);display:grid;place-items:center;}
    .td-thumb img{width:100%;height:100%;object-fit:cover;transition:transform .3s var(--ease-out);}
    .td-thumb:hover img{transform:scale(1.03);}
  `],
  template: `
    @if (notFound()) {
      <div class="card p-10 text-center max-w-lg mx-auto mt-10">
        <p class="font-display text-lg font-semibold">No encontramos este ticket</p>
        <p class="text-sm text-muted mt-1">Puede que no exista o que pertenezca a otro cliente.</p>
        <a routerLink="/tickets" class="btn btn-ghost btn-sm mt-5">Volver a tickets</a>
      </div>
    }
    @if (detail(); as d) {
      @let t = d.ticket;
      <header class="max-w-6xl">
        <div class="flex flex-wrap items-center gap-2">
          <span class="font-mono text-xs text-muted">{{ t.code }}</span>
          <app-ticket-type-pill [type]="t.type"/>
          <app-status-pill [status]="t.status"/>
        </div>
        <h1 class="font-display text-3xl font-semibold tracking-tight mt-3 leading-tight">{{ t.title || 'Sin título' }}</h1>
        <p class="text-sm text-muted mt-2">
          {{ d.projectName }}@if (d.componentName) { · {{ d.componentName }}} · Abierto por {{ d.createdByName || 'el cliente' }} el {{ t.createdAt | date:"d 'de' MMMM, y" }}
        </p>

        @if (t.status !== 'Cerrado') {
          <ol class="flex gap-3 mt-7" aria-label="Progreso del ticket">
            @for (s of steps; track s.status; let i = $index) {
              <li class="td-step" [class.done]="i < stepIndex(t)" [class.current]="i === stepIndex(t)" [attr.aria-current]="i === stepIndex(t) ? 'step' : null">
                <span class="td-bar"></span>
                <span class="text-xs" [class.font-semibold]="i <= stepIndex(t)" [class.text-muted]="i > stepIndex(t)">{{ s.label }}</span>
              </li>
            }
          </ol>
        } @else {
          <p class="pill pill-danger mt-6">Ticket cerrado sin cambios</p>
        }
      </header>

      <div class="grid lg:grid-cols-[minmax(0,1fr)_320px] gap-6 mt-8 max-w-6xl items-start">
        <div class="space-y-6 min-w-0">
          <article class="card">
            <div class="px-6 py-4 border-b border-[var(--border)]"><h2 class="font-display text-base font-semibold">Detalle de la solicitud</h2></div>
            <div class="divide-y divide-[var(--border)]">
              @for (f of fields(t); track f.label) {
                <section class="px-6 py-5">
                  <h3 class="td-label">{{ f.label }}</h3>
                  <p class="text-[14.5px] leading-relaxed mt-2 whitespace-pre-line">{{ f.value }}</p>
                </section>
              }
            </div>
          </article>

          @if (d.attachments.length) {
            <section class="card">
              <div class="px-6 py-4 border-b border-[var(--border)] flex items-center gap-2">
                <app-icon name="paperclip" [size]="16"/>
                <h2 class="font-display text-base font-semibold">Adjuntos</h2>
                <span class="text-xs text-muted">{{ d.attachments.length }}</span>
              </div>
              <div class="p-6 space-y-4">
                @if (images(d).length) {
                  <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                    @for (a of images(d); track a.id) {
                      <button type="button" class="td-thumb" [attr.aria-label]="'Ver ' + a.fileName" (click)="preview.set(a)">
                        @if (urls()[a.id]) { <img [src]="urls()[a.id]" [alt]="a.fileName"> } @else { <span class="text-xs text-muted">Cargando…</span> }
                      </button>
                    }
                  </div>
                }
                @for (a of files(d); track a.id) {
                  <div class="flex items-center gap-3 rounded-[var(--radius-sm)] border border-[var(--border)] px-4 py-3">
                    <app-icon name="file" [size]="18"/>
                    <div class="min-w-0 flex-1"><p class="text-sm font-medium truncate">{{ a.fileName }}</p><p class="text-xs text-muted">{{ size(a.sizeBytes) }}</p></div>
                    <button type="button" class="btn btn-ghost btn-sm" (click)="download(a)"><app-icon name="download" [size]="15"/> Descargar</button>
                  </div>
                }
              </div>
            </section>
          }

          <section class="card">
            <div class="px-6 py-4 border-b border-[var(--border)] flex items-center gap-2">
              <app-icon name="message" [size]="16"/>
              <h2 class="font-display text-base font-semibold">Conversación</h2>
              @if (comments().length) { <span class="text-xs text-muted">{{ comments().length }}</span> }
            </div>
            <div class="p-6">
              <app-comment-thread [comments]="comments()"/>
              @if (canComment()) { <app-comment-form [ticketId]="t.id" (added)="onAdded($event)"/> }
            </div>
          </section>
        </div>

        <aside class="card p-6 lg:sticky lg:top-24">
          <h2 class="td-label">Resumen</h2>
          <dl class="td-meta mt-4 space-y-3">
            <div class="flex justify-between gap-4"><dt>Estado</dt><dd><app-status-pill [status]="t.status"/></dd></div>
            <div class="flex justify-between gap-4"><dt>Tipo</dt><dd><app-ticket-type-pill [type]="t.type"/></dd></div>
            <div class="flex justify-between gap-4"><dt>Proyecto</dt><dd>{{ d.projectName }}</dd></div>
            @if (d.componentName) { <div class="flex justify-between gap-4"><dt>Componente</dt><dd>{{ d.componentName }}</dd></div> }
            <div class="flex justify-between gap-4"><dt>Solicitado por</dt><dd>{{ d.createdByName || '—' }}</dd></div>
            <div class="flex justify-between gap-4"><dt>Creado</dt><dd>{{ t.createdAt | date:'dd/MM/yyyy HH:mm' }}</dd></div>
            <div class="flex justify-between gap-4"><dt>Última actualización</dt><dd>{{ t.updatedAt | date:'dd/MM/yyyy HH:mm' }}</dd></div>
          </dl>
          @if (isAdmin() && t.githubIssueUrl) {
            <a [href]="t.githubIssueUrl" target="_blank" rel="noopener" class="btn btn-ghost btn-sm w-full mt-6 justify-center"><app-icon name="external-link" [size]="15"/> Issue #{{ t.githubIssueNumber }} en GitHub</a>
          }
          <p class="text-xs text-muted mt-6 leading-relaxed">Te avisaremos por correo cuando el equipo responda o cambie el estado.</p>
        </aside>
      </div>

      @if (preview(); as p) {
        <div class="fixed inset-0 z-50 grid place-items-center bg-black/70 p-4" role="dialog" aria-modal="true" [attr.aria-label]="p.fileName" (click)="preview.set(null)">
          <figure class="max-w-5xl w-full" (click)="$event.stopPropagation()">
            <img [src]="urls()[p.id]" [alt]="p.fileName" class="max-h-[80vh] mx-auto rounded-lg shadow-2xl">
            <figcaption class="flex items-center justify-between gap-3 mt-3 text-sm text-white">
              <span class="truncate">{{ p.fileName }} · {{ size(p.sizeBytes) }}</span>
              <span class="flex gap-2">
                <button type="button" class="btn btn-sm bg-white/10 text-white border-white/20" (click)="download(p)"><app-icon name="download" [size]="15"/> Descargar</button>
                <button type="button" class="btn btn-sm bg-white/10 text-white border-white/20" aria-label="Cerrar" (click)="preview.set(null)"><app-icon name="x" [size]="15"/></button>
              </span>
            </figcaption>
          </figure>
        </div>
      }
    }`,
  host: { '(document:keydown.escape)': 'preview.set(null)' },
})
export class TicketDetailComponent implements OnInit, OnDestroy {
  private api = inject(PortalApiService);
  private ui = inject(PortalUiService);
  private auth = inject(AuthService);
  private route = inject(ActivatedRoute);

  readonly steps = STEPS;
  detail = signal<TicketDetailDto | null>(null);
  comments = signal<TicketCommentDto[]>([]);
  notFound = signal(false);
  /** Object URLs de las imágenes (la descarga necesita el token, no sirve un src directo). */
  urls = signal<Record<string, string>>({});
  preview = signal<TicketAttachmentDto | null>(null);

  ngOnInit(): void {
    this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: 'Detalle' });
    this.api.getTicket(this.route.snapshot.paramMap.get('id')!).subscribe({
      next: d => {
        this.detail.set(d);
        this.comments.set(d.comments);
        this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: d.ticket.code });
        for (const a of this.images(d)) this.api.getTicketAttachment(d.ticket.id, a.id).subscribe(blob => this.urls.update(u => ({ ...u, [a.id]: URL.createObjectURL(blob) })));
      },
      error: () => this.notFound.set(true),
    });
  }

  ngOnDestroy(): void { Object.values(this.urls()).forEach(URL.revokeObjectURL); }

  canComment(): boolean { return this.auth.user()?.role !== 'SuperAdmin'; }
  isAdmin(): boolean { return this.auth.user()?.role === 'SuperAdmin'; }

  stepIndex(t: TicketDto): number { return Math.max(0, STEPS.findIndex(s => s.status === t.status)); }

  images(d: TicketDetailDto) { return d.attachments.filter(a => a.contentType.startsWith('image/')); }
  files(d: TicketDetailDto) { return d.attachments.filter(a => !a.contentType.startsWith('image/')); }

  size(bytes: number) { return bytes < 1024 * 1024 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1024 / 1024).toFixed(1)} MB`; }

  download(a: TicketAttachmentDto): void {
    const save = (url: string, revoke: boolean) => {
      const link = Object.assign(document.createElement('a'), { href: url, download: a.fileName });
      link.click();
      if (revoke) setTimeout(() => URL.revokeObjectURL(url), 1000);
    };
    const cached = this.urls()[a.id];
    if (cached) { save(cached, false); return; }
    this.api.getTicketAttachment(this.detail()!.ticket.id, a.id).subscribe(blob => save(URL.createObjectURL(blob), true));
  }

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
