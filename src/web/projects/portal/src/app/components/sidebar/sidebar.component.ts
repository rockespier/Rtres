import { Component, computed, inject, input, output } from '@angular/core';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { ThemeToggleComponent } from '../theme-toggle/theme-toggle.component';
import { IconComponent } from '../icon/icon.component';
import { AuthService } from '../../core/auth.service';
import { PortalUiService } from '../../core/portal-ui.service';
import { navFor } from '../../core/nav';

const ROLE_LABELS: Record<string, string> = { Cliente: 'Cliente', Admin: 'Administrador', SuperAdmin: 'Equipo Rtres' };

/**
 * Navegación lateral. Clientes: barra clara con la opción activa en lima.
 * Equipo Rtres (SuperAdmin): barra oscura, para que nunca se confunda la vista de administración con la del cliente.
 */
@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [RouterLink, RouterLinkActive, ThemeToggleComponent, IconComponent],
  template: `<aside class="sidebar" [class.sidebar-dark]="isStaff()" [class.sidebar-drawer]="drawer()">
    <div class="sidebar-top">
      <a routerLink="/" class="brand-logo" (click)="navigate.emit()"><img src="assets/logo-rtres.png" alt="Rtres Web Solutions, inicio" width="175" height="79"></a>
      @if (drawer()) {
        <button type="button" class="icon-btn" aria-label="Cerrar menú" (click)="navigate.emit()"><app-icon name="x"/></button>
      }
    </div>

    <nav class="sidebar-nav" aria-label="Principal">
      @for (group of groups(); track $index) {
        @if (group.label) { <p class="side-group-label" [title]="group.label">{{ group.label }}</p> }
        @for (item of group.items; track item.link) {
          <a [routerLink]="item.link" routerLinkActive="active" ariaCurrentWhenActive="page" class="nav-item" (click)="navigate.emit()">
            <app-icon [name]="item.icon"/><span class="truncate">{{ item.label }}</span>
          </a>
        }
      }
    </nav>

    <div class="sidebar-foot">
      <div class="user-chip">
        <span class="avatar-btn" aria-hidden="true">{{ initials() }}</span>
        <span class="min-w-0">
          <span class="block text-sm font-semibold truncate">{{ user()?.name || 'Mi cuenta' }}</span>
          <span class="block text-xs side-muted truncate">{{ subtitle() }}</span>
        </span>
      </div>
      <div class="nav-item"><app-icon name="moon"/><span>Modo oscuro</span><app-theme-toggle class="ml-auto"/></div>
      <button type="button" class="nav-item w-full" (click)="logout()"><app-icon name="logout"/><span>Cerrar sesión</span></button>
    </div>
  </aside>`,
})
export class SidebarComponent {
  private auth = inject(AuthService);
  private ui = inject(PortalUiService);
  private router = inject(Router);

  /** true dentro del menú móvil (muestra el botón de cerrar). */
  drawer = input(false);
  /** Se emite al elegir una opción o cerrar, para que el shell cierre el menú móvil. */
  navigate = output<void>();

  user = this.auth.user;
  isStaff = computed(() => this.user()?.role === 'SuperAdmin');
  groups = computed(() => navFor(this.user()?.role, this.ui.viewingClientName()));
  initials = computed(() => this.user()?.initials || this.user()?.name?.trim().split(/\s+/).map(w => w[0]).slice(0, 2).join('').toUpperCase() || '·');
  subtitle = computed(() => {
    const u = this.user();
    if (!u) return '';
    return u.role === 'SuperAdmin' ? ROLE_LABELS[u.role] : [u.clientName, u.role === 'Admin' ? ROLE_LABELS[u.role] : null].filter(Boolean).join(' · ');
  });

  logout(): void {
    this.navigate.emit();
    this.auth.logout();
    this.router.navigateByUrl('/login');
  }
}
