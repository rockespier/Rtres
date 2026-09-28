import { Component, OnDestroy, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { PortalApiService } from '../../core/portal-api.service';

@Component({selector:'app-paypal-return',standalone:true,imports:[CommonModule,RouterLink],template:`<main class="min-h-screen grid place-items-center p-6"><section class="card max-w-md p-8 text-center"><div *ngIf="!done()" class="w-10 h-10 mx-auto rounded-full border-2 border-[color:var(--primary)] border-t-transparent animate-spin"></div><h1 class="font-display text-2xl mt-5">{{done() ? 'Aún no hay confirmación' : 'Procesando tu pago…'}}</h1><p class="text-muted mt-2">{{message()}}</p><a *ngIf="done()" routerLink="/dashboard" class="btn btn-primary btn-sm mt-5">Volver al panel</a></section></main>`})
export class PayPalReturnComponent implements OnInit, OnDestroy {
  private api=inject(PortalApiService);private route=inject(ActivatedRoute);private router=inject(Router);private timer?:ReturnType<typeof setTimeout>; private attempts=0;message=signal('Esperando la confirmación segura de PayPal.');done=signal(false);
  ngOnInit(){const id=this.route.snapshot.queryParamMap.get('clientProductId');if(!id){this.router.navigateByUrl('/dashboard');return;}
  // Pide al backend que cobre la orden aprobada sin esperar al webhook; pase lo que pase, luego se consulta el estado.
  this.api.captureClientProduct(id).subscribe({next:()=>this.poll(id),error:()=>this.poll(id)});}
  ngOnDestroy(){if(this.timer)clearTimeout(this.timer);}
  private poll(id:string){this.api.getClientProduct(id).subscribe({next:product=>{if(product.status==='Activo'||product.status==='Cancelado'){this.router.navigateByUrl('/dashboard');return;}if(++this.attempts>=12){this.done.set(true);this.message.set('La confirmación está tardando un poco. Actualizaremos tu panel cuando llegue el aviso de PayPal.');return;}this.timer=setTimeout(()=>this.poll(id),2500);},error:()=>{this.done.set(true);this.message.set('No pudimos consultar el estado del pago.');}});}
}
