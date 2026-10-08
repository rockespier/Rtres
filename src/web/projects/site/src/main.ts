import { bootstrapApplication, provideClientHydration } from '@angular/platform-browser';
import { provideRouter, withInMemoryScrolling } from '@angular/router';
import { provideHttpClient, withFetch } from '@angular/common/http';
import { SiteComponent } from './app/site.component';
import { siteRoutes } from './app/site.routes';
bootstrapApplication(SiteComponent, { providers: [provideRouter(siteRoutes, withInMemoryScrolling({ anchorScrolling: 'enabled', scrollPositionRestoration: 'enabled' })), provideClientHydration(), provideHttpClient(withFetch())] });
