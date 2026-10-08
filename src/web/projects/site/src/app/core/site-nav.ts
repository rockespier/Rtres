/** Enlaces del menú, del pie y de la home: una sola lista para que todos apunten a las mismas páginas. */
export interface NavLink { path: string; label: string; }

export const SERVICE_LINKS: NavLink[] = [
  { path: '/servicios/software-a-medida', label: $localize`:@@home.services.1.title:Software a medida` },
  { path: '/servicios/apps-y-experiencias-web', label: $localize`:@@home.services.2.title:Apps y experiencias web` },
  { path: '/servicios/integracion-y-automatizacion', label: $localize`:@@home.services.3.title:Integración y automatización` },
  { path: '/servicios/hosting-dominios-y-soporte', label: $localize`:@@home.services.4.title:Hosting, dominios y soporte` },
];

export const CASE_LINKS: NavLink[] = [
  { path: '/casos/euroamerican-assistance', label: 'Euroamerican Assistance' },
  { path: '/casos/grupo-crosland', label: 'Grupo Crosland' },
];

export const PORTAL_URL = 'https://portal.rtres.net';
