import { Routes } from '@angular/router';
import { SiteLayoutComponent } from './layout/site-layout.component';
import { HomePageComponent } from './pages/home/home-page.component';
import { SERVICES } from './pages/service/service-content';
import { CASES } from './pages/case/case-content';
import { NotFoundPageComponent } from './pages/not-found/not-found-page.component';
import { BLOG_SHELL_SLUG, casePath, pagePath, servicePath } from './core/site-paths';

// La home va en el bundle inicial; el resto de páginas se cargan con su ruta (menos JS para el LCP de la home).
const servicePage = () => import('./pages/service/service-page.component').then(m => m.ServicePageComponent);
const casePage = () => import('./pages/case/case-page.component').then(m => m.CasePageComponent);
const legalPage = () => import('./pages/legal/legal-page.component').then(m => m.LegalPageComponent);
const blogPostPage = () => import('./pages/blog/blog-post-page.component').then(m => m.BlogPostPageComponent);

export const siteRoutes: Routes = [
  {
    path: '',
    component: SiteLayoutComponent,
    children: [
      { path: '', component: HomePageComponent },
      // Slugs traducidos por idioma (core/site-paths.ts); data.slug es la clave del contenido.
      ...SERVICES.map(x => ({ path: servicePath(x.slug).slice(1), loadComponent: servicePage, data: { slug: x.slug } })),
      { path: pagePath('about').slice(1), loadComponent: () => import('./pages/about/about-page.component').then(m => m.AboutPageComponent) },
      { path: pagePath('resources').slice(1), loadComponent: () => import('./pages/resources/resources-page.component').then(m => m.ResourcesPageComponent) },
      { path: pagePath('blog').slice(1), loadComponent: () => import('./pages/blog/blog-page.component').then(m => m.BlogPageComponent) },
      // Ruta fija para que se prerenderice la página base de los posts nuevos (ver site.htaccess).
      { path: `${pagePath('blog').slice(1)}/${BLOG_SHELL_SLUG}`, loadComponent: blogPostPage },
      { path: `${pagePath('blog').slice(1)}/:slug`, loadComponent: blogPostPage },
      { path: pagePath('contact').slice(1), loadComponent: () => import('./pages/contact/contact-page.component').then(m => m.ContactPageComponent) },
      { path: pagePath('privacy').slice(1), loadComponent: legalPage, data: { doc: 'privacy' } },
      { path: pagePath('legal').slice(1), loadComponent: legalPage, data: { doc: 'legal' } },
      ...CASES.map(x => ({ path: casePath(x.slug).slice(1), loadComponent: casePage, data: { slug: x.slug } })),
      // El prefijo de idioma lo resuelve el build localizado (/es, /en, /it); esta ruta cubre el dev server.
      // Se prerenderiza en /{idioma}/404: el .htaccess la sirve con estado 404 para las URLs que no existen.
      { path: '404', component: NotFoundPageComponent },
      { path: ':lang', component: HomePageComponent },
      { path: '**', component: NotFoundPageComponent },
    ],
  },
];
