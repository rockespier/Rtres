import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HomeTopBarComponent } from '../components/home/top-bar.component';
import { HomeHeaderComponent } from '../components/home/site-header.component';
import { HomeFooterComponent } from '../components/home/site-footer.component';

/** Marco común de todas las páginas: barra de idiomas, cabecera fija y pie. */
@Component({
  selector: 'app-site-layout',
  standalone: true,
  imports: [RouterOutlet, HomeTopBarComponent, HomeHeaderComponent, HomeFooterComponent],
  template: `
    <app-home-top-bar />
    <app-home-header />
    <main><router-outlet /></main>
    <app-home-footer />
  `,
  styles: [`:host{display:block;font-family:Arial,Helvetica,sans-serif;color:var(--v2-ink)}`],
})
export class SiteLayoutComponent {}
