import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { PortalApiService } from '../../core/portal-api.service';

@Component({selector:'app-paypal-return',standalone:true,template:`<main class="min-h-screen grid place-items-center p-6"><section class="card max-w-md p-8 text-center"><div class="w-10 h-10 mx-auto rounded-full border-2 border-[color:var(--primary)] border-t-transparent animate-spin"></div><h1 class="font-display text-2xl mt-5">Procesando tu pago…</h1><p class="text-muted mt-2">{{message()}}</p></section></main>`})
export class PayPalReturnComponent implements OnInit, OnDestroy {
  private api=inject(PortalApiService);private route=inject(ActivatedRoute);private router=inject(Router);private timer?:ReturnType<typeof setTimeout>; private attempts=0;message=signal('Esperando la confirmación segura de PayPal.');
  ngOnInit(){const id=this.route.snapshot.queryParamMap.get('clientProductId');if(!id){this.router.navigateByUrl('/dashboard');return;}this.poll(id);}
  ngOnDestroy(){if(this.timer)clearTimeout(this.timer);}
  private poll(id:string){this.api.getClientProduct(id).subscribe({next:product=>{if(product.status==='Activo'||product.status==='Cancelado'){this.router.navigateByUrl('/dashboard');return;}if(++this.attempts>=12){this.message.set('La confirmación está tardando un poco. Actualizaremos tu panel cuando llegue el aviso de PayPal.');return;}this.timer=setTimeout(()=>this.poll(id),2500);},error:()=>{this.message.set('No pudimos consultar el estado del pago.');}});}
}
