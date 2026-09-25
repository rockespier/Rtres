import { Routes } from '@angular/router'; import { HomeComponent } from './pages/home/home.component';
export const siteRoutes: Routes = [{ path: '', component: HomeComponent }, { path: ':lang', component: HomeComponent }];
