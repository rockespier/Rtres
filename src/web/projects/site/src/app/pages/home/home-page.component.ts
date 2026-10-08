import { Component } from '@angular/core';
import { HomeHeroComponent } from '../../components/home/hero.component';
import { HomeProofComponent } from '../../components/home/proof-strip.component';
import { HomeServicesComponent } from '../../components/home/services.component';
import { HomeCasesComponent } from '../../components/home/success-cases.component';
import { HomeSupportComponent } from '../../components/home/support.component';
import { HomeContactComponent } from '../../components/home/contact.component';

/** Home: las secciones; la cabecera y el pie los pone SiteLayoutComponent. */
@Component({
  selector: 'app-home-page',
  standalone: true,
  imports: [HomeHeroComponent, HomeProofComponent, HomeServicesComponent, HomeCasesComponent, HomeSupportComponent, HomeContactComponent],
  template: `
    <app-home-hero />
    <app-home-proof />
    <app-home-services />
    <app-home-cases />
    <app-home-support />
    <app-home-contact />
  `,
})
export class HomePageComponent {}
