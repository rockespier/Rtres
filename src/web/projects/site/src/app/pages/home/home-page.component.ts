import { Component } from '@angular/core';
import { HomeHeroComponent } from '../../components/home/hero.component';
import { HomeProofComponent } from '../../components/home/proof-strip.component';
import { HomeServicesComponent } from '../../components/home/services.component';
import { HomeCasesComponent } from '../../components/home/success-cases.component';
import { HomeSupportComponent } from '../../components/home/support.component';
import { HomeContactComponent } from '../../components/home/contact.component';
import { HomeFooterComponent } from '../../components/home/site-footer.component';

@Component({
  selector: 'app-home-page',
  standalone: true,
  imports: [HomeHeroComponent, HomeProofComponent, HomeServicesComponent, HomeCasesComponent, HomeSupportComponent, HomeContactComponent, HomeFooterComponent],
  template: `
    <main>
      <app-home-hero />
      <app-home-proof />
      <app-home-services />
      <app-home-cases />
      <app-home-support />
      <app-home-contact />
    </main>
    <app-home-footer />
  `,
  styles: [`:host{display:block;font-family:Arial,Helvetica,sans-serif;color:var(--v2-ink)}`],
})
export class HomePageComponent {}
