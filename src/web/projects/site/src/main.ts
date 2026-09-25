import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { SiteComponent } from './app/site.component';
import { siteRoutes } from './app/site.routes';
bootstrapApplication(SiteComponent, { providers: [provideRouter(siteRoutes)] });
