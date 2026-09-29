import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from './auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  if (auth.isAuthenticated()) return true;
  if (auth.hasExpiredToken()) { auth.logout(); auth.sessionExpired.set(true); }
  return inject(Router).createUrlTree(['/login']);
};
