import { Routes } from '@angular/router';
import { SiteLayoutComponent } from './layout/site-layout.component';
import { HomePageComponent } from './pages/home/home-page.component';
import { ServicePageComponent } from './pages/service/service-page.component';
import { SERVICES } from './pages/service/service-content';
import { CasePageComponent } from './pages/case/case-page.component';
import { CASES } from './pages/case/case-content';
import { AboutPageComponent } from './pages/about/about-page.component';
import { ResourcesPageComponent } from './pages/resources/resources-page.component';
import { BlogPageComponent } from './pages/blog/blog-page.component';
import { BlogPostPageComponent } from './pages/blog/blog-post-page.component';
import { NotFoundPageComponent } from './pages/not-found/not-found-page.component';
import { ContactPageComponent } from './pages/contact/contact-page.component';
import { BLOG_SHELL_SLUG, casePath, pagePath, servicePath } from './core/site-paths';

export const siteRoutes: Routes = [
  {
    path: '',
    component: SiteLayoutComponent,
    children: [
      { path: '', component: HomePageComponent },
      // Slugs traducidos por idioma (core/site-paths.ts); data.slug es la clave del contenido.
      ...SERVICES.map(x => ({ path: servicePath(x.slug).slice(1), component: ServicePageComponent, data: { slug: x.slug } })),
      { path: pagePath('about').slice(1), component: AboutPageComponent },
      { path: pagePath('resources').slice(1), component: ResourcesPageComponent },
      { path: pagePath('blog').slice(1), component: BlogPageComponent },
      // Ruta fija para que se prerenderice la página base de los posts nuevos (ver site.htaccess).
      { path: `${pagePath('blog').slice(1)}/${BLOG_SHELL_SLUG}`, component: BlogPostPageComponent },
      { path: `${pagePath('blog').slice(1)}/:slug`, component: BlogPostPageComponent },
      { path: pagePath('contact').slice(1), component: ContactPageComponent },
      ...CASES.map(x => ({ path: casePath(x.slug).slice(1), component: CasePageComponent, data: { slug: x.slug } })),
      // El prefijo de idioma lo resuelve el build localizado (/es, /en, /it); esta ruta cubre el dev server.
      // Se prerenderiza en /{idioma}/404: el .htaccess la sirve con estado 404 para las URLs que no existen.
      { path: '404', component: NotFoundPageComponent },
      { path: ':lang', component: HomePageComponent },
      { path: '**', component: NotFoundPageComponent },
    ],
  },
];
