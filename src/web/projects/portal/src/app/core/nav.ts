import { IconName } from '../components/icon/icon.component';

export type PortalRole = 'Cliente' | 'Admin' | 'SuperAdmin';

export interface NavItem { label: string; link: string; icon: IconName; }
export interface NavGroup { label?: string; items: NavItem[]; }

/** Área del cliente: lo que ve un Cliente/Admin, y el SuperAdmin cuando está "viendo como" un cliente. */
const CLIENT_AREA: NavItem[] = [
  { label: 'Inicio', link: '/dashboard', icon: 'home' },
  { label: 'Mis tickets', link: '/tickets', icon: 'ticket' },
  { label: 'Mis servicios', link: '/services', icon: 'box' },
  { label: 'Contratar', link: '/catalog', icon: 'plus-square' },
  { label: 'Facturación', link: '/billing', icon: 'receipt' },
];

/**
 * Menú según el rol: cada usuario ve solo lo que puede usar.
 * El backend sigue siendo quien autoriza; esto (y roleGuard) solo evita mostrar o abrir pantallas que darían 403.
 */
export function navFor(role: PortalRole | undefined, viewingClient: string | null): NavGroup[] {
  if (role === 'SuperAdmin') {
    const groups: NavGroup[] = [
      { label: 'Operación', items: [
        { label: 'Clientes', link: '/admin/clients', icon: 'building' },
        { label: 'Tickets', link: '/admin/tickets', icon: 'ticket' },
        { label: 'Productos', link: '/admin/products', icon: 'layers' },
      ] },
      { label: 'Finanzas', items: [
        { label: 'Reportes', link: '/admin/reports', icon: 'chart' },
        { label: 'Documentos tributarios', link: '/admin/tax-documents', icon: 'file' },
        { label: 'Gastos', link: '/admin/expenses', icon: 'wallet' },
        { label: 'Tasas e impuestos', link: '/admin/tax-settings', icon: 'percent' },
      ] },
    ];
    if (viewingClient) groups.push({ label: `Viendo: ${viewingClient}`, items: CLIENT_AREA.filter(i => i.link !== '/catalog') });
    groups.push({ items: [{ label: 'Mi cuenta', link: '/profile', icon: 'user' }] });
    return groups;
  }
  const items = [...CLIENT_AREA, { label: 'Mi cuenta', link: '/profile', icon: 'user' as const }];
  if (role === 'Admin') items.push({ label: 'Equipo', link: '/team', icon: 'users' });
  return [{ items }];
}

/** Pantalla de entrada según el rol. */
export const homeFor = (role: PortalRole | undefined): string => role === 'SuperAdmin' ? '/admin/clients' : '/dashboard';
