import { Injectable, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { environment } from '../../environments/environment';

export interface LoginResponse {
  token: string;
  user: { name: string | null; initials: string | null; clientName: string | null; role: 'Cliente' | 'Admin' | 'SuperAdmin' };
}

const TOKEN_KEY = 'rtres_portal_token';
const USER_KEY = 'rtres_portal_user';

/** Lee el vencimiento (claim exp) del JWT; si no se puede leer, lo da por vigente y decide la API (401). */
function tokenExpired(token: string): boolean {
  try {
    const payload = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
    const exp = JSON.parse(atob(payload)).exp;
    return typeof exp === 'number' && exp * 1000 <= Date.now();
  } catch { return false; }
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readTokenFromStorage(): string | null {
    try { return localStorage.getItem(TOKEN_KEY); } catch { return null; }
  }

  token = signal<string | null>(this.readTokenFromStorage());
  user = signal<LoginResponse['user'] | null>(this.readUserFromStorage());

  constructor(private http: HttpClient) {}

  private readUserFromStorage(): LoginResponse['user'] | null {
    try {
      const raw = localStorage.getItem(USER_KEY);
      return raw ? JSON.parse(raw) : null;
    } catch { return null; }
  }

  isAuthenticated(): boolean {
    const token = this.token();
    return !!token && !tokenExpired(token);
  }

  /** Hay una sesión guardada pero su token ya venció (dura 8 horas). */
  sessionExpired(): boolean {
    const token = this.token();
    return !!token && tokenExpired(token);
  }

  async login(email: string, password: string): Promise<void> {
    const response = await firstValueFrom(
      this.http.post<LoginResponse>(`${environment.apiBaseUrl}/auth/login`, { email, password })
    );
    this.token.set(response.token);
    this.user.set(response.user);
    try {
      localStorage.setItem(TOKEN_KEY, response.token);
      localStorage.setItem(USER_KEY, JSON.stringify(response.user));
    } catch { /* storage unavailable */ }
  }

  logout(): void {
    this.token.set(null);
    this.user.set(null);
    try {
      localStorage.removeItem(TOKEN_KEY);
      localStorage.removeItem(USER_KEY);
    } catch { /* storage unavailable */ }
  }
}
