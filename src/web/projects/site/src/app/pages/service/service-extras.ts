/**
 * "Para quién es" y preguntas frecuentes de cada servicio (PLAN-seo.md, T5). Las preguntas también salen como
 * schema FAQPage. Fuentes: Documentacion/Casos de exito Rtres.docx, Carta presentacion.docx, Carta Comercial.docx y los
 * precios "desde" del catálogo del portal: si cambian los precios del catálogo, actualizar estas respuestas.
 */
export interface ServiceFaq { q: string; a: string; }
export interface ServiceExtras { audience: string[]; faqs: ServiceFaq[]; }

export const SERVICE_EXTRAS: Record<string, ServiceExtras> = {
  'software-a-medida': {
    audience: [
      $localize`:@@service.software.aud1:Empresas cuya operación ya no cabe en hojas de cálculo ni en un sistema genérico: ventas, comisiones, cobranzas u órdenes de trabajo con reglas propias.`,
      $localize`:@@service.software.aud2:Operaciones críticas que no pueden detenerse, como asistencia al viajero 24/7 o redes de talleres, y necesitan un sistema estable durante años.`,
      $localize`:@@service.software.aud3:Equipos de TI que necesitan sumar desarrolladores .NET o especialistas en SAP sin contratar planilla: también trabajamos como extensión de tu equipo (staff augmentation).`,
    ],
    faqs: [
      { q: $localize`:@@service.software.faq1.q:¿Cuánto cuesta desarrollar un software a medida?`, a: $localize`:@@service.software.faq1.a:Depende del alcance. Después de una primera conversación definimos los módulos y estimamos las horas: el precio es esa estimación por nuestra tarifa, y lo dividimos en fases para que empieces a usar el sistema antes de terminarlo todo. Siempre recibes la propuesta por escrito antes de empezar.` },
      { q: $localize`:@@service.software.faq2.q:¿Cuánto tiempo toma?`, a: $localize`:@@service.software.faq2.a:Lo que más influye es la cantidad de procesos e integraciones. Trabajamos por entregas: primero un prototipo navegable para validar el flujo y luego módulos que pasan a producción uno por uno. En la propuesta indicamos las fases y sus fechas estimadas.` },
      { q: $localize`:@@service.software.faq3.q:¿El sistema puede integrarse con SAP o con la facturación electrónica de SUNAT?`, a: $localize`:@@service.software.faq3.a:Sí. Es una de nuestras especialidades: hemos integrado sistemas de talleres con SAP para consultar y reservar stock en tiempo real, sincronizar repuestos y validar garantías, y sistemas de gestión con la emisión de comprobantes electrónicos ante SUNAT.` },
      { q: $localize`:@@service.software.faq4.q:¿Qué pasa después de la entrega?`, a: $localize`:@@service.software.faq4.a:Seguimos contigo. El sistema queda en producción con documentación y capacitación, y el soporte y las mejoras se piden desde nuestro portal de clientes, con tickets y seguimiento. Clientes como Euroamerican Assistance y Alliance trabajan con nosotros desde 2008.` },
      { q: $localize`:@@service.software.faq5.q:¿El código y los datos son de mi empresa?`, a: $localize`:@@service.software.faq5.a:Sí. El sistema se construye para tu empresa y tus datos son tuyos. Las condiciones de propiedad, alojamiento y soporte quedan escritas en la propuesta antes de empezar.` },
    ],
  },
  'apps-y-experiencias-web': {
    audience: [
      $localize`:@@service.apps.aud1:Empresas que necesitan una web profesional que explique bien lo que hacen y convierta visitas en contactos, en uno o varios idiomas.`,
      $localize`:@@service.apps.aud2:Negocios que quieren vender en línea con una tienda propia, con su catálogo, pagos y pedidos.`,
      $localize`:@@service.apps.aud3:Empresas que atienden a sus clientes con procesos repetitivos (pedidos, renovaciones, consultas) y quieren un portal de autoservicio.`,
    ],
    faqs: [
      { q: $localize`:@@service.apps.faq1.q:¿Cuánto cuesta una página web?`, a: $localize`:@@service.apps.faq1.a:Tenemos planes de sitio web desde US$ 400 y tiendas online desde US$ 600, ambos en pago único, más el hosting y el dominio. Los portales y aplicaciones a medida se cotizan según su alcance.` },
      { q: $localize`:@@service.apps.faq2.q:¿Puedo actualizar el contenido yo mismo?`, a: $localize`:@@service.apps.faq2.a:Sí. Según el proyecto usamos un gestor de contenidos (como WordPress) o un panel propio, para que cambies textos, imágenes y productos sin depender de nosotros. Si prefieres, también lo hacemos por ti desde el portal de soporte.` },
      { q: $localize`:@@service.apps.faq3.q:¿La web aparecerá en Google?`, a: $localize`:@@service.apps.faq3.a:La construimos para eso: páginas rápidas, una por servicio, con títulos y descripciones pensados para búsquedas reales, versiones por idioma bien enlazadas y datos estructurados. Posicionar también requiere contenido y tiempo, y te explicamos qué esperar.` },
      { q: $localize`:@@service.apps.faq4.q:¿Funcionará bien en celulares?`, a: $localize`:@@service.apps.faq4.a:Sí. Diseñamos primero para el celular, donde llega la mayoría de visitas, y probamos cada página en distintos tamaños de pantalla antes de publicarla.` },
      { q: $localize`:@@service.apps.faq5.q:¿Hacen sitios en varios idiomas?`, a: $localize`:@@service.apps.faq5.a:Sí. Trabajamos con clientes en Perú, España e Italia, y construimos sitios en español, inglés e italiano, cada idioma con sus propias direcciones para que Google muestre la versión correcta a cada visitante.` },
    ],
  },
  'integracion-y-automatizacion': {
    audience: [
      $localize`:@@service.integration.aud1:Empresas que usan SAP y necesitan que sus sistemas operativos (talleres, ventas, almacenes) consulten y actualicen la información sin digitarla dos veces.`,
      $localize`:@@service.integration.aud2:Negocios en Perú que deben emitir comprobantes electrónicos ante SUNAT desde su propio sistema de ventas o gestión.`,
      $localize`:@@service.integration.aud3:Equipos que pierden horas en tareas repetitivas: validar RUC, DNI o cuentas bancarias, consolidar reportes o mover datos entre sistemas.`,
    ],
    faqs: [
      { q: $localize`:@@service.integration.faq1.q:¿Con qué versiones de SAP trabajan?`, a: $localize`:@@service.integration.faq1.a:Nos adaptamos a la que ya tiene tu empresa. Antes de proponer, revisamos con tu equipo cómo se expone la información (servicios, interfaces o archivos) y diseñamos la integración sobre eso, sin reingenierías costosas.` },
      { q: $localize`:@@service.integration.faq2.q:¿Qué se puede integrar con SAP?`, a: $localize`:@@service.integration.faq2.a:Por ejemplo: consulta de stock en tiempo real y reserva en almacén, sincronización de repuestos, validación y seguimiento de garantías, y el envío de pedidos o facturas. Lo hemos hecho para el taller Kawasaki y la red de más de 300 talleres Bajaj de Grupo Crosland.` },
      { q: $localize`:@@service.integration.faq3.q:¿Pueden conectar mi sistema con la facturación electrónica de SUNAT?`, a: $localize`:@@service.integration.faq3.a:Sí. Hemos desarrollado interfaces para emitir y validar facturas electrónicas desde el sistema de gestión del cliente, de modo que el comprobante se genera al cerrar la venta, sin volver a digitarlo.` },
      { q: $localize`:@@service.integration.faq4.q:¿Qué son sus APIs de validación?`, a: $localize`:@@service.integration.faq4.a:Son servicios que tu sistema puede consultar para validar datos de RUC y DNI, y de cuentas bancarias, al registrar un cliente o un pago. Se contratan como suscripción mensual desde nuestro portal de clientes; si te interesan, escríbenos y te enviamos los detalles.` },
      { q: $localize`:@@service.integration.faq5.q:¿Qué pasa si SAP o SUNAT cambian algo?`, a: $localize`:@@service.integration.faq5.a:Las integraciones necesitan mantenimiento. Monitoreamos las que construimos y, cuando cambia una norma o una versión, las ajustamos dentro del soporte, que se gestiona desde el portal de clientes.` },
    ],
  },
  'hosting-dominios-y-soporte': {
    audience: [
      $localize`:@@service.hosting.aud1:Empresas que no tienen un equipo de TI propio y quieren que su web, su correo y sus sistemas estén siempre en línea, sin preocuparse por la parte técnica.`,
      $localize`:@@service.hosting.aud2:Negocios con varios dominios, certificados y renovaciones que hoy se gestionan en distintos lugares y a veces vencen sin aviso.`,
      $localize`:@@service.hosting.aud3:Clientes que ya tienen un sistema o una web y necesitan soporte continuo con tiempos y prioridades claros.`,
    ],
    faqs: [
      { q: $localize`:@@service.hosting.faq1.q:¿Cuánto cuesta el hosting?`, a: $localize`:@@service.hosting.faq1.a:Los planes de hosting cloud empiezan en US$ 110 al año, y hay planes para WordPress y para empresas con más tráfico. Los dominios .com desde US$ 25 al año y los .pe desde US$ 40. Puedes ver y contratar los planes desde nuestro portal de clientes.` },
      { q: $localize`:@@service.hosting.faq2.q:¿Me avisan antes de que venza mi dominio o mi hosting?`, a: $localize`:@@service.hosting.faq2.a:Sí. El portal te envía recordatorios por correo 30, 7 y 1 día antes de cada vencimiento, y puedes renovar en línea con PayPal o por transferencia bancaria.` },
      { q: $localize`:@@service.hosting.faq3.q:¿Cómo pido soporte?`, a: $localize`:@@service.hosting.faq3.a:Desde el portal de clientes registras un ticket (un error, una mejora o un requerimiento) y ves su estado hasta que se resuelve. Te avisamos por correo cada vez que hay una respuesta o un cambio.` },
      { q: $localize`:@@service.hosting.faq4.q:¿Incluye copias de seguridad?`, a: $localize`:@@service.hosting.faq4.a:Ofrecemos backups programados de bases de datos y sitios como servicio, para que puedas recuperar tu información si algo falla. Te recomendamos el plan según la importancia de tus datos.` },
      { q: $localize`:@@service.hosting.faq5.q:¿Puedo pagar en soles o por transferencia?`, a: $localize`:@@service.hosting.faq5.a:Sí. Además de PayPal, aceptamos transferencia bancaria a nuestras cuentas en soles, dólares o euros: reportas el pago con el número de operación o la constancia y lo confirmamos.` },
    ],
  },
};
