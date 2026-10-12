import { Component, OnInit, inject } from '@angular/core';
import { Meta, Title } from '@angular/platform-browser';
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
export class HomePageComponent implements OnInit {
  private title = inject(Title);
  private meta = inject(Meta);

  /** Título y description del home: el servicio y el lugar, que es lo que se busca (ver PLAN-seo.md, S3). */
  ngOnInit() {
    this.title.setTitle($localize`:@@home.metaTitle:Software a medida y desarrollo web en Lima, Perú | Rtres`);
    this.meta.updateTag({ name: 'description', content: $localize`:@@home.meta:Desarrollamos software a medida, apps web e integraciones con SAP y SUNAT para empresas en Perú, Italia y España. Socios tecnológicos desde 2007.` });
  }
}
