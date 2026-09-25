import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { provideServerRendering } from '@angular/platform-server';
import { SiteComponent } from './app/site.component'; import { siteRoutes } from './app/site.routes';
export default () => bootstrapApplication(SiteComponent, { providers: [provideServerRendering(), provideRouter(siteRoutes)] });
