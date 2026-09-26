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
export interface ProjectDto { id: string; name: string; slug: string; }

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

export interface TicketDto {
  id: string;
  code: string;
  type: string;
  status: string;
  title: string;
  description: string;
  updatedAt: string;
  githubIssueNumber: number | null;
  githubIssueUrl: string | null;
}

export interface TicketsPage { items: TicketDto[]; page: number; totalPages: number; }

export interface CreateTicketRequest {
  projectId: string;
  type: 'Soporte' | 'Cambio';
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
export interface PaymentTransactionDto { id:string; createdAt:string; product:string; amount:number; currency:string; status:string; }
export interface AdminClientDetailDto { id:string; companyName:string; contactName:string; email:string; phone:string|null; preferredLanguage:string; isActive:boolean; }
export interface AdminClientProductDto { id:string; clientId:string; projectId:string; projectName:string|null; productId:string; productName:string|null; productType:string|null; billingCycle:string; isManualBilling:boolean; status:string; price:number|null; domainName:string|null; priceLabelOverride:string|null; }

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
  getClientProduct(id:string) { return this.http.get<ClientProductApiDto>(this.scoped(`/client-products/${id}`)); }
  getProjects() { return this.http.get<ProjectDto[]>(this.scoped('/projects')); }
  getProjectsForClient(clientId:string) { return this.http.get<ProjectDto[]>(`${this.base}/projects?clientId=${encodeURIComponent(clientId)}`); }
  getTickets(page = 1) { return this.http.get<TicketsPage>(this.scoped(`/tickets?page=${page}`)); }
  getTicket(id: string) { return this.http.get<{ ticket: TicketDto; comments: unknown[] }>(`${this.base}/tickets/${id}`); }
  createTicket(body: CreateTicketRequest) { return this.http.post<TicketDto>(`${this.base}/tickets`, body); }
  uploadAttachment(ticketId: string, file: File) {
    const form = new FormData();
    form.append('file', file);
    return this.http.post(`${this.base}/tickets/${ticketId}/attachments`, form);
  }
  getTransactions() { return this.http.get<PaymentTransactionDto[]>(`${this.base}/billing/transactions`); }
  getProfile() { return this.http.get<{name:string;email:string}>(`${this.base}/profile`); }
  updateProfile(name:string) { return this.http.patch(`${this.base}/profile`, {name}); }
  changePassword(currentPassword:string,newPassword:string) { return this.http.post(`${this.base}/profile/change-password`, {currentPassword,newPassword}); }
  getTeam() { return this.http.get<TeamUserDto[]>(`${this.base}/team/users`); }
  inviteTeam(name:string,email:string) { return this.http.post<{id:string;temporaryPassword:string}>(`${this.base}/team/users`,{name,email}); }
  updateTeam(id:string, body:{role?:string;isActive?:boolean}) { return this.http.patch(`${this.base}/team/users/${id}`,body); }
  getAdminClients() { return this.http.get<AdminClientDto[]>(`${this.base}/admin/clients`); }
  getAdminClient(id:string) { return this.http.get<{client:AdminClientDetailDto;products:AdminClientProductDto[]}>(`${this.base}/admin/clients/${id}`); }
  createAdminClient(body: Omit<AdminClientDetailDto,'id'>) { return this.http.post<AdminClientDetailDto>(`${this.base}/admin/clients`, body); }
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
}
export interface ImportResult { created:number; skipped:number; errors:{row:number;reason:string}[]; }
