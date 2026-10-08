import { Injectable, inject, signal } from '@angular/core';
import { PaymentMethodsDto, PortalApiService } from './portal-api.service';

/**
 * Medios de pago habilitados por Rtres (Configuración → Medios de pago). Se piden una vez por sesión; mientras cargan se
 * asumen ambos activos para no esconder botones que el backend igual valida.
 */
@Injectable({ providedIn: 'root' })
export class PaymentMethodsService {
  private api = inject(PortalApiService);
  readonly methods = signal<PaymentMethodsDto>({ payPal: true, bankTransfer: true });
  private loaded = false;

  load() {
    if (this.loaded) return;
    this.loaded = true;
    this.api.getPaymentMethods().subscribe({ next: x => this.methods.set(x), error: () => (this.loaded = false) });
  }

  set(methods: PaymentMethodsDto) { this.methods.set(methods); this.loaded = true; }
}
