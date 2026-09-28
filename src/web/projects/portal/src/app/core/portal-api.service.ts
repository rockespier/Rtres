import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { PortalUiService } from './portal-ui.service';

export interface DashboardSummary {
  activeProducts: number;
  expiringSoon: number;
  openTickets: number;
  nextPaymentAmount: number | null;
}

export interface ProductDto { id: string; type: string; name: string; billingCycle: string; basePrice: number | null; currency: string; description?:string|null; isActive?:boolean; }
export interface ProjectDto { id: string; name: string; slug: string; githubRepoOwner?: string; githubRepoName?: string; }
export interface ClientAccessDto { clientName: string; email: string; temporaryPassword: string; emailSent: boolean; }

export interface ClientProductApiDto {
  id: string;
  status: string;
  renewsAt: string | null;
  nextChargeAt: string | null;
  lastBackupAt: string | null;
  price: number | null;
  priceLabelOverride: string | null;
  domainName: string | null;
  billingCycle: string;
  isManualBilling: boolean;
  payPalSubscriptionId?: string | null;
  product: ProductDto;
  project: ProjectDto;
}

export type TicketType = 'Bug' | 'Funcionalidad' | 'Requerimiento';
export type TicketStatus = 'Abierto' | 'EnProgreso' | 'Resuelto' | 'Publicado' | 'Cerrado';

export interface TicketDto {
  id: string;
  code: string;
  projectId: string;
  type: TicketType;
  status: TicketStatus;
  title: string;
  description: string;
  currentBehavior: string | null;
  expectedBehavior: string | null;
  stepsToReproduce: string | null;
  environment: string | null;
  acceptanceCriteria: string | null;
  estimatedImpact: string | null;
  createdAt: string;
  updatedAt: string;
  githubIssueNumber: number | null;
  githubIssueUrl: string | null;
}

export interface TicketCommentDto { id: string; body: string; fromGithub: boolean; authorName: string | null; createdAt: string; }

export interface TicketsPage { items: TicketDto[]; page: number; totalPages: number; }

export interface CreateTicketRequest {
  projectId: string;
  type: TicketType;
  title: string;
  description: string;
  currentBehavior?: string;
  expectedBehavior?: string;
  stepsToReproduce?: string;
  environment?: string;
  acceptanceCriteria?: string;
  estimatedImpact?: string;
}
export interface TeamUserDto { id:string; name:string; email:string; role:'Cliente'|'Admin'; isActive:boolean; }
export interface AdminClientDto { id:string; companyName:string; isActive:boolean; activeProducts:number; openTickets:number; }
export interface PaymentTransactionDto { id:string; createdAt:string; product:string; clientName:string; amount:number; currency:string; status:string; internalCode:string|null; }
export interface AdminClientDetailDto { id:string; companyName:string; contactName:string; email:string; phone:string|null; preferredLanguage:string; isActive:boolean; }
export interface AdminClientProductDto { id:string; clientId:string; projectId:string; projectName:string|null; productId:string; productName:string|null; productType:string|null; billingCycle:string; isManualBilling:boolean; status:string; price:number|null; domainName:string|null; priceLabelOverride:string|null; }

export interface TaxSettingsDto { igvRate:number; rentaRate:number; }
export interface ExchangeRateDto { date:string; currencyCode:string; rateToPen:number; source:string; }
export type TaxDocumentType = 'Factura'|'ReciboPorHonorarios';
export interface TaxDocumentDto { id:string; paymentTransactionId:string|null; clientId:string; type:TaxDocumentType; series:string; number:number; issueDate:string; currency:string; baseAmount:number; igvAmount:number; totalAmount:number; notes:string|null; }
export type ExpenseCategory = 'Hosting'|'Dominios'|'SuscripcionesIA'|'ApisPorUso'|'Sueldos'|'Otros';
export type ExpenseType = 'Fijo'|'Variable';
export interface ExpenseDto { id:string; description:string; category:ExpenseCategory; type:ExpenseType; amount:number; currency:string; amountPen:number; date:string; recurring:boolean; recurrenceCycle:string|null; }
export interface SalesReportDto { baseImponible:number; igv:number; total:number; }
export interface TaxSummaryReportDto { ventasGravadasPen:number; igvEstimado:number; rentaEstimada:number; tasa:{igvRate:number;rentaRate:number}; disclaimer:string; }
export interface ExpensesReportDto { total:number; porCategoria:{categoria:string;monto:number}[]; }
export interface NetReportDto { ventasPen:number; gastosPen:number; impuestosEstimadosPen:number; netoEstimadoPen:number; }

@Injectable({ providedIn: 'root' })
export class PortalApiService {
  private ui = inject(PortalUiService);
  constructor(private http: HttpClient) {}

  private get base() { return environment.apiBaseUrl; }
  private scoped(path: string): string { const id=this.ui.viewingClientId(); return id ? `${this.base}${path}${path.includes('?')?'&':'?'}clientId=${encodeURIComponent(id)}` : `${this.base}${path}`; }

  getDashboardSummary() { return this.http.get<DashboardSummary>(this.scoped('/dashboard/summary')); }
  getClientProducts() { return this.http.get<ClientProductApiDto[]>(this.scoped('/client-products')); }
  getCatalogProducts() { return this.http.get<ProductDto[]>(`${this.base}/catalog/products`); }
  subscribeProduct(body:{productId:string;projectId:string;billingCycle:string}) { return this.http.post<{clientProductId:string;approvalUrl:string}>(`${this.base}/subscriptions`, body); }
  renewProduct(id:string) { return this.http.post<{approvalUrl:string}>(this.scoped(`/client-products/${id}/renew`), {}); }
  cancelProduct(id:string) { return this.http.post(this.scoped(`/client-products/${id}/cancel`), {}); }
  captureClientProduct(id:string) { return this.http.post<{status:string}>(this.scoped(`/client-products/${id}/capture`), {}); }
  getClientProduct(id:string) { return this.http.get<ClientProductApiDto>(this.scoped(`/client-products/${id}`)); }
  getProjects() { return this.http.get<ProjectDto[]>(this.scoped('/projects')); }
  getProjectsForClient(clientId:string) { return this.http.get<ProjectDto[]>(`${this.base}/projects?clientId=${encodeURIComponent(clientId)}`); }
  getTickets(page = 1, filters: { status?: string; type?: string } = {}) {
    const q = [`page=${page}`, filters.status ? `status=${filters.status}` : '', filters.type ? `type=${filters.type}` : ''].filter(Boolean).join('&');
    return this.http.get<TicketsPage>(this.scoped(`/tickets?${q}`));
  }
  getTicket(id: string) { return this.http.get<{ ticket: TicketDto; comments: TicketCommentDto[] }>(this.scoped(`/tickets/${id}`)); }
  addTicketComment(id: string, body: string) { return this.http.post<TicketCommentDto>(`${this.base}/tickets/${id}/comments`, { body }); }
  createTicket(body: CreateTicketRequest) { return this.http.post<TicketDto>(`${this.base}/tickets`, body); }
  uploadAttachment(ticketId: string, file: File) {
    const form = new FormData();
    form.append('file', file);
    return this.http.post(`${this.base}/tickets/${ticketId}/attachments`, form);
  }
  getTransactions() { return this.http.get<PaymentTransactionDto[]>(this.scoped('/billing/transactions')); }
  getProfile() { return this.http.get<{name:string;email:string}>(`${this.base}/profile`); }
  updateProfile(name:string) { return this.http.patch(`${this.base}/profile`, {name}); }
  changePassword(currentPassword:string,newPassword:string) { return this.http.post(`${this.base}/profile/change-password`, {currentPassword,newPassword}); }
  getTeam() { return this.http.get<TeamUserDto[]>(`${this.base}/team/users`); }
  inviteTeam(name:string,email:string) { return this.http.post<{id:string;temporaryPassword:string;emailSent:boolean}>(`${this.base}/team/users`,{name,email}); }
  updateTeam(id:string, body:{role?:string;isActive?:boolean}) { return this.http.patch(`${this.base}/team/users/${id}`,body); }
  getAdminClients() { return this.http.get<AdminClientDto[]>(`${this.base}/admin/clients`); }
  getAdminClient(id:string) { return this.http.get<{client:AdminClientDetailDto;products:AdminClientProductDto[]}>(`${this.base}/admin/clients/${id}`); }
  createAdminClient(body: Omit<AdminClientDetailDto,'id'>) { return this.http.post<{client:AdminClientDetailDto;access:ClientAccessDto}>(`${this.base}/admin/clients`, body); }
  generateClientAccess(clientId:string) { return this.http.post<ClientAccessDto>(`${this.base}/admin/clients/${clientId}/access`, {}); }
  createProject(clientId:string, body:{name:string;slug?:string;githubRepoOwner?:string;githubRepoName?:string}) { return this.http.post<ProjectDto>(`${this.base}/admin/clients/${clientId}/projects`, body); }
  updateProject(id:string, body:{name?:string;githubRepoOwner?:string;githubRepoName?:string}) { return this.http.patch<ProjectDto>(`${this.base}/admin/projects/${id}`, body); }
  updateAdminClient(id:string,body:Partial<Omit<AdminClientDetailDto,'id'>>) { return this.http.patch<AdminClientDetailDto>(`${this.base}/admin/clients/${id}`,body); }
  importAdminClients(file:File) { const data=new FormData();data.append('file',file);return this.http.post<ImportResult>(`${this.base}/admin/clients/import`,data); }
  adminClientTemplate() { return this.http.get(`${this.base}/admin/clients/import/template`,{responseType:'blob'}); }
  getAdminProducts() { return this.http.get<ProductDto[]>(`${this.base}/admin/products`); }
  createAdminProduct(body: Omit<ProductDto,'id'>) { return this.http.post<ProductDto>(`${this.base}/admin/products`,body); }
  updateAdminProduct(id:string,body:Partial<Omit<ProductDto,'id'>>) { return this.http.patch<ProductDto>(`${this.base}/admin/products/${id}`,body); }
  importAdminProducts(file:File) { const data=new FormData();data.append('file',file);return this.http.post<ImportResult>(`${this.base}/admin/products/import`,data); }
  adminProductTemplate() { return this.http.get(`${this.base}/admin/products/import/template`,{responseType:'blob'}); }
  assignClientProduct(clientId:string,body:unknown) { return this.http.post<{clientProduct:AdminClientProductDto;approvalUrl:string|null}>(`${this.base}/admin/clients/${clientId}/products`,body); }
  updateAdminClientProduct(id:string,body:unknown) { return this.http.patch<AdminClientProductDto>(`${this.base}/admin/client-products/${id}`,body); }

  getTaxSettings() { return this.http.get<TaxSettingsDto>(`${this.base}/admin/tax-settings`); }
  updateTaxSettings(body:Partial<TaxSettingsDto>) { return this.http.patch<TaxSettingsDto>(`${this.base}/admin/tax-settings`,body); }
  syncExchangeRates() { return this.http.post<ExchangeRateDto[]>(`${this.base}/admin/exchange-rates/sync`,{}); }
  getExchangeRates() { return this.http.get<ExchangeRateDto[]>(`${this.base}/admin/exchange-rates`); }
  getTaxDocuments(params:{clientId?:string;month?:number;year?:number}={}) { return this.http.get<TaxDocumentDto[]>(`${this.base}/admin/tax-documents${query(params)}`); }
  createTaxDocument(body:Omit<TaxDocumentDto,'id'>) { return this.http.post<TaxDocumentDto>(`${this.base}/admin/tax-documents`,body); }
  getExpenses(params:{month?:number;year?:number;category?:string}={}) { return this.http.get<ExpenseDto[]>(`${this.base}/admin/expenses${query(params)}`); }
  createExpense(body:Omit<ExpenseDto,'id'|'amountPen'>) { return this.http.post<ExpenseDto>(`${this.base}/admin/expenses`,body); }
  updateExpense(id:string,body:Partial<Omit<ExpenseDto,'id'|'amountPen'>>) { return this.http.patch<ExpenseDto>(`${this.base}/admin/expenses/${id}`,body); }
  getSalesReport(month:number,year:number,currency:string) { return this.http.get<SalesReportDto>(`${this.base}/admin/reports/sales${query({month,year,currency})}`); }
  getTaxSummaryReport(month:number,year:number) { return this.http.get<TaxSummaryReportDto>(`${this.base}/admin/reports/tax-summary${query({month,year})}`); }
  getExpensesReport(month:number,year:number) { return this.http.get<ExpensesReportDto>(`${this.base}/admin/reports/expenses${query({month,year})}`); }
  getNetReport(month:number,year:number) { return this.http.get<NetReportDto>(`${this.base}/admin/reports/net${query({month,year})}`); }
}
function query(params:Record<string,string|number|undefined>) { const q=Object.entries(params).filter(([,v])=>v!=null&&v!=='').map(([k,v])=>`${k}=${encodeURIComponent(v!)}`).join('&'); return q?`?${q}`:''; }
export interface ImportResult { created:number; skipped:number; errors:{row:number;reason:string}[]; accesses?:ClientAccessDto[]; }
