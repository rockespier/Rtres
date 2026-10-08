import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, of, timeout } from 'rxjs';
import { environment } from '../../environments/environment';

export interface WordPressProject { name: string; category: string; photoUrl: string | null; }
export interface WordPressReview { author: string; quote: string; }
export interface PublicStats { activeClients: number; }
export interface PublicVideo { youtubeId: string; title: string; category: string; description: string | null; }

const REQUEST_TIMEOUT_MS = 5000;

@Injectable({ providedIn: 'root' })
export class PublicApiService {
  constructor(private http: HttpClient) {}

  getProjects(locale: string): Observable<WordPressProject[]> {
    return this.safeGet<WordPressProject[]>(`${environment.apiBaseUrl}/public/${locale}/projects`, []);
  }

  getReviews(locale: string): Observable<WordPressReview[]> {
    return this.safeGet<WordPressReview[]>(`${environment.apiBaseUrl}/public/${locale}/reviews`, []);
  }

  /** Videos publicados para la página Recursos (los administra el portal). */
  getVideos(locale: string): Observable<PublicVideo[] | null> {
    return this.safeGet<PublicVideo[] | null>(`${environment.apiBaseUrl}/public/${locale}/videos`, null);
  }

  /** Cifras públicas (clientes activos en el portal); null si la API no responde. */
  getStats(): Observable<PublicStats | null> {
    return this.safeGet<PublicStats | null>(`${environment.apiBaseUrl}/public/stats`, null);
  }

  getHeroPhoto(): Observable<{ url: string }> {
    return this.safeGet<{ url: string }>(`${environment.apiBaseUrl}/public/hero-photo`, { url: 'https://picsum.photos/id/48/900/1100' });
  }

  private safeGet<T>(url: string, fallback: T): Observable<T> {
    return this.http.get<T>(url).pipe(
      timeout(REQUEST_TIMEOUT_MS),
      catchError(() => of(fallback)),
    );
  }
}
