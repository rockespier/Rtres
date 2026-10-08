import { Routes } from '@angular/router';
import { SiteLayoutComponent } from './layout/site-layout.component';
import { HomePageComponent } from './pages/home/home-page.component';
import { ServicePageComponent } from './pages/service/service-page.component';
import { SERVICES } from './pages/service/service-content';
import { CasePageComponent } from './pages/case/case-page.component';
import { CASES } from './pages/case/case-content';
import { AboutPageComponent } from './pages/about/about-page.component';
import { ResourcesPageComponent } from './pages/resources/resources-page.component';

export const siteRoutes: Routes = [
  {
    path: '',
    component: SiteLayoutComponent,
    children: [
      { path: '', component: HomePageComponent },
      ...SERVICES.map(x => ({ path: `servicios/${x.slug}`, component: ServicePageComponent, data: { slug: x.slug } })),
      { path: 'nosotros', component: AboutPageComponent },
      { path: 'recursos', component: ResourcesPageComponent },
      ...CASES.map(x => ({ path: `casos/${x.slug}`, component: CasePageComponent, data: { slug: x.slug } })),
      // El prefijo de idioma lo resuelve el build localizado (/es, /en, /it); esta ruta cubre el dev server.
      { path: ':lang', component: HomePageComponent },
    ],
  },
  { path: '**', redirectTo: '' },
];
