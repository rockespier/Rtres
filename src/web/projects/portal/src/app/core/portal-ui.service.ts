import { Injectable, TemplateRef, signal } from '@angular/core';

export interface Breadcrumb {
  parentLabel?: string;
  parentLink?: string;
  current: string;
}

@Injectable({ providedIn: 'root' })
export class PortalUiService {
  mobileMenuOpen = signal(false);
  breadcrumb = signal<Breadcrumb>({ current: 'Inicio' });
  actions = signal<TemplateRef<unknown> | null>(null);
  viewingClientId = signal<string | null>(null);
  /** Nombre del cliente que el SuperAdmin está viendo (para el menú). */
  viewingClientName = signal<string | null>(null);

  toggleMobileMenu(): void {
    this.mobileMenuOpen.update(v => !v);
  }

  closeMobileMenu(): void {
    this.mobileMenuOpen.set(false);
  }
}
