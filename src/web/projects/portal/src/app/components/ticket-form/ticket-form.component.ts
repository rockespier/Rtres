import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, computed, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { FileDropzoneComponent } from '../file-dropzone/file-dropzone.component';
import { IconComponent, IconName } from '../icon/icon.component';
import { TicketTypePillComponent } from '../ticket-type-pill/ticket-type-pill.component';
import { PortalApiService, ProjectDto, TicketType } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { AuthService } from '../../core/auth.service';

type FieldName = 'title' | 'description' | 'currentBehavior' | 'expectedBehavior' | 'stepsToReproduce' | 'environment' | 'acceptanceCriteria';

@Component({
  selector: 'app-ticket-form',
  standalone: true,
  imports: [CommonModule, RouterLink, ReactiveFormsModule, FileDropzoneComponent, IconComponent, TicketTypePillComponent],
  styles: [`
    .tf-step{display:grid;place-items:center;width:24px;height:24px;border-radius:99px;font-size:12px;font-weight:600;background:var(--night);color:var(--on-night);flex-shrink:0;}
    .tf-hint{font-size:12.5px;color:var(--muted);margin-top:-2px;margin-bottom:8px;}
    .tf-error{font-size:12.5px;color:var(--danger-ink);margin-top:6px;}
    .tf-field.invalid .field{border-color:var(--danger-ink);}
    .tf-req{color:var(--danger-ink);margin-left:2px;}
    .tf-type{display:flex;gap:12px;align-items:flex-start;text-align:left;padding:14px 16px;border-radius:var(--radius-md);border:1px solid var(--border);background:var(--surface);transition:border-color .15s,box-shadow .15s;}
    .tf-type:hover{border-color:var(--border-strong);}
    .tf-type.active{border-color:var(--primary);box-shadow:0 0 0 3px var(--surface-tint);}
    .tf-type .tf-icon{display:grid;place-items:center;width:34px;height:34px;border-radius:10px;background:var(--neutral-bg);color:var(--muted);flex-shrink:0;}
    .tf-type.active .tf-icon{background:var(--lime);color:var(--on-lime);}
    textarea.field{min-height:96px;resize:vertical;line-height:1.55;}
  `],
  template: `<ng-template #actions>
      <a routerLink="/tickets" class="btn btn-ghost btn-sm hidden sm:inline-flex">Cancelar</a>
      <button form="ticketForm" type="submit" class="btn btn-primary btn-sm" [disabled]="submitting()">{{ submitting() ? 'Enviando…' : 'Enviar ticket' }}</button>
    </ng-template>

    <header class="max-w-6xl">
      <h1 class="font-display text-3xl font-semibold tracking-tight">Nuevo ticket</h1>
      <p class="text-muted mt-2 max-w-2xl">Cuéntanos qué necesitas. Cuanto más concreto seas, antes podremos resolverlo. Te responderemos en este ticket y por correo.</p>
    </header>

    <div class="grid lg:grid-cols-[minmax(0,1fr)_320px] gap-6 mt-8 max-w-6xl items-start">
      <form id="ticketForm" [formGroup]="form" (ngSubmit)="submit()" class="space-y-6 min-w-0" novalidate>

        <section class="card p-6">
          <div class="flex items-center gap-3"><span class="tf-step">1</span><h2 class="font-display text-base font-semibold">¿Qué tipo de solicitud es?</h2></div>
          <div class="grid sm:grid-cols-3 gap-3 mt-5" role="radiogroup" aria-label="Tipo de ticket">
            @for (t of types; track t.value) {
              <button type="button" class="tf-type" role="radio" [attr.aria-checked]="type() === t.value" [class.active]="type() === t.value" (click)="setType(t.value)">
                <span class="tf-icon"><app-icon [name]="t.icon" [size]="17"/></span>
                <span><span class="block text-sm font-semibold">{{ t.label }}</span><span class="block text-xs text-muted mt-0.5 leading-snug">{{ t.hint }}</span></span>
              </button>
            }
          </div>
        </section>

        <section class="card p-6">
          <div class="flex items-center gap-3"><span class="tf-step">2</span><h2 class="font-display text-base font-semibold">Contexto</h2></div>
          <div class="grid gap-5 mt-5" [ngClass]="{ 'sm:grid-cols-2': repositories().length > 1 }">
            <label class="block"><span class="field-label">Proyecto</span>
              <select class="field" formControlName="projectId">@for (p of projects(); track p.id) {<option [value]="p.id">{{ p.name }}</option>}</select>
              @if (productName() && form.value.projectId === productProjectId) { <span class="block text-xs text-muted mt-1.5">Producto: <span class="font-medium">{{ productName() }}</span></span> }
            </label>
            @if (repositories().length > 1) {
              <label class="block"><span class="field-label">Componente</span>
                <select class="field" formControlName="repositoryId">@for (r of repositories(); track r.id) {<option [value]="r.id">{{ r.label || r.name }}</option>}</select>
              </label>
            }
          </div>
          <label class="tf-field block mt-5" [class.invalid]="invalid('title')"><span class="field-label">Título<span class="tf-req">*</span></span>
            <p class="tf-hint">Una frase que resuma el pedido.</p>
            <input class="field" formControlName="title" maxlength="140" [placeholder]="isBug() ? 'Ej. El botón Pagar no responde en el checkout' : 'Ej. Mostrar 2 beneficios por fila en el PDF'">
            @if (invalid('title')) { <p class="tf-error">Escribe un título.</p> }
          </label>
        </section>

        <section class="card p-6">
          <div class="flex items-center gap-3"><span class="tf-step">3</span><h2 class="font-display text-base font-semibold">Detalle</h2></div>
          <div class="space-y-5 mt-5">
            <label class="tf-field block" [class.invalid]="invalid('description')"><span class="field-label">Descripción<span class="tf-req">*</span></span>
              <p class="tf-hint">{{ isBug() ? '¿Qué está fallando y a quién afecta?' : '¿Qué necesitas y para qué?' }}</p>
              <textarea class="field" formControlName="description"></textarea>
              @if (invalid('description')) { <p class="tf-error">Describe la solicitud.</p> }
            </label>
            <div class="grid gap-5 md:grid-cols-2">
              <label class="tf-field block" [class.invalid]="invalid('currentBehavior')"><span class="field-label">Comportamiento actual@if (isBug()) {<span class="tf-req">*</span>} @else {<span class="font-normal"> (opcional)</span>}</span>
                <p class="tf-hint">Lo que pasa hoy.</p>
                <textarea class="field" formControlName="currentBehavior"></textarea>
                @if (invalid('currentBehavior')) { <p class="tf-error">Indica qué pasa hoy.</p> }
              </label>
              <label class="tf-field block" [class.invalid]="invalid('expectedBehavior')"><span class="field-label">Comportamiento esperado<span class="tf-req">*</span></span>
                <p class="tf-hint">Lo que debería pasar.</p>
                <textarea class="field" formControlName="expectedBehavior"></textarea>
                @if (invalid('expectedBehavior')) { <p class="tf-error">Indica el resultado esperado.</p> }
              </label>
            </div>
            @if (isBug()) {
              <label class="tf-field block" [class.invalid]="invalid('stepsToReproduce')"><span class="field-label">Pasos para reproducir<span class="tf-req">*</span></span>
                <p class="tf-hint">Uno por línea, desde que entras a la página.</p>
                <textarea class="field" formControlName="stepsToReproduce" placeholder="1. Entrar a …&#10;2. Hacer clic en …&#10;3. Aparece …"></textarea>
                @if (invalid('stepsToReproduce')) { <p class="tf-error">Indica cómo reproducirlo.</p> }
              </label>
              <label class="tf-field block" [class.invalid]="invalid('environment')"><span class="field-label">Entorno<span class="tf-req">*</span></span>
                <p class="tf-hint">Dispositivo, navegador y página donde ocurre.</p>
                <input class="field" formControlName="environment" placeholder="Ej. Chrome en Windows · /checkout">
                @if (invalid('environment')) { <p class="tf-error">Indica dónde ocurre.</p> }
              </label>
            }
          </div>
        </section>

        <section class="card p-6">
          <div class="flex items-center gap-3"><span class="tf-step">4</span><h2 class="font-display text-base font-semibold">Evidencia</h2><span class="text-xs text-muted">opcional</span></div>
          <p class="text-sm text-muted mt-2 mb-4">Capturas, videos cortos, logs o un diseño de referencia ayudan mucho.</p>
          <app-file-dropzone/>
        </section>

        <section class="card p-6">
          <div class="flex items-center gap-3"><span class="tf-step">5</span><h2 class="font-display text-base font-semibold">¿Cómo sabremos que está listo?</h2></div>
          <div class="space-y-5 mt-5">
            <label class="tf-field block" [class.invalid]="invalid('acceptanceCriteria')"><span class="field-label">Criterios de aceptación<span class="tf-req">*</span></span>
              <p class="tf-hint">Lo que revisarás para dar el ticket por resuelto.</p>
              <textarea class="field" formControlName="acceptanceCriteria"></textarea>
              @if (invalid('acceptanceCriteria')) { <p class="tf-error">Indica cómo validarlo.</p> }
            </label>
            @if (!isBug()) {
              <label class="block"><span class="field-label">Impacto / alcance estimado <span class="font-normal">(opcional)</span></span>
                <p class="tf-hint">Urgencia, fechas o a cuántos usuarios afecta.</p>
                <textarea class="field" formControlName="estimatedImpact"></textarea>
              </label>
            }
          </div>
        </section>
      </form>

      <aside class="card p-6 lg:sticky lg:top-24">
        <div class="flex items-center justify-between gap-2"><h2 class="text-[11px] font-semibold uppercase tracking-[.08em] text-muted">Resumen</h2><app-ticket-type-pill [type]="type()"/></div>
        <p class="font-display text-lg font-semibold mt-4 leading-snug" [class.text-muted]="!value().title">{{ value().title || 'Sin título' }}</p>
        <dl class="mt-4 space-y-2 text-sm">
          <div class="flex justify-between gap-3"><dt class="text-muted">Proyecto</dt><dd class="font-medium text-right">{{ projectName() || '—' }}</dd></div>
          @if (componentName()) { <div class="flex justify-between gap-3"><dt class="text-muted">Componente</dt><dd class="font-medium text-right">{{ componentName() }}</dd></div> }
          <div class="flex justify-between gap-3"><dt class="text-muted">Adjuntos</dt><dd class="font-medium">{{ dropzone?.files()?.length ?? 0 }}</dd></div>
          <div class="flex justify-between gap-3"><dt class="text-muted">Solicitado por</dt><dd class="font-medium text-right">{{ auth.user()?.name || '—' }}</dd></div>
        </dl>
        <div class="border-t border-[var(--border)] mt-5 pt-5">
          <div class="flex justify-between text-xs text-muted"><span>Campos obligatorios</span><span>{{ progress().done }}/{{ progress().total }}</span></div>
          <div class="h-1.5 rounded-full bg-[var(--neutral-border)] mt-2 overflow-hidden"><div class="h-full rounded-full bg-[var(--primary)] transition-all" [style.width.%]="progress().done / progress().total * 100"></div></div>
          <ul class="mt-4 space-y-1.5">
            @for (f of progress().fields; track f.name) {
              <li class="flex items-center gap-2 text-xs" [class.text-muted]="!f.done">
                <span class="grid place-items-center w-4 h-4 rounded-full" [style.background]="f.done ? 'var(--primary)' : 'var(--neutral-border)'" [style.color]="'var(--on-primary)'">@if (f.done) {<app-icon name="check" [size]="11"/>}</span>{{ f.label }}
              </li>
            }
          </ul>
        </div>
        @if (error()) { <p class="text-sm text-red-600 mt-5">{{ error() }}</p> }
        <button form="ticketForm" type="submit" class="btn btn-primary w-full justify-center mt-6" [disabled]="submitting()">{{ submitting() ? 'Enviando…' : 'Enviar ticket' }}</button>
      </aside>
    </div>`,
})
export class TicketFormComponent implements OnInit, AfterViewInit, OnDestroy {
  private fb = inject(FormBuilder);
  private api = inject(PortalApiService);
  private router = inject(Router);
  private ui = inject(PortalUiService);
  auth = inject(AuthService);
  private params = inject(ActivatedRoute).snapshot.queryParamMap;
  /** Ticket registrado desde la tarjeta de un producto: se guarda el producto mientras no se cambie de proyecto. */
  productProjectId = this.params.get('projectId');
  private clientProductId = this.params.get('clientProductId');
  productName = signal('');
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;
  @ViewChild(FileDropzoneComponent) dropzone?: FileDropzoneComponent;

  projects = signal<ProjectDto[]>([]);
  submitting = signal(false);
  submitted = signal(false);
  error = signal('');

  types: { value: TicketType; label: string; hint: string; icon: IconName }[] = [
    { value: 'Bug', label: 'Reportar bug', hint: 'Algo no funciona como debería.', icon: 'bug' },
    { value: 'Funcionalidad', label: 'Nueva funcionalidad', hint: 'Algo que aún no existe.', icon: 'sparkle' },
    { value: 'Requerimiento', label: 'Requerimiento', hint: 'Un cambio sobre algo existente.', icon: 'pencil' },
  ];

  form = this.fb.group({
    type: ['Bug' as TicketType],
    projectId: [''],
    repositoryId: [''],
    title: ['', [Validators.required, Validators.pattern(/\S/)]],
    description: ['', Validators.required],
    currentBehavior: ['', Validators.required],
    expectedBehavior: ['', Validators.required],
    stepsToReproduce: ['', Validators.required],
    environment: ['', Validators.required],
    acceptanceCriteria: ['', Validators.required],
    estimatedImpact: [''],
  });

  value = toSignal(this.form.valueChanges, { initialValue: this.form.value });
  type = computed(() => this.value().type ?? 'Bug');
  private projectId = toSignal(this.form.controls.projectId.valueChanges, { initialValue: '' });
  /** Repos del proyecto elegido: con más de uno, el cliente indica dónde va el ticket (por defecto el principal). */
  repositories = computed(() => this.projects().find(p => p.id === this.projectId())?.repositories ?? []);
  projectName = computed(() => this.projects().find(p => p.id === this.projectId())?.name ?? '');
  componentName = computed(() => {
    if (this.repositories().length < 2) return '';
    const repo = this.repositories().find(r => r.id === this.value().repositoryId);
    return repo ? repo.label || repo.name : '';
  });

  private readonly labels: Record<FieldName, string> = {
    title: 'Título', description: 'Descripción', currentBehavior: 'Comportamiento actual', expectedBehavior: 'Comportamiento esperado',
    stepsToReproduce: 'Pasos para reproducir', environment: 'Entorno', acceptanceCriteria: 'Criterios de aceptación',
  };
  /** Checklist del resumen: solo los campos que exige el tipo elegido. */
  progress = computed(() => {
    const v = this.value();
    const names: FieldName[] = this.type() === 'Bug'
      ? ['title', 'description', 'currentBehavior', 'expectedBehavior', 'stepsToReproduce', 'environment', 'acceptanceCriteria']
      : ['title', 'description', 'expectedBehavior', 'acceptanceCriteria'];
    const fields = names.map(name => ({ name, label: this.labels[name], done: !!v[name]?.trim() }));
    return { fields, done: fields.filter(f => f.done).length, total: fields.length };
  });

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.api.getProjects().subscribe(projects => {
        this.projects.set(projects);
        const preset = projects.find(p => p.id === this.productProjectId);
        this.form.patchValue({ projectId: preset?.id ?? (projects.length ? projects[0].id : '') });
      });
    });
    effect(() => {
      const repos = this.repositories();
      this.form.controls.repositoryId.setValue((repos.find(r => r.isDefault) ?? repos[0])?.id ?? '');
    });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: 'Nuevo' });
    const type = this.params.get('type') as TicketType | null;
    if (type && this.types.some(t => t.value === type)) this.setType(type);
    if (this.params.get('title')) this.form.patchValue({ title: this.params.get('title') });
    if (this.clientProductId) this.api.getClientProduct(this.clientProductId).subscribe({ next: p => this.productName.set(p.domainName ? `${p.product.name} — ${p.domainName}` : p.product.name), error: () => this.clientProductId = null });
  }

  ngAfterViewInit(): void {
    this.ui.actions.set(this.actionsTpl);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }

  isBug(): boolean { return this.type() === 'Bug'; }

  /** Los errores se muestran al tocar el campo o al intentar enviar, no mientras se escribe por primera vez. */
  invalid(name: FieldName): boolean {
    const c = this.form.controls[name];
    return c.invalid && (c.touched || this.submitted());
  }

  /** Bug usa los campos de reporte de error; Funcionalidad/Requerimiento solo exigen el comportamiento esperado. */
  setType(t: TicketType) {
    this.form.controls.type.setValue(t);
    const bug = t === 'Bug';
    for (const name of ['currentBehavior', 'stepsToReproduce', 'environment'] as const) {
      const control = this.form.controls[name];
      control.setValidators(bug ? Validators.required : null);
      control.updateValueAndValidity();
    }
  }

  submit(): void {
    this.submitted.set(true);
    if (this.form.invalid) {
      this.error.set('Revisa los campos marcados.');
      document.querySelector<HTMLElement>('.tf-field.invalid .field')?.focus();
      return;
    }
    const v = this.form.getRawValue();
    const bug = v.type === 'Bug';
    this.submitting.set(true);
    this.error.set('');
    this.api.createTicket({
      projectId: v.projectId!,
      repositoryId: this.repositories().length > 1 && v.repositoryId ? v.repositoryId : undefined,
      clientProductId: this.clientProductId && v.projectId === this.productProjectId ? this.clientProductId : undefined,
      type: v.type!,
      title: v.title!.trim(),
      description: v.description!,
      currentBehavior: v.currentBehavior || undefined,
      expectedBehavior: v.expectedBehavior!,
      stepsToReproduce: bug ? v.stepsToReproduce! : undefined,
      environment: bug ? v.environment! : undefined,
      acceptanceCriteria: v.acceptanceCriteria!,
      estimatedImpact: bug ? undefined : v.estimatedImpact || undefined,
    }, this.dropzone?.files() ?? []).subscribe({
      next: t => this.router.navigate(['/tickets', t.id]),
      error: e => { this.error.set(e?.error?.message ?? 'No se pudo crear el ticket.'); this.submitting.set(false); },
    });
  }
}
