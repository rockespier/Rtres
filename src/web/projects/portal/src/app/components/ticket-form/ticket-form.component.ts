import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, computed, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { TicketPreviewCardComponent } from '../ticket-preview-card/ticket-preview-card.component';
import { FileDropzoneComponent } from '../file-dropzone/file-dropzone.component';
import { PortalApiService, ProjectDto, TicketType } from '../../core/portal-api.service';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-ticket-form',
  standalone: true,
  imports: [CommonModule, RouterLink, ReactiveFormsModule, TicketPreviewCardComponent, FileDropzoneComponent],
  template: `<ng-template #actions>
      <a routerLink="/tickets" class="btn btn-ghost btn-sm hidden sm:inline-flex">Cancelar</a>
      <button form="ticketForm" type="submit" class="btn btn-primary btn-sm" [disabled]="submitting()">{{ submitting() ? 'Enviando…' : 'Enviar ticket' }}</button>
    </ng-template>
    <h1 class="font-display text-2xl font-semibold">Nuevo ticket</h1>
    <div class="grid lg:grid-cols-[1fr_360px] gap-6 mt-6">
      <form id="ticketForm" [formGroup]="form" (ngSubmit)="submit()">
        <div class="card p-6 space-y-6">
          <div>
            <button *ngFor="let t of types; let first = first" type="button" class="type-tab" [class.ml-2]="!first" [class.active]="form.value.type===t.value" (click)="setType(t.value)">{{ t.label }}</button>
          </div>
          <label>Proyecto<select class="field" formControlName="projectId"><option *ngFor="let p of projects()" [value]="p.id">{{ p.name }}</option></select></label>
          <p *ngIf="productName() && form.value.projectId === productProjectId" class="text-sm -mt-3"><span class="text-muted">Producto:</span> <span class="font-medium">{{ productName() }}</span></p>
          <label *ngIf="repositories().length > 1">Componente<select class="field" formControlName="repositoryId"><option *ngFor="let r of repositories()" [value]="r.id">{{ r.label || r.name }}</option></select></label>
          <label>Título<input class="field" formControlName="title"></label>
          <label>Descripción *<textarea class="field" formControlName="description"></textarea></label>
          <label>Comportamiento actual{{ isBug() ? ' *' : ' (opcional)' }}<textarea class="field" formControlName="currentBehavior"></textarea></label>
          <label>Comportamiento esperado *<textarea class="field" formControlName="expectedBehavior"></textarea></label>
          <label *ngIf="isBug()">Pasos para reproducir *<textarea class="field" formControlName="stepsToReproduce"></textarea></label>
          <label *ngIf="isBug()">Entorno *<input class="field" formControlName="environment"></label>
          <app-file-dropzone/>
          <label>Criterios de aceptación *<textarea class="field" formControlName="acceptanceCriteria"></textarea></label>
          <label *ngIf="!isBug()">Impacto / alcance estimado<textarea class="field" formControlName="estimatedImpact"></textarea></label>
          <p *ngIf="error()" class="text-red-600 text-sm">{{ error() }}</p>
        </div>
      </form>
      <app-ticket-preview-card [value]="preview()"/>
    </div>`,
})
export class TicketFormComponent implements OnInit, AfterViewInit, OnDestroy {
  private fb = inject(FormBuilder);
  private api = inject(PortalApiService);
  private router = inject(Router);
  private ui = inject(PortalUiService);
  private params = inject(ActivatedRoute).snapshot.queryParamMap;
  /** Ticket registrado desde la tarjeta de un producto: se guarda el producto mientras no se cambie de proyecto. */
  productProjectId = this.params.get('projectId');
  private clientProductId = this.params.get('clientProductId');
  productName = signal('');
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  projects = signal<ProjectDto[]>([]);
  submitting = signal(false);
  error = signal('');

  types: { value: TicketType; label: string }[] = [
    { value: 'Bug', label: 'Reportar bug' },
    { value: 'Funcionalidad', label: 'Nueva funcionalidad' },
    { value: 'Requerimiento', label: 'Requerimiento' },
  ];

  form = this.fb.group({
    type: ['Bug' as TicketType],
    projectId: [''],
    repositoryId: [''],
    title: [''],
    description: ['', Validators.required],
    currentBehavior: ['', Validators.required],
    expectedBehavior: ['', Validators.required],
    stepsToReproduce: ['', Validators.required],
    environment: ['', Validators.required],
    acceptanceCriteria: ['', Validators.required],
    estimatedImpact: [''],
  });

  preview = toSignal(this.form.valueChanges, { initialValue: this.form.value });
  private projectId = toSignal(this.form.controls.projectId.valueChanges, { initialValue: '' });
  /** Repos del proyecto elegido: con más de uno, el cliente indica dónde va el ticket (por defecto el principal). */
  repositories = computed(() => this.projects().find(p => p.id === this.projectId())?.repositories ?? []);

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

  isBug(): boolean { return this.form.value.type === 'Bug'; }

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
    if (this.form.invalid) { this.error.set('Completa los campos obligatorios.'); return; }
    const v = this.form.getRawValue();
    const bug = v.type === 'Bug';
    this.submitting.set(true);
    this.error.set('');
    this.api.createTicket({
      projectId: v.projectId!,
      repositoryId: this.repositories().length > 1 && v.repositoryId ? v.repositoryId : undefined,
      clientProductId: this.clientProductId && v.projectId === this.productProjectId ? this.clientProductId : undefined,
      type: v.type!,
      title: v.title!,
      description: v.description!,
      currentBehavior: v.currentBehavior || undefined,
      expectedBehavior: v.expectedBehavior!,
      stepsToReproduce: bug ? v.stepsToReproduce! : undefined,
      environment: bug ? v.environment! : undefined,
      acceptanceCriteria: v.acceptanceCriteria!,
      estimatedImpact: bug ? undefined : v.estimatedImpact || undefined,
    }).subscribe({
      next: t => this.router.navigate(['/tickets', t.id]),
      error: () => { this.error.set('No se pudo crear el ticket.'); this.submitting.set(false); },
    });
  }
}
