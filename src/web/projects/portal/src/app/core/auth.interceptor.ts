import { inject } from '@angular/core';
import { HttpErrorResponse, HttpInterceptorFn } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';
import { AuthService } from './auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.token();
  if (!token) return next(req);
  return next(req.clone({ setHeaders: { Authorization: `Bearer ${token}` } })).pipe(
    catchError((err: unknown) => {
      // 401 con token enviado = sesión vencida o revocada: cerrar y llevar al login con aviso.
      if (err instanceof HttpErrorResponse && err.status === 401) auth.expireSession();
      return throwError(() => err);
    })
  );
};
