import { Component, DestroyRef, HostListener, inject } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { NavigationEnd, Router, RouterOutlet } from '@angular/router';
import { filter } from 'rxjs';
import { SidebarComponent } from '../sidebar/sidebar.component';
import { TopbarComponent } from '../topbar/topbar.component';
import { PortalUiService } from '../../core/portal-ui.service';

@Component({
  selector: 'app-portal-shell',
  standalone: true,
  imports: [RouterOutlet, SidebarComponent, TopbarComponent],
  template: `<div class="flex min-h-screen">
    <app-sidebar class="hidden lg:block shrink-0"/>
    @if (ui.mobileMenuOpen()) {
      <div class="drawer-backdrop lg:hidden" (click)="ui.closeMobileMenu()"></div>
      <app-sidebar class="lg:hidden" [drawer]="true" (navigate)="ui.closeMobileMenu()"/>
    }
    <div class="flex-1 min-w-0">
      <app-topbar/>
      <main class="px-4 sm:px-6 lg:px-10 py-8 lg:py-10 max-w-6xl"><router-outlet/></main>
    </div>
  </div>`,
})
export class PortalShellComponent {
  ui = inject(PortalUiService);

  constructor() {
    inject(Router).events.pipe(filter(e => e instanceof NavigationEnd), takeUntilDestroyed(inject(DestroyRef))).subscribe(() => this.ui.closeMobileMenu());
  }

  @HostListener('document:keydown.escape') onEscape(): void { this.ui.closeMobileMenu(); }
}
