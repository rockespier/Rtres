import { Component, computed, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PortalUiService } from '../../core/portal-ui.service';
import { AuthService } from '../../core/auth.service';
import { ClientSwitcherComponent } from '../client-switcher/client-switcher.component';
import { NotificationBellComponent } from '../notification-bell/notification-bell.component';
import { IconComponent } from '../icon/icon.component';

@Component({
  selector: 'app-topbar',
  standalone: true,
  imports: [CommonModule, RouterLink, ClientSwitcherComponent, NotificationBellComponent, IconComponent],
  template: `<header class="topbar">
    <div class="flex items-center gap-3 min-w-0">
      <button type="button" class="icon-btn lg:hidden" aria-label="Abrir menú" [attr.aria-expanded]="ui.mobileMenuOpen()" (click)="ui.toggleMobileMenu()"><app-icon name="menu"/></button>
      <a routerLink="/" class="wordmark wordmark-sm lg:hidden" aria-label="Rtres, inicio"><span class="wordmark-name">Rtres</span></a>
      <nav class="crumbs hidden sm:flex" aria-label="Ruta">
        @if (ui.breadcrumb().parentLabel; as parent) {
          <a [routerLink]="ui.breadcrumb().parentLink || '/'">{{ parent }}</a><span aria-hidden="true">/</span>
        }
        <span class="crumb-current" aria-current="page">{{ ui.breadcrumb().current }}</span>
      </nav>
    </div>
    <div class="flex items-center gap-2.5 shrink-0">
      <app-client-switcher class="hidden md:block"/>
      <app-notification-bell/>
      <ng-container *ngTemplateOutlet="ui.actions()"></ng-container>
      <a routerLink="/profile" class="avatar-btn" aria-label="Mi cuenta" title="Mi cuenta">{{ initials() }}</a>
    </div>
  </header>`,
})
export class TopbarComponent {
  ui = inject(PortalUiService);
  private auth = inject(AuthService);
  initials = computed(() => this.auth.user()?.initials || this.auth.user()?.name?.trim().split(/\s+/).map(w => w[0]).slice(0, 2).join('').toUpperCase() || '·');
}
