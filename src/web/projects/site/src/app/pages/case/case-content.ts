/** Contenido de cada caso de éxito. Fuente: Documentacion/Casos de exito Rtres.docx y Opiniones.docx. */
export interface CaseStat { value: string; label: string; }
export interface CaseGroup { title: string | null; rows: { title: string; text: string }[]; }
export interface CaseContent {
  slug: string;
  sector: string;
  name: string;
  intro: string;
  metaDescription: string;
  stats: CaseStat[];
  /** Recorte de casos_exito.png: tamaño y posición del fondo, y proporción del recuadro. */
  /** Recorte de casos_exito.png; width = ancho real del recorte en px (no se muestra más grande para que no pierda nitidez). */
  shot: { size: string; position: string; ratio: string; width: number };
  challenge: string;
  solution: CaseGroup[];
  integrations: string[];
  impact: string;
  testimonial: { quote: string; author: string; role: string } | null;
  services: { path: string; label: string }[];
  next: { path: string; name: string };
}

export const CASES: CaseContent[] = [
  {
    slug: 'euroamerican-assistance',
    sector: $localize`:@@case.eua.sector:Asistencia al viajero y seguros`,
    name: 'Euroamerican Assistance',
    intro: $localize`:@@case.eua.intro:Líder en asistencia al viajero con más de 20 años de experiencia y operación 24/7 en todo el mundo.`,
    metaDescription: $localize`:@@case.eua.meta:Caso de éxito: sistema central de ventas, comisiones, cobranza y business intelligence para Euroamerican Assistance, desde 2008.`,
    stats: [
      { value: '2008', label: $localize`:@@case.eua.stat1:socios tecnológicos desde` },
      { value: '15+', label: $localize`:@@case.eua.stat2:años de operación estable` },
      { value: '24/7', label: $localize`:@@case.eua.stat3:operación global sostenida` },
    ],
    shot: { size: '213.5% auto', position: '4.2% 79.4%', ratio: '783 / 330', width: 783 },
    challenge: $localize`:@@case.eua.challenge:Sostener una operación crítica que no puede detenerse, con coberturas médicas y legales complejas y un flujo financiero internacional.`,
    solution: [
      {
        title: null,
        rows: [
          { title: $localize`:@@case.eua.row1.title:Sistema integral de ventas`, text: $localize`:@@case.eua.row1.text:Administración total de productos, cálculo automático de comisiones, incentivos y beneficios.` },
          { title: $localize`:@@case.eua.row2.title:Business intelligence`, text: $localize`:@@case.eua.row2.text:Tableros gráficos para monitorear ingresos y reportes ejecutivos para la dirección.` },
          { title: $localize`:@@case.eua.row3.title:Gestión financiera`, text: $localize`:@@case.eua.row3.text:Módulo de cobranza integrado para asegurar la liquidez del negocio.` },
          { title: $localize`:@@case.eua.row4.title:Venta online`, text: $localize`:@@case.eua.row4.text:Un sistema de venta en línea que da al equipo comercial una ventaja tecnológica frente a la competencia.` },
        ],
      },
    ],
    integrations: [$localize`:@@case.eua.int1:Ventas y comisiones`, $localize`:@@case.eua.int2:Cobranza`, $localize`:@@case.eua.int3:Reportes ejecutivos`, $localize`:@@case.eua.int4:Venta online`],
    impact: $localize`:@@case.eua.impact:Estabilidad operativa y administrativa garantizada por más de 15 años, con un sistema que evoluciona al ritmo del negocio.`,
    testimonial: {
      quote: $localize`:@@testimonial.weston:Rtres cumple en exceso con nuestras expectativas. Hemos desarrollado un sistema de venta online que nos permite trabajar con una ventaja tecnológica, lo cual se traduce en un mejor producto para nuestros clientes.`,
      author: 'Erick Weston',
      role: $localize`:@@case.eua.role:Gerente comercial, Euroamerican Assistance`,
    },
    services: [
      { path: '/servicios/software-a-medida', label: $localize`:@@home.services.1.title:Software a medida` },
      { path: '/servicios/hosting-dominios-y-soporte', label: $localize`:@@home.services.4.title:Hosting, dominios y soporte` },
    ],
    next: { path: '/casos/grupo-crosland', name: 'Grupo Crosland' },
  },
  {
    slug: 'grupo-crosland',
    sector: $localize`:@@case.crosland.sector:Automotriz y servicio técnico`,
    name: 'Grupo Crosland',
    intro: $localize`:@@case.crosland.intro:Representante oficial en el Perú de Kawasaki y Bajaj, con una red de servicio postventa en todo el país.`,
    metaDescription: $localize`:@@case.crosland.meta:Caso de éxito: sistemas de gestión de talleres (DMS) integrados con SAP para Kawasaki y más de 300 talleres Bajaj del Grupo Crosland.`,
    stats: [
      { value: '300+', label: $localize`:@@case.crosland.stat1:talleres Bajaj conectados` },
      { value: 'SAP', label: $localize`:@@case.crosland.stat2:stock y garantías en tiempo real` },
      { value: '2', label: $localize`:@@case.crosland.stat3:marcas: Kawasaki y Bajaj` },
    ],
    shot: { size: '205.2% auto', position: '100% 79.4%', ratio: '815 / 330', width: 815 },
    challenge: $localize`:@@case.crosland.challenge:Digitalizar y controlar la operación de talleres mecánicos y la venta de repuestos, con una sincronización precisa con el inventario corporativo.`,
    solution: [
      {
        title: $localize`:@@case.crosland.group1:Taller Kawasaki`,
        rows: [
          { title: $localize`:@@case.crosland.row1.title:Órdenes de trabajo y presupuestos`, text: $localize`:@@case.crosland.row1.text:Gestión completa del taller, desde la recepción del vehículo hasta la entrega.` },
          { title: $localize`:@@case.crosland.row2.title:Integración con SAP`, text: $localize`:@@case.crosland.row2.text:Consulta de stock en tiempo real y reserva de repuestos en almacén.` },
          { title: $localize`:@@case.crosland.row3.title:Facturación`, text: $localize`:@@case.crosland.row3.text:Interfaz automática para generar los comprobantes.` },
        ],
      },
      {
        title: $localize`:@@case.crosland.group2:Red de talleres Bajaj`,
        rows: [
          { title: $localize`:@@case.crosland.row4.title:Control de reparaciones`, text: $localize`:@@case.crosland.row4.text:Seguimiento masivo de reparaciones y de la eficiencia técnica de cada taller.` },
          { title: $localize`:@@case.crosland.row5.title:Gestión de garantías`, text: $localize`:@@case.crosland.row5.text:Creación y seguimiento de reclamos de garantía directo a fábrica.` },
          { title: $localize`:@@case.crosland.row6.title:Sincronización con SAP`, text: $localize`:@@case.crosland.row6.text:Repuestos y validación de garantías sincronizados por completo.` },
        ],
      },
    ],
    integrations: ['SAP', $localize`:@@case.crosland.int2:Inventario corporativo`, $localize`:@@case.crosland.int3:Facturación`, $localize`:@@case.crosland.int4:Garantías de fábrica`],
    impact: $localize`:@@case.crosland.impact:Un flujo de trabajo técnico optimizado y control absoluto del inventario de repuestos en toda la red.`,
    testimonial: null,
    services: [
      { path: '/servicios/software-a-medida', label: $localize`:@@home.services.1.title:Software a medida` },
      { path: '/servicios/integracion-y-automatizacion', label: $localize`:@@home.services.3.title:Integración y automatización` },
    ],
    next: { path: '/casos/euroamerican-assistance', name: 'Euroamerican Assistance' },
  },
];
