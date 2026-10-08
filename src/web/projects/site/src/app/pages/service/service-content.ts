/** Contenido de cada página de servicio. Una plantilla (ServicePageComponent) y un bloque de datos por servicio. */
export interface ServiceRow { title: string; text: string; }
export interface ServiceContent {
  slug: string;
  index: string;
  title: string;
  lead: string;
  metaDescription: string;
  /** Imagen del hero y qué parte mostrar (background-position). */
  image: string;
  imagePosition: string;
  problemLabel: string;
  problem: string;
  rows: ServiceRow[];
  deliverables: string[];
  technologies: string[];
  relatedCase: { path: string; name: string; scope: string; quote: string } | null;
  ctaTitle: string;
}

export const SERVICES: ServiceContent[] = [
  {
    slug: 'software-a-medida',
    index: '01',
    title: $localize`:@@service.software.title:Software a medida`,
    lead: $localize`:@@service.software.lead:Sistemas hechos para cómo trabaja tu empresa: ventas, comisiones, operaciones e indicadores en una sola plataforma que crece contigo.`,
    metaDescription: $localize`:@@service.software.meta:Desarrollo de software a medida para empresas: sistemas de ventas, comisiones, gestión de talleres y business intelligence. Desde 2007.`,
    image: 'assets/hero-dashboard.webp',
    imagePosition: '72% 45%',
    problemLabel: $localize`:@@service.problem.label:EL PROBLEMA`,
    problem: $localize`:@@service.software.problem:Las hojas de cálculo y los sistemas genéricos llegan hasta un punto. Después, cada proceso nuevo es un parche, la información vive en lugares distintos y nadie confía del todo en los números.`,
    rows: [
      { title: $localize`:@@service.software.row1.title:Sistemas de ventas y comisiones`, text: $localize`:@@service.software.row1.text:Productos, tarifas, agentes y cálculo automático de comisiones e incentivos, sin planillas paralelas.` },
      { title: $localize`:@@service.software.row2.title:Gestión de operaciones`, text: $localize`:@@service.software.row2.text:Órdenes de trabajo, presupuestos, garantías y flujos de aprobación adaptados a tu proceso real.` },
      { title: $localize`:@@service.software.row3.title:Business intelligence`, text: $localize`:@@service.software.row3.text:Tableros e informes ejecutivos con datos al día para decidir con números, no con intuición.` },
      { title: $localize`:@@service.software.row4.title:Cobranza y finanzas`, text: $localize`:@@service.software.row4.text:Módulos de cobranza, facturación y conciliación conectados al resto de la operación.` },
    ],
    deliverables: [
      $localize`:@@service.software.d1:Análisis del proceso y alcance por etapas`,
      $localize`:@@service.software.d2:Prototipo navegable antes de programar`,
      $localize`:@@service.software.d3:Sistema web en producción con usuarios y permisos`,
      $localize`:@@service.software.d4:Documentación y capacitación del equipo`,
      $localize`:@@service.software.d5:Soporte y evolución continua desde el portal`,
    ],
    technologies: ['.NET', 'Angular', 'SQL Server', $localize`:@@service.tech.sap:Integración con SAP`, $localize`:@@service.tech.sunat:Facturación electrónica SUNAT`],
    relatedCase: {
      path: '/casos/euroamerican-assistance',
      name: 'Euroamerican Assistance',
      scope: $localize`:@@home.cases.1.scope:Desde 2008 · Ventas, comisiones y BI`,
      quote: $localize`:@@service.software.case:Más de 15 años sosteniendo su sistema central de ventas, comisiones y cobranza.`,
    },
    ctaTitle: $localize`:@@service.software.cta:¿Tu operación necesita un sistema propio?`,
  },
  {
    slug: 'apps-y-experiencias-web',
    index: '02',
    title: $localize`:@@service.apps.title:Apps y experiencias web`,
    lead: $localize`:@@service.apps.lead:Sitios, portales y aplicaciones que tus clientes entienden a la primera: rápidos, claros y pensados para vender o atender mejor.`,
    metaDescription: $localize`:@@service.apps.meta:Diseño y desarrollo de sitios web, portales de clientes, tiendas online y aplicaciones web rápidas y fáciles de usar.`,
    image: 'assets/photos/apps-phone.jpg',
    imagePosition: '50% 42%',
    problemLabel: $localize`:@@service.problem.label:EL PROBLEMA`,
    problem: $localize`:@@service.apps.problem:Un sitio lento, difícil de actualizar o que no se ve bien en el móvil espanta a los clientes antes de que lleguen a escribirte. La primera impresión digital ya es la primera impresión.`,
    rows: [
      { title: $localize`:@@service.apps.row1.title:Sitios web corporativos`, text: $localize`:@@service.apps.row1.text:Tu marca bien presentada, en varios idiomas y fácil de actualizar por tu equipo.` },
      { title: $localize`:@@service.apps.row2.title:Portales de clientes`, text: $localize`:@@service.apps.row2.text:Zonas privadas para que tus clientes consulten, compren, paguen o abran solicitudes sin llamarte.` },
      { title: $localize`:@@service.apps.row3.title:Tiendas y reservas online`, text: $localize`:@@service.apps.row3.text:Catálogo, pagos con PayPal o tarjeta y reservas conectadas a tu operación.` },
      { title: $localize`:@@service.apps.row4.title:Aplicaciones web a medida`, text: $localize`:@@service.apps.row4.text:Herramientas internas o para clientes que funcionan en cualquier dispositivo, sin instalar nada.` },
    ],
    deliverables: [
      $localize`:@@service.apps.d1:Diseño a medida, no una plantilla genérica`,
      $localize`:@@service.apps.d2:Versión móvil revisada pantalla por pantalla`,
      $localize`:@@service.apps.d3:Textos e imágenes optimizados para buscadores`,
      $localize`:@@service.apps.d4:Panel para actualizar contenidos sin programar`,
      $localize`:@@service.apps.d5:Hosting, dominio y certificado SSL incluidos si los necesitas`,
    ],
    technologies: ['Angular', 'WordPress', 'PayPal', $localize`:@@service.tech.multilang:Multi-idioma (ES · EN · IT)`],
    relatedCase: null,
    ctaTitle: $localize`:@@service.apps.cta:¿Tu web está a la altura de tu empresa?`,
  },
  {
    slug: 'integracion-y-automatizacion',
    index: '03',
    title: $localize`:@@service.integration.title:Integración y automatización`,
    lead: $localize`:@@service.integration.lead:Conectamos tus sistemas para que los datos viajen solos: ERP, facturación electrónica, inventario y servicios externos hablando entre sí.`,
    metaDescription: $localize`:@@service.integration.meta:Integración con SAP, facturación electrónica SUNAT, inventarios y APIs. Automatizamos procesos para eliminar la doble digitación.`,
    image: 'assets/photos/integration-servers.jpg',
    imagePosition: '50% 40%',
    problemLabel: $localize`:@@service.problem.label:EL PROBLEMA`,
    problem: $localize`:@@service.integration.problem:Cuando los sistemas no se hablan, alguien copia datos de uno a otro a mano. Eso cuesta horas, genera errores y hace que nadie sepa cuál es el número correcto.`,
    rows: [
      { title: $localize`:@@service.integration.row1.title:Integración con SAP`, text: $localize`:@@service.integration.row1.text:Consulta de stock en tiempo real, reservas en almacén y sincronización de repuestos y garantías.` },
      { title: $localize`:@@service.integration.row2.title:Facturación electrónica`, text: $localize`:@@service.integration.row2.text:Emisión y validación de comprobantes con SUNAT directamente desde tu sistema.` },
      { title: $localize`:@@service.integration.row3.title:Pagos y suscripciones`, text: $localize`:@@service.integration.row3.text:Cobros únicos y recurrentes con PayPal, conciliados automáticamente con tu facturación.` },
      { title: $localize`:@@service.integration.row4.title:Automatización de tareas`, text: $localize`:@@service.integration.row4.text:Procesos programados, alertas y reportes que se generan y envían solos.` },
    ],
    deliverables: [
      $localize`:@@service.integration.d1:Mapa de los sistemas y del flujo de datos`,
      $localize`:@@service.integration.d2:Conectores probados con datos reales`,
      $localize`:@@service.integration.d3:Registro de cada sincronización y alertas si algo falla`,
      $localize`:@@service.integration.d4:Reintentos automáticos ante caídas de servicios externos`,
      $localize`:@@service.integration.d5:Documentación técnica para tu equipo`,
    ],
    technologies: [$localize`:@@service.tech.sap:Integración con SAP`, $localize`:@@service.tech.sunat:Facturación electrónica SUNAT`, 'REST APIs', 'PayPal', 'GitHub', '.NET'],
    relatedCase: {
      path: '/casos/grupo-crosland',
      name: 'Grupo Crosland',
      scope: $localize`:@@home.cases.2.scope:DMS · SAP · Garantías`,
      quote: $localize`:@@service.integration.case:Talleres Kawasaki y una red de más de 300 talleres Bajaj sincronizados con SAP en tiempo real.`,
    },
    ctaTitle: $localize`:@@service.integration.cta:¿Cuántas horas pierde tu equipo copiando datos?`,
  },
  {
    slug: 'hosting-dominios-y-soporte',
    index: '04',
    title: $localize`:@@service.hosting.title:Hosting, dominios y soporte`,
    lead: $localize`:@@service.hosting.lead:La operación técnica que mantiene tus sistemas disponibles: servidores, dominios, certificados, copias de seguridad y un equipo que responde.`,
    metaDescription: $localize`:@@service.hosting.meta:Hosting administrado, registro y renovación de dominios, certificados SSL, backups y soporte técnico con portal de tickets.`,
    image: 'assets/photos/hosting-servers.jpg',
    imagePosition: '72% 50%',
    problemLabel: $localize`:@@service.problem.label:EL PROBLEMA`,
    problem: $localize`:@@service.hosting.problem:Un dominio que vence sin aviso, un certificado caducado o un servidor caído un viernes por la noche. Lo técnico solo se nota cuando falla, y entonces cuesta caro.`,
    rows: [
      { title: $localize`:@@service.hosting.row1.title:Hosting administrado`, text: $localize`:@@service.hosting.row1.text:Servidores configurados, actualizados y vigilados para tus sitios y sistemas.` },
      { title: $localize`:@@service.hosting.row2.title:Dominios y certificados SSL`, text: $localize`:@@service.hosting.row2.text:Registro y renovación con avisos a 30, 7 y 1 día antes del vencimiento.` },
      { title: $localize`:@@service.hosting.row3.title:Copias de seguridad`, text: $localize`:@@service.hosting.row3.text:Backups programados y restauración probada, no solo prometida.` },
      { title: $localize`:@@service.hosting.row4.title:Soporte con tickets`, text: $localize`:@@service.hosting.row4.text:Reportas desde el portal de asistencia y sigues cada caso hasta que queda resuelto.` },
    ],
    deliverables: [
      $localize`:@@service.hosting.d1:Un solo proveedor para todo lo técnico`,
      $localize`:@@service.hosting.d2:Renovaciones y pagos online desde el portal`,
      $localize`:@@service.hosting.d3:Historial de tickets y respuestas en un lugar`,
      $localize`:@@service.hosting.d4:Avisos antes de cada vencimiento`,
      $localize`:@@service.hosting.d5:Facturación en soles, dólares o euros`,
    ],
    technologies: ['Linux', 'Windows Server', 'SQL Server', 'SSL', $localize`:@@service.tech.portal:Portal de asistencia Rtres`],
    relatedCase: null,
    ctaTitle: $localize`:@@service.hosting.cta:¿Sabes cuándo vence tu dominio?`,
  },
];

/** Pasos comunes a todos los servicios. */
export const PROCESS_STEPS: ServiceRow[] = [
  { title: $localize`:@@service.process.1.title:Entender`, text: $localize`:@@service.process.1.text:Conversamos con quienes usan el proceso todos los días.` },
  { title: $localize`:@@service.process.2.title:Diseñar`, text: $localize`:@@service.process.2.text:Definimos alcance, prioridades y un prototipo que puedas probar.` },
  { title: $localize`:@@service.process.3.title:Construir`, text: $localize`:@@service.process.3.text:Entregas por etapas, en producción desde las primeras semanas.` },
  { title: $localize`:@@service.process.4.title:Acompañar`, text: $localize`:@@service.process.4.text:Soporte, mejoras y tickets desde el portal de asistencia.` },
];
