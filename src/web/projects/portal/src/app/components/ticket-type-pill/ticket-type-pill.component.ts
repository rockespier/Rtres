import { Component, computed, input } from '@angular/core';

export const TICKET_TYPE_LABELS: Record<string, string> = {
  Bug: 'Bug',
  Funcionalidad: 'Funcionalidad',
  Requerimiento: 'Requerimiento',
};

@Component({
  selector: 'app-ticket-type-pill',
  standalone: true,
  template: `<span class="pill"
    [class.pill-danger]="type()==='Bug'"
    [class.pill-info]="type()==='Funcionalidad'"
    [class.pill-warn]="type()==='Requerimiento'">{{ label() }}</span>`,
})
export class TicketTypePillComponent {
  type = input<string>('Bug');
  label = computed(() => TICKET_TYPE_LABELS[this.type()] ?? this.type());
}
