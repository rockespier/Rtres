import { Component, OnDestroy, OnInit, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-placeholder',
  standalone: true,
  template: '<h1 class="font-display text-2xl">Próximamente</h1><p class="text-muted mt-2">Esta sección estará disponible pronto.</p>',
})
export class PlaceholderComponent implements OnInit, OnDestroy {
  private route = inject(ActivatedRoute);
  private ui = inject(PortalUiService);

  ngOnInit(): void {
    this.ui.breadcrumb.set({ current: this.route.snapshot.data['breadcrumb'] ?? 'Próximamente' });
    this.ui.actions.set(null);
  }

  ngOnDestroy(): void {
    this.ui.actions.set(null);
  }
}
