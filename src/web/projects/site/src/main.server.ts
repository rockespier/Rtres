import { BootstrapContext, bootstrapApplication } from '@angular/platform-browser';
import { provideServerRendering } from '@angular/platform-server';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withFetch } from '@angular/common/http';
import { SiteComponent } from './app/site.component';
import { siteRoutes } from './app/site.routes';

const bootstrap = (context: BootstrapContext) =>
  bootstrapApplication(SiteComponent, { providers: [provideRouter(siteRoutes), provideServerRendering(), provideHttpClient(withFetch())] }, context);

export default bootstrap;
