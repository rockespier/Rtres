import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';
import { PortalUiService } from './portal-ui.service';
import { PortalRole, homeFor } from './nav';

/** Solo deja pasar a los roles indicados; el resto vuelve a su pantalla de inicio. */
export const roleGuard = (...roles: PortalRole[]): CanActivateFn => () => {
  const role = inject(AuthService).user()?.role;
  return role && roles.includes(role) ? true : inject(Router).createUrlTree([homeFor(role)]);
};

/**
 * Área del cliente. Cliente/Admin entran siempre; el SuperAdmin solo con un cliente seleccionado,
 * porque sin él la API rechaza estas consultas (clientId es obligatorio).
 */
export const clientAreaGuard: CanActivateFn = () => {
  const role = inject(AuthService).user()?.role;
  if (role === 'Cliente' || role === 'Admin') return true;
  if (role === 'SuperAdmin' && inject(PortalUiService).viewingClientId()) return true;
  return inject(Router).createUrlTree([homeFor(role)]);
};
