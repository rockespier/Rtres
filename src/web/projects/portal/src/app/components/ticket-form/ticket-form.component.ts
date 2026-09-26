import { AfterViewInit, Component, OnDestroy, OnInit, TemplateRef, ViewChild, effect, inject, signal } from '@angular/core';
import { toSignal } from '@angular/core/rxjs-interop';
import { CommonModule } from '@angular/common';
import { Router, RouterLink } from '@angular/router';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { TicketPreviewCardComponent } from '../ticket-preview-card/ticket-preview-card.component';
import { FileDropzoneComponent } from '../file-dropzone/file-dropzone.component';
import { PortalApiService, ProjectDto } from '../../core/portal-api.service';
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
            <button type="button" class="type-tab" [class.active]="form.value.type==='Soporte'" (click)="setType('Soporte')">Ticket de soporte</button>
            <button type="button" class="type-tab ml-2" [class.active]="form.value.type==='Cambio'" (click)="setType('Cambio')">Solicitud de cambio</button>
          </div>
          <label>Proyecto<select class="field" formControlName="projectId"><option *ngFor="let p of projects()" [value]="p.id">{{ p.name }}</option></select></label>
          <label>Título<input class="field" formControlName="title"></label>
          <label>Descripción *<textarea class="field" formControlName="description"></textarea></label>
          <label>Comportamiento actual *<textarea class="field" formControlName="currentBehavior"></textarea></label>
          <label>Comportamiento esperado *<textarea class="field" formControlName="expectedBehavior"></textarea></label>
          <label>Pasos para reproducir *<textarea class="field" formControlName="stepsToReproduce"></textarea></label>
          <label>Entorno *<input class="field" formControlName="environment"></label>
          <app-file-dropzone/>
          <label>Criterios de aceptación *<textarea class="field" formControlName="acceptanceCriteria"></textarea></label>
          <label *ngIf="form.value.type==='Cambio'">Impacto / alcance estimado<textarea class="field" formControlName="estimatedImpact"></textarea></label>
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
  @ViewChild('actions') private actionsTpl!: TemplateRef<unknown>;

  projects = signal<ProjectDto[]>([]);
  submitting = signal(false);
  error = signal('');

  form = this.fb.group({
    type: ['Soporte'],
    projectId: [''],
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

  constructor() {
    effect(() => {
      this.ui.viewingClientId();
      this.api.getProjects().subscribe(projects => {
        this.projects.set(projects);
        this.form.patchValue({ projectId: projects.length ? projects[0].id : '' });
      });
    });
  }

  ngOnInit(): void {
    this.ui.breadcrumb.set({ parentLabel: 'Tickets', parentLink: '/tickets', current: 'Nuevo' });
  }

  ngAfterViewInit(): void {
    this.ui.actions.set(this.actionsTpl);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }

  setType(t: 'Soporte' | 'Cambio') { this.form.controls.type.setValue(t); }

  submit(): void {
    if (this.form.invalid) { this.error.set('Completa los campos obligatorios.'); return; }
    const v = this.form.getRawValue();
    this.submitting.set(true);
    this.error.set('');
    this.api.createTicket({
      projectId: v.projectId!,
      type: v.type as 'Soporte' | 'Cambio',
      title: v.title!,
      description: v.description!,
      currentBehavior: v.currentBehavior!,
      expectedBehavior: v.expectedBehavior!,
      stepsToReproduce: v.stepsToReproduce!,
      environment: v.environment!,
      acceptanceCriteria: v.acceptanceCriteria!,
      estimatedImpact: v.estimatedImpact || undefined,
    }).subscribe({
      next: () => this.router.navigateByUrl('/tickets'),
      error: () => { this.error.set('No se pudo crear el ticket.'); this.submitting.set(false); },
    });
  }
}
