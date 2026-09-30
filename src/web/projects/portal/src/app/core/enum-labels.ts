import { Pipe, PipeTransform } from '@angular/core';

// Etiquetas legibles para los enums del backend que se muestran como texto plano (no como pill con su propio componente).
export const PRODUCT_TYPE_LABELS: Record<string, string> = {
  Hosting: 'Hosting', Dominio: 'Dominio', Ssl: 'SSL', BackupBd: 'Backup de BD', SoporteMensual: 'Soporte mensual', DesarrolloWeb: 'Desarrollo web',
};
export const BILLING_CYCLE_LABELS: Record<string, string> = { Unico: 'Único', Mensual: 'Mensual', Bimestral: 'Bimestral', Trimestral: 'Trimestral', Semestral: 'Semestral', Anual: 'Anual' };
/** Meses entre cobros de los ciclos por suscripción (PayPal cobra solo; usan próximo cobro). Único y Anual se pagan por periodo (vencimiento). */
export const SUBSCRIPTION_MONTHS: Record<string, number> = { Mensual: 1, Bimestral: 2, Trimestral: 3, Semestral: 6 };
export const isSubscriptionCycle = (cycle: string): boolean => cycle in SUBSCRIPTION_MONTHS;
export const EXPENSE_CATEGORY_LABELS: Record<string, string> = {
  Hosting: 'Hosting', Dominios: 'Dominios', SuscripcionesIA: 'Suscripciones IA', ApisPorUso: 'APIs por uso', Sueldos: 'Sueldos', Otros: 'Otros', ImpuestoRenta: 'Impuesto a la Renta', Comisiones: 'Comisiones',
};
export const EXPENSE_TYPE_LABELS: Record<string, string> = { Fijo: 'Fijo', Variable: 'Variable' };
export const CLIENT_PRODUCT_STATUS_LABELS: Record<string, string> = {
  Activo: 'Activo', PorVencer: 'Por vencer', Vencido: 'Vencido', Cancelado: 'Cancelado', Pendiente: 'Pendiente',
};

const REGISTRY = { productType: PRODUCT_TYPE_LABELS, billingCycle: BILLING_CYCLE_LABELS, expenseCategory: EXPENSE_CATEGORY_LABELS, expenseType: EXPENSE_TYPE_LABELS, clientProductStatus: CLIENT_PRODUCT_STATUS_LABELS };

@Pipe({ name: 'enumLabel', standalone: true })
export class EnumLabelPipe implements PipeTransform {
  transform(value: string, kind: keyof typeof REGISTRY): string { return REGISTRY[kind][value] ?? value; }
}
