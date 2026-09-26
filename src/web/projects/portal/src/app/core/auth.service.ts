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
    return !!this.token();
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
