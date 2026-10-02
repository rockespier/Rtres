import { Routes } from '@angular/router'; import { HomePageComponent } from './pages/home/home-page.component';
export const siteRoutes: Routes = [{ path: '', component: HomePageComponent }, { path: ':lang', component: HomePageComponent }];
