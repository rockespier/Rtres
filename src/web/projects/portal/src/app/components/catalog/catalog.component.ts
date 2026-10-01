import { MoneyPipe } from '../../core/money.pipe';
import { Component, OnInit, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { PortalApiService, ProductDto, ProjectDto } from '../../core/portal-api.service';
import { SubscribeDialogComponent } from '../subscribe-dialog/subscribe-dialog.component';
import { PortalUiService } from '../../core/portal-ui.service';
import { BILLING_CYCLE_LABELS, EnumLabelPipe, PRODUCT_TYPE_LABELS } from '../../core/enum-labels';

const UNCATEGORIZED = 'Otros servicios';
/** Palabras que no ayudan a encontrar un producto ("necesito una web para mi negocio" → "web", "negocio"). */
const STOPWORDS = new Set(['necesito', 'necesitamos', 'quiero', 'queremos', 'busco', 'buscamos', 'tengo', 'tenemos', 'hacer', 'crear', 'tener', 'poner', 'una', 'uno', 'unos', 'unas', 'un', 'el', 'la', 'los', 'las', 'lo', 'de', 'del', 'para', 'por', 'mi', 'mis', 'su', 'sus', 'que', 'me', 'nos', 'en', 'y', 'o', 'con', 'sin', 'al', 'a', 'es', 'algo', 'como', 'mas', 'muy', 'ayuda', 'ayudar', 'ayudame', 'quisiera', 'favor', 'hola']);

const normalize = (text: string) => text.toLowerCase().normalize('NFD').replace(/[̀-ͯ]/g, '');
const words = (text: string | null | undefined) => normalize(text ?? '').split(/[^a-z0-9ñ]+/).filter(w => w.length >= 2);
/** "web" encuentra "webs"; "paginas" encuentra "pagina" (plurales y palabras incompletas mientras se escribe). */
const matches = (term: string, token: string) => term.startsWith(token) || (token.length >= 4 && term.length >= 3 && token.startsWith(term));

interface Scored { product: ProductDto; score: number; }

@Component({selector:'app-catalog',standalone:true,imports:[MoneyPipe,CommonModule,RouterLink,SubscribeDialogComponent,EnumLabelPipe],template:`
<h1 class="font-display text-2xl font-semibold">Catálogo</h1>
<p class="text-muted mt-1">Servicios que puedes agregar a tus proyectos.</p>

<section class="search card mt-6 p-6 lg:p-8">
  <label for="catalog-search" class="font-display text-xl lg:text-2xl font-semibold block">¿En qué podemos ayudarte? ¿Qué necesitas?</label>
  <div class="relative mt-4">
    <svg class="absolute left-4 top-1/2 -translate-y-1/2 text-muted" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
    <input id="catalog-search" class="field search-input" type="search" autocomplete="off" placeholder="Ej.: necesito una web para mi negocio" [value]="query()" (input)="query.set($any($event.target).value)">
  </div>
  <div class="flex flex-wrap gap-2 mt-4" role="group" aria-label="Categorías">
    <button type="button" class="chip" [class.active]="!category()" (click)="category.set(null)">Todas</button>
    <button type="button" class="chip" *ngFor="let c of categories()" [class.active]="category()===c" (click)="category.set(category()===c?null:c)">{{c}}</button>
  </div>
</section>

<ng-container *ngIf="searching(); else grouped">
  <p class="text-sm text-muted mt-8" *ngIf="results().length">Te recomendamos {{results().length===1?'este servicio':'estos '+results().length+' servicios'}} para «{{query().trim()}}»</p>
  <div class="grid md:grid-cols-2 xl:grid-cols-3 gap-5 mt-4" *ngIf="results().length; else noResults">
    <ng-container *ngFor="let r of results()"><ng-container *ngTemplateOutlet="card; context:{$implicit:r.product}"/></ng-container>
  </div>
  <ng-template #noResults><div class="card p-8 mt-8 text-center"><p class="font-semibold">No encontramos un servicio para «{{query().trim()}}».</p><p class="text-muted text-sm mt-1">Prueba con otras palabras o cuéntanos qué necesitas: te preparamos una cotización.</p></div></ng-template>
</ng-container>

<ng-template #grouped>
  <section *ngFor="let g of groups()" class="mt-10">
    <div class="flex items-baseline gap-3 border-b pb-2"><h2 class="font-display text-lg font-semibold">{{g.category}}</h2><span class="text-sm text-muted">{{g.products.length}}</span></div>
    <div class="grid md:grid-cols-2 xl:grid-cols-3 gap-5 mt-5"><ng-container *ngFor="let p of g.products"><ng-container *ngTemplateOutlet="card; context:{$implicit:p}"/></ng-container></div>
  </section>
</ng-template>

<ng-template #card let-product>
  <article class="card p-6 flex flex-col">
    <p class="stat-label">{{product.category || (product.type | enumLabel:'productType')}}</p>
    <h3 class="font-display text-xl font-semibold mt-2">{{product.name}}</h3>
    <p class="text-muted text-sm mt-2" *ngIf="product.description">{{product.description}}</p>
    <div class="mt-auto pt-5">
      <p class="font-display text-lg font-semibold tabular-nums">{{product.basePrice == null ? 'Según cotización' : (product.basePrice|money:product.currency)}}<span *ngIf="product.basePrice != null && product.igvRate" class="text-sm text-muted font-normal"> + IGV</span></p>
      <p class="text-xs text-muted mt-0.5">{{cycleLabel(product.billingCycle)}}</p>
      <button *ngIf="product.basePrice != null; else quote" class="btn btn-primary btn-sm mt-4" (click)="selected.set(product)">Agregar</button>
      <ng-template #quote><a class="btn btn-primary btn-sm mt-4" routerLink="/tickets/new" [queryParams]="{type:'Requerimiento', title:'Cotización: '+product.name}">Solicitar cotización</a></ng-template>
    </div>
  </article>
</ng-template>

<app-subscribe-dialog *ngIf="selected() as product" [product]="product" [projects]="projects()" (closed)="selected.set(null)"/>`,
styles:[`
.search-input{padding:16px 16px 16px 48px;font-size:17px;border-radius:14px}
.chip{padding:6px 14px;border-radius:99px;font-size:13px;font-weight:600;color:var(--muted);border:1px solid var(--border);background:var(--surface)}
.chip:hover{color:var(--ink)}
.chip.active{background:var(--ink);color:var(--surface);border-color:var(--ink)}
`]})
export class CatalogComponent implements OnInit {
  private api=inject(PortalApiService);private ui=inject(PortalUiService);
  products=signal<ProductDto[]>([]);projects=signal<ProjectDto[]>([]);selected=signal<ProductDto|null>(null);
  query=signal('');category=signal<string|null>(null);
  ngOnInit(){this.ui.breadcrumb.set({current:'Catálogo'});this.api.getCatalogProducts().subscribe(x=>this.products.set(x));this.api.getProjects().subscribe(x=>this.projects.set(x));}

  categories=computed(()=>[...new Set(this.products().map(p=>p.category||UNCATEGORIZED))].sort((a,b)=>a===UNCATEGORIZED?1:b===UNCATEGORIZED?-1:a.localeCompare(b,'es')));
  private inCategory=computed(()=>this.products().filter(p=>!this.category()||(p.category||UNCATEGORIZED)===this.category()));
  private tokens=computed(()=>words(this.query()).filter(w=>!STOPWORDS.has(w)));
  searching=computed(()=>this.tokens().length>0);
  groups=computed(()=>this.categories().filter(c=>!this.category()||c===this.category()).map(category=>({category,products:this.inCategory().filter(p=>(p.category||UNCATEGORIZED)===category)})).filter(g=>g.products.length));

  /** Productos con coincidencias en etiquetas (pesan más), nombre, categoría, tipo o descripción, del más al menos relevante. */
  results=computed(()=>{
    const tokens=this.tokens();
    return this.inCategory().map<Scored>(product=>{
      const fields:[string[],number][]=[[(product.tags??'').split(',').flatMap(words),3],[words(product.name),2],[words(product.category),2],[words(PRODUCT_TYPE_LABELS[product.type]??product.type),2],[words(product.description),1]];
      const score=tokens.reduce((sum,token)=>sum+Math.max(0,...fields.map(([terms,weight])=>terms.some(t=>matches(t,token))?weight:0)),0);
      return {product,score};
    }).filter(x=>x.score>0).sort((a,b)=>b.score-a.score||a.product.name.localeCompare(b.product.name,'es'));
  });

  cycleLabel(cycle:string){return cycle==='Unico'?'Pago único':`Pago ${(BILLING_CYCLE_LABELS[cycle]??cycle).toLowerCase()}`;}
}
