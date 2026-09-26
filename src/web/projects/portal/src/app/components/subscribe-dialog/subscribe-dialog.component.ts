import { Component, EventEmitter, Input, Output, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { PortalApiService, ProductDto, ProjectDto } from '../../core/portal-api.service';

@Component({selector:'app-subscribe-dialog',standalone:true,imports:[CommonModule,FormsModule],template:`<div class="fixed inset-0 z-50 grid place-items-center bg-black/40 p-4"><section class="card w-full max-w-lg p-6"><h2 class="font-display text-xl">Agregar {{product.name}}</h2><p class="text-muted mt-1">Confirma el proyecto y el ciclo antes de continuar a PayPal.</p><label class="field-label mt-5">Proyecto<select class="field" [(ngModel)]="projectId"><option value="" disabled>Selecciona un proyecto</option><option *ngFor="let project of projects" [value]="project.id">{{project.name}}</option></select></label><label class="field-label mt-3">Ciclo de facturación<select class="field" [(ngModel)]="billingCycle"><option [value]="product.billingCycle">{{cycleLabel(product.billingCycle)}}</option></select></label><p *ngIf="error()" class="text-warn text-sm mt-3">{{error()}}</p><div class="flex gap-2 mt-6"><button class="btn btn-primary btn-sm" (click)="continue()" [disabled]="!projectId || loading()">{{loading() ? 'Preparando…' : 'Continuar a PayPal'}}</button><button class="btn btn-ghost btn-sm" (click)="closed.emit()">Cancelar</button></div></section></div>`})
export class SubscribeDialogComponent {
  private api=inject(PortalApiService); @Input({required:true}) product!:ProductDto; @Input() projects:ProjectDto[]=[]; @Output() closed=new EventEmitter<void>();
  projectId=''; billingCycle=''; loading=signal(false); error=signal('');
  ngOnInit(){this.billingCycle=this.product.billingCycle;}
  cycleLabel(value:string){return value==='Unico'?'Pago único':value;}
  continue(){this.loading.set(true);this.error.set('');this.api.subscribeProduct({productId:this.product.id,projectId:this.projectId,billingCycle:this.billingCycle}).subscribe({next:r=>location.assign(r.approvalUrl),error:e=>{this.error.set(e.error?.message ?? 'No se pudo iniciar el pago.');this.loading.set(false);}});}
}
