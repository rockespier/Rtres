import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../environments/environment';

export interface LoginResponse {
  token: string;
  user: { name: string | null; initials: string | null; clientName: string | null; role: 'Cliente' | 'Admin' | 'SuperAdmin' };
}

const TOKEN_KEY = 'rtres_portal_token';
const USER_KEY = 'rtres_portal_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readTokenFromStorage(): string | null {
    try { return localStorage.getItem(TOKEN_KEY); } catch { return null; }
  }

  token = signal<string | null>(this.readTokenFromStorage());
  user = signal<LoginResponse['user'] | null>(this.readUserFromStorage());

  /** true cuando se cerró la sesión por vencimiento (el login muestra el aviso). */
  sessionExpired = signal(false);
  private router = inject(Router);
  private expiryTimer: ReturnType<typeof setTimeout> | undefined;

  constructor(private http: HttpClient) {
    this.scheduleExpiry();
  }

  private readUserFromStorage(): LoginResponse['user'] | null {
    try {
      const raw = localStorage.getItem(USER_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }

  isAuthenticated(): boolean {
    const token = this.token();
    return !!token && !isExpired(token);
  }

  /** Token presente pero vencido: hay que avisar en vez de mandar al login en silencio. */
  hasExpiredToken(): boolean {
    const token = this.token();
    return !!token && isExpired(token);
  }

  /** Cierra la sesión vencida y lleva al login con aviso. */
  expireSession(): void {
    if (!this.token()) return;
    this.logout();
    this.sessionExpired.set(true);
    this.router.navigateByUrl('/login');
  }

  async login(email: string, password: string): Promise<void> {
    const response = await firstValueFrom(
      this.http.post<LoginResponse>(`${environment.apiBaseUrl}/auth/login`, { email, password })
    );
    this.token.set(response.token);
    this.user.set(response.user);
    this.sessionExpired.set(false);
    this.scheduleExpiry();
    try {
      localStorage.setItem(TOKEN_KEY, response.token);
      localStorage.setItem(USER_KEY, JSON.stringify(response.user));
    } catch { /* storage unavailable */ }
  }

  logout(): void {
    clearTimeout(this.expiryTimer);
    this.token.set(null);
    this.user.set(null);
    try {
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(USER_KEY);
    } catch { /* storage unavailable */ }
  }

  private scheduleExpiry(): void {
    clearTimeout(this.expiryTimer);
    const exp = this.token() ? expiresAt(this.token()!) : null;
    if (exp === null) return;
    this.expiryTimer = setTimeout(() => this.expireSession(), Math.max(0, exp - Date.now()));
  }
}

/** Vencimiento del JWT en ms (claim `exp`), o null si no se puede leer. */
function expiresAt(token: string): number | null {
  try {
    const payload = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
    const exp = JSON.parse(atob(payload)).exp;
    return typeof exp === 'number' ? exp * 1000 : null;
  } catch { return null; }
}

function isExpired(token: string): boolean {
  const exp = expiresAt(token);
  return exp === null || exp <= Date.now();
}
