import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CommonModule } from '@angular/common';

/** Confirmación con el estilo del portal (en lugar del confirm() del navegador). */
@Component({selector:'app-confirm-dialog',standalone:true,imports:[CommonModule],template:`<div class="fixed inset-0 z-50 grid place-items-center bg-black/40 p-4" (click)="!busy && cancelled.emit()"><section class="card w-full max-w-md p-6" role="alertdialog" aria-modal="true" [attr.aria-label]="title" (click)="$event.stopPropagation()"><h2 class="font-display text-xl">{{title}}</h2><p class="text-muted mt-2">{{message}}</p><p *ngIf="error" class="text-sm text-red-600 mt-3">{{error}}</p><div class="flex gap-2 mt-6"><button class="btn btn-sm" [class.btn-danger]="danger" [class.btn-primary]="!danger" [disabled]="busy" (click)="confirmed.emit()">{{busy ? busyLabel : confirmLabel}}</button><button class="btn btn-ghost btn-sm" [disabled]="busy" (click)="cancelled.emit()">{{cancelLabel}}</button></div></section></div>`})
export class ConfirmDialogComponent {
  @Input({required:true}) title='';
  @Input() message='';
  @Input() confirmLabel='Confirmar';
  @Input() cancelLabel='Volver';
  @Input() busyLabel='Procesando…';
  @Input() danger=false;
  @Input() busy=false;
  @Input() error='';
  @Output() confirmed=new EventEmitter<void>();
  @Output() cancelled=new EventEmitter<void>();
}
