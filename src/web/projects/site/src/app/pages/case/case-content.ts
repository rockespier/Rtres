import { casePath, servicePath } from '../../core/site-paths';
/** Contenido de cada caso de éxito. Fuente: Documentacion/Casos de exito Rtres.docx, Opiniones.docx y caso-exito-alas.md. */
export interface CaseStat { value: string; label: string; }
export interface CaseGroup { title: string | null; rows: { title: string; text: string }[]; }
export interface CaseContent {
  slug: string;
  sector: string;
  name: string;
  intro: string;
  metaDescription: string;
  stats: CaseStat[];
  /** Recorte de casos_exito.webp; width = ancho real del recorte en px (no se muestra más grande para que no pierda nitidez). Sin captura: null (panel con el nombre). */
  shot: { size: string; position: string; ratio: string; width: number } | null;
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
      { path: servicePath('software-a-medida'), label: $localize`:@@home.services.1.title:Software a medida` },
      { path: servicePath('hosting-dominios-y-soporte'), label: $localize`:@@home.services.4.title:Hosting, dominios y soporte` },
    ],
    next: { path: casePath('grupo-crosland'), name: 'Grupo Crosland' },
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
      { path: servicePath('software-a-medida'), label: $localize`:@@home.services.1.title:Software a medida` },
      { path: servicePath('integracion-y-automatizacion'), label: $localize`:@@home.services.3.title:Integración y automatización` },
    ],
    next: { path: casePath('alas-global-tour'), name: 'ALAS Global Tour' },
  },
  {
    slug: 'alas-global-tour',
    sector: $localize`:@@case.alas.sector:Deportes y eventos internacionales`,
    name: 'ALAS Global Tour',
    intro: $localize`:@@case.alas.intro:Circuito internacional de surf, con campeonatos en varios países y una comunidad de atletas, organizadores y aficionados. Plataforma en desarrollo.`,
    metaDescription: $localize`:@@case.alas.meta:Caso de éxito: plataforma web multiidioma para ALAS Global Tour, con inscripciones, pagos online y en playa, resultados de surf en vivo y rankings.`,
    stats: [
      { value: '70%', label: $localize`:@@case.alas.stat1:menos tiempo de inscripción (objetivo)` },
      { value: '85%', label: $localize`:@@case.alas.stat2:menos trabajo administrativo manual (objetivo)` },
      { value: '3', label: $localize`:@@case.alas.stat3:idiomas: español, inglés y portugués` },
    ],
    shot: null,
    challenge: $localize`:@@case.alas.challenge:Pasar de un portal en ASP clásico lleno de procesos manuales a una plataforma que conecte inscripciones, pagos, resultados y contenidos de un circuito que compite en varios países.`,
    solution: [
      {
        title: $localize`:@@case.alas.group1:Atletas y aficionados`,
        rows: [
          { title: $localize`:@@case.alas.row1.title:Inscripciones digitales`, text: $localize`:@@case.alas.row1.text:El atleta elige campeonato y categoría, valida sus datos y se inscribe desde el teléfono.` },
          { title: $localize`:@@case.alas.row2.title:Pago online o en playa`, text: $localize`:@@case.alas.row2.text:Pasarela de pago integrada, o inscripción con pago pendiente que el staff confirma en el evento. Todo en un mismo control.` },
          { title: $localize`:@@case.alas.row3.title:Resultados en vivo`, text: $localize`:@@case.alas.row3.text:Integración con el sistema de puntuación de los jueces: heats, rondas y posiciones sin republicar nada a mano.` },
          { title: $localize`:@@case.alas.row4.title:Rankings y perfiles de atletas`, text: $localize`:@@case.alas.row4.text:Cada atleta tiene un perfil con su historial y resultados; rankings por temporada, país y categoría.` },
        ],
      },
      {
        title: $localize`:@@case.alas.group2:Organización`,
        rows: [
          { title: $localize`:@@case.alas.row5.title:Administración por roles`, text: $localize`:@@case.alas.row5.text:Campeonatos, sedes, categorías, noticias y multimedia, gestionados por administradores, editores y staff sin depender de soporte técnico.` },
          { title: $localize`:@@case.alas.row6.title:Control de inscritos e ingresos`, text: $localize`:@@case.alas.row6.text:Inscritos, pagos pendientes y confirmados en una sola vista, con exportaciones e indicadores.` },
          { title: $localize`:@@case.alas.row7.title:Calendario y streaming`, text: $localize`:@@case.alas.row7.text:Calendario interactivo de campeonatos, transmisiones en vivo, galerías y noticias en tres idiomas.` },
        ],
      },
    ],
    integrations: ['Angular + .NET', $localize`:@@case.alas.int2:Pasarela de pago`, $localize`:@@case.alas.int3:Sistema de puntuación`, 'Streaming'],
    impact: $localize`:@@case.alas.impact:Una sola plataforma para procesos que hoy van por separado. Objetivos del proyecto: 90 % de inscripciones digitales, resultados publicados un 95 % más rápido y 45 % más tráfico internacional.`,
    // Testimonio pendiente: llega en unos días.
    testimonial: null,
    services: [
      { path: servicePath('apps-y-experiencias-web'), label: $localize`:@@home.services.2.title:Apps y experiencias web` },
      { path: servicePath('software-a-medida'), label: $localize`:@@home.services.1.title:Software a medida` },
    ],
    next: { path: casePath('euroamerican-assistance'), name: 'Euroamerican Assistance' },
  },
];
