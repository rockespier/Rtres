import { Component } from '@angular/core';import { CommonModule } from '@angular/common';import { NumRowComponent } from '../num-row/num-row.component';
@Component({selector:'app-features',standalone:true,imports:[CommonModule,NumRowComponent],template:`<section id="features" class="relative py-28 border-t border-black/5"><div class="wrap"><h2 class="font-display text-4xl font-bold" i18n="@@features.title">Todo lo que tu negocio necesita, en un solo partner</h2><p class="lead mt-3" i18n="@@features.sub">De la idea al lanzamiento, y del lanzamiento al crecimiento sostenido.</p><div class="mt-12"><app-num-row *ngFor="let f of features;let i=index" [index]="'0'+(i+1)" [title]="f.title" [description]="f.desc" [ctaLabel]="i===5 ? portalLabel : undefined"/></div></div></section>`}) export class FeaturesComponent{
  portalLabel=$localize`:@@feat.6.cta:Preview del portal →`;
  features=[
    {title:$localize`:@@feat.1.title:Diseño de sitios web`,desc:$localize`:@@feat.1.desc:Sitios rápidos, responsivos y orientados a conversión.`},
    {title:$localize`:@@feat.2.title:SEO & SEM`,desc:$localize`:@@feat.2.desc:Posicionamos tu marca entre los primeros resultados.`},
    {title:$localize`:@@feat.3.title:Desarrollo a medida`,desc:$localize`:@@feat.3.desc:Sistemas y plataformas construidas para tu operación.`},
    {title:$localize`:@@feat.4.title:E-commerce`,desc:$localize`:@@feat.4.desc:Catálogo, carrito y pasarela de pagos integrados.`},
    {title:$localize`:@@feat.5.title:Soporte y mantenimiento`,desc:$localize`:@@feat.5.desc:Planes mensuales con tickets y tiempos de respuesta claros.`},
    {title:$localize`:@@feat.6.title:Portal de clientes`,desc:$localize`:@@feat.6.desc:Gestiona tus productos, pagos y soporte en un solo panel.`},
  ];
}
