import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { HttpErrorResponse } from '@angular/common/http';
import { AuthService } from '../../core/auth.service';

/** Destino del enlace de acceso enviado por email: canjea el token por la sesión y entra al portal. */
@Component({selector:'app-login-link',standalone:true,imports:[CommonModule,RouterLink],template:`<main class="min-h-screen grid place-items-center px-5"><section class="card max-w-md w-full p-9 text-center"><div *ngIf="!error()" class="w-10 h-10 mx-auto rounded-full border-2 border-[color:var(--primary)] border-t-transparent animate-spin" aria-hidden="true"></div><h1 class="font-display text-2xl mt-5">{{error() ? 'No pudimos iniciar sesión' : 'Entrando al portal…'}}</h1><p class="text-muted mt-2" role="status">{{error() || 'Estamos verificando tu enlace de acceso.'}}</p><a *ngIf="error()" routerLink="/login" class="btn btn-primary btn-sm mt-5">Pedir un enlace nuevo</a></section></main>`})
export class LoginLinkComponent implements OnInit {
  private auth=inject(AuthService);private route=inject(ActivatedRoute);private router=inject(Router);
  error=signal('');
  async ngOnInit(){
    const token=this.route.snapshot.queryParamMap.get('t');
    // Quita el token de la barra de direcciones y del historial: es de un solo uso, pero no debe quedar a la vista.
    this.router.navigate([],{queryParams:{},replaceUrl:true});
    if(!token){this.error.set('El enlace está incompleto. Pide uno nuevo desde el inicio de sesión.');return;}
    try{await this.auth.loginWithLink(token);this.router.navigateByUrl('/');}
    catch(err){this.error.set(err instanceof HttpErrorResponse&&err.error?.message?err.error.message:'No se pudo verificar el enlace. Inténtalo de nuevo.');}
  }
}
