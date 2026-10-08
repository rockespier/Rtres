import { Routes } from '@angular/router'; import { LoginComponent } from './components/login/login.component'; import { PortalShellComponent } from './components/portal-shell/portal-shell.component'; import { DashboardComponent } from './components/dashboard/dashboard.component'; import { TicketsListComponent } from './components/tickets-list/tickets-list.component'; import { TicketFormComponent } from './components/ticket-form/ticket-form.component'; import { TicketDetailComponent } from './components/ticket-detail/ticket-detail.component'; import { BillingComponent } from './components/billing/billing.component'; import { ProfileComponent } from './components/profile/profile.component'; import { TeamComponent } from './components/team/team.component'; import { AdminClientsComponent } from './components/admin-clients/admin-clients.component'; import { AdminClientDetailComponent } from './components/admin-client-detail/admin-client-detail.component'; import { AdminProductsComponent } from './components/admin-products/admin-products.component'; import { AdminTicketsComponent } from './components/admin-tickets/admin-tickets.component'; import { CatalogComponent } from './components/catalog/catalog.component'; import { PayPalReturnComponent } from './components/paypal-return/paypal-return.component'; import { authGuard } from './core/auth.guard'; import { TaxSettingsComponent } from './components/tax-settings/tax-settings.component'; import { TaxDocumentsComponent } from './components/tax-documents/tax-documents.component'; import { ExpensesComponent } from './components/expenses/expenses.component'; import { LearningVideosComponent } from './components/learning-videos/learning-videos.component'; import { PurchasesComponent } from './components/purchases/purchases.component'; import { TaxCalendarComponent } from './components/tax-calendar/tax-calendar.component'; import { ReportsComponent } from './components/reports/reports.component'; import { ServicesComponent } from './components/services/services.component'; import { clientAreaGuard, roleGuard } from './core/role.guard'; import { homeFor } from './core/nav'; import { AuthService } from './core/auth.service'; import { inject } from '@angular/core';

const superAdmin = roleGuard('SuperAdmin');
export const portalRoutes: Routes=[
  {path:'login',component:LoginComponent},
  {path:'billing/return',component:PayPalReturnComponent,canActivate:[authGuard]},
  {path:'',component:PortalShellComponent,canActivate:[authGuard],children:[
    // Va primero: el grupo del área del cliente (path '') también aceptaría la URL vacía.
    {path:'',pathMatch:'full',redirectTo:()=>homeFor(inject(AuthService).user()?.role)},
    // Área del cliente
    {path:'',canActivateChild:[clientAreaGuard],children:[
      {path:'dashboard',component:DashboardComponent},
      {path:'services',component:ServicesComponent},
      {path:'catalog',component:CatalogComponent},
      {path:'tickets',component:TicketsListComponent},
      {path:'tickets/new',component:TicketFormComponent},
      {path:'tickets/:id',component:TicketDetailComponent},
      {path:'billing',component:BillingComponent},
    ]},
    {path:'profile',component:ProfileComponent},
    {path:'team',component:TeamComponent,canActivate:[roleGuard('Admin')]},
    // Administración Rtres
    {path:'admin',canActivateChild:[superAdmin],children:[
      {path:'clients',component:AdminClientsComponent},
      {path:'clients/:id',component:AdminClientDetailComponent},
      {path:'products',component:AdminProductsComponent},
      {path:'tickets',component:AdminTicketsComponent},
      {path:'reports',component:ReportsComponent},
      {path:'tax-documents',component:TaxDocumentsComponent},
      {path:'expenses',component:ExpensesComponent},
      {path:'tax-settings',component:TaxSettingsComponent},
      {path:'learning-videos',component:LearningVideosComponent},
      {path:'purchases',component:PurchasesComponent},
      {path:'tax-calendar',component:TaxCalendarComponent},
    ]},
  ]},
  {path:'**',redirectTo:''},
];
