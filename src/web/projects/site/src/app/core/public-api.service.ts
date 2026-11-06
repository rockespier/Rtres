import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, catchError, of, timeout } from 'rxjs';
import { environment } from '../../environments/environment';

export interface WordPressProject { name: string; category: string; photoUrl: string | null; }
export interface WordPressReview { author: string; quote: string; }
/** Formulario de contacto; website es el campo trampa (oculto) contra bots. */
export interface ContactRequest { name: string; email: string; phone: string; company: string; service: string; message: string; locale: string; page: string; website: string; }
export interface PublicStats { activeClients: number; }
export interface PublicVideo { youtubeId: string; title: string; category: string; description: string | null; }
export interface BlogPostSummary { slug: string; title: string; excerpt: string; tag: string | null; publishedAt: string; readingMinutes: number; coverUrl: string | null; coverAlt: string | null; }
export interface BlogPost extends BlogPostSummary { html: string; updatedAt: string; related: BlogPostSummary[]; }

const REQUEST_TIMEOUT_MS = 5000;
/** El blog lee todos los posts del idioma de WordPress cuando vence el caché de la API. */
const BLOG_TIMEOUT_MS = 20000;

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

  /** Posts del idioma, sin el contenido; null si la API no responde. */
  getBlogPosts(locale: string): Observable<BlogPostSummary[] | null> {
    return this.http.get<BlogPostSummary[]>(`${environment.apiBaseUrl}/public/${locale}/blog`).pipe(timeout(BLOG_TIMEOUT_MS), catchError(() => of(null)));
  }

  /** Un post; null si no existe y 'error' si la API no responde (no es lo mismo: solo el primero es un 404). */
  getBlogPost(locale: string, slug: string): Observable<BlogPost | null | 'error'> {
    return this.http.get<BlogPost>(`${environment.apiBaseUrl}/public/${locale}/blog/${encodeURIComponent(slug)}`).pipe(
      timeout(BLOG_TIMEOUT_MS),
      catchError(error => of(error?.status === 404 ? null : 'error' as const)),
    );
  }

  /** Cifras públicas (clientes activos en el portal); null si la API no responde. */
  getStats(): Observable<PublicStats | null> {
    return this.safeGet<PublicStats | null>(`${environment.apiBaseUrl}/public/stats`, null);
  }

  /** Envía el formulario de contacto. A diferencia de las lecturas, los errores llegan al componente para mostrarlos. */
  sendContact(body: ContactRequest): Observable<unknown> {
    return this.http.post(`${environment.apiBaseUrl}/public/contact`, body).pipe(timeout(15000));
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
