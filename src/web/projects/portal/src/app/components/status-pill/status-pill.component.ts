import { Component, computed, input } from '@angular/core';

const LABELS: Record<string, string> = {
  Abierto: 'Abierto',
  EnProgreso: 'En progreso',
  Resuelto: 'Resuelto',
  Publicado: 'Publicado',
  Cerrado: 'Cerrado',
};

@Component({
  selector: 'app-status-pill',
  standalone: true,
  template: `<span class="pill"
    [class.pill-success]="status()==='Abierto'"
    [class.pill-info]="status()==='EnProgreso'"
    [class.pill-neutral]="status()==='Resuelto'||status()==='Publicado'"
    [class.pill-danger]="status()==='Cerrado'">{{ label() }}</span>`,
})
export class StatusPillComponent {
  status = input<string>('Abierto');
  label = computed(() => LABELS[this.status()] ?? this.status());
}
