# Auditoría SEO y de conversión — Sitio público Rtres

**Fecha:** 1 de octubre de 2026
**Alcance:** sitio público `src/web/projects/site` (Angular SSR, ES/EN/IT), comparado con el catálogo del portal, los ingresos registrados y los documentos comerciales (`Documentacion/`).
**Marca y dominio oficiales (decisión tomada):** Rtres Web Solutions · `rtres.net`.

---

## Resumen ejecutivo

El sitio tiene una buena base técnica: renderizado en servidor (SSR), tres idiomas, un solo `<h1>` y FAQ con respuestas reales. Pero hoy **no puede posicionar por ningún servicio concreto** ni convertir bien a quien llega:

| # | Aspecto | Estado | Problema principal |
|---|---|---|---|
| 1 | Qué hacemos, para quién, contacto | 🟠 Parcial | El mensaje es genérico ("soluciones web"), no dice para quién ni dónde. No hay formulario: "Contacto" es un pie de página con un teléfono de ejemplo. |
| 2 | Una página por servicio | 🔴 No existe | Todo vive en una sola URL con anclas (`#features`, `#pricing`). Google y los asistentes de IA no tienen una página que responda a "desarrollo de software a medida en Lima" o "API validación RUC". |
| 3 | Reseñas, logos, casos de éxito | 🔴 Riesgo | Los logos mostrados (Assist Card, Ransa, Claro, Rimac) **no son clientes reales**. El "5.0 ★★★★★" no tiene fuente. Los casos de éxito reales (Crosland, Euroamerican…) no aparecen. |
| 4 | CTA claro en cada página | 🟠 Roto | Hay CTAs, pero todos llevan a `#contact` (un pie sin formulario). Los botones "Empezar" de precios no tienen enlace. "Ver todos los proyectos" lleva a contacto. |

**Prioridad absoluta (esta semana):** quitar los logos falsos y el rating sin fuente, corregir el teléfono y el enlace de login, y crear un formulario de contacto real. Son problemas de credibilidad, no solo de SEO.

---

## 1. Qué hace, a quién va dirigido y cómo contactar

### Lo que hay hoy

- **H1:** "Soluciones web que convierten visitas en clientes" (`hero.component.ts`). Habla del beneficio, pero no del servicio ni de la ubicación. Cualquier agencia del mundo podría usar esa frase.
- **Subtítulo:** "Diseñamos y desarrollamos sitios, tiendas y sistemas a medida…". Está mejor, pero no dice para quién.
- **Público objetivo:** según `PRODUCT.md`, son pymes y responsables de marketing en Perú e Italia. El sitio no lo dice en ningún lugar. Tampoco menciona Lima, Perú, Italia ni España.
- **Diferenciadores reales que no aparecen en la web:**
  - Socio tecnológico de clientes **desde 2008**: Euroamerican Assistance y Alliance siguen hoy.
  - Integraciones con **SAP** y **facturación electrónica SUNAT**.
  - **Staff augmentation .NET / SAP** (Carta Comercial).
  - **APIs de validación de DNI, RUC y cuentas bancarias**, un producto que ya se vende cada mes.
  - Operación en **Lima + Italia/España**: atención en tres idiomas y en dos husos horarios.
- **Contacto:**
  - No hay **formulario**. Todos los CTA apuntan a `#contact`, que es el `<footer>` (`footer.component.ts`).
  - El pie muestra **`+51 999 999 999`**, un número de ejemplo. La barra superior muestra `+39 328 191 5399`: son dos teléfonos distintos en la misma página.
  - No hay **WhatsApp**, cuando es el canal principal en el folleto "Planes web" y en Perú.
  - No hay dirección física ni horario. Sin ellos, no hay datos NAP coherentes con Google Business Profile.
  - "Iniciar sesión" apunta a **`http://localhost:4201/login`** (`top-bar.component.ts`). En producción es un enlace roto.

### Recomendaciones

1. **Reescribir la primera pantalla** para que responda a las tres preguntas en 5 segundos. Propuesta:
   - **H1:** "Desarrollo web y software a medida para empresas en Perú e Italia"
   - **Subtítulo:** "Desde 2008 construimos y mantenemos sitios, tiendas online y sistemas de gestión integrados con SAP y SUNAT para pymes y corporaciones."
   - **CTA primario:** "Pedir presupuesto". **CTA secundario:** "Escríbenos por WhatsApp".
2. **Crear `/contacto`** con un formulario corto: nombre, email, teléfono, servicio (desplegable), mensaje y presupuesto orientativo opcional. Debe enviar el lead al API, con notificación por email, para no depender de un `mailto:`.
3. **Botón flotante de WhatsApp** en móvil (`https://wa.me/393281915399` o el número peruano), con un mensaje predefinido según la página: "Hola, me interesa una tienda online…".
4. **Unificar NAP** (nombre, dirección, teléfono) exactamente igual en la web, Google Business Profile, LinkedIn y los directorios.
5. **Añadir "Para quién trabajamos"** con segmentos concretos: pymes que necesitan su primera web, empresas con operación crítica (aseguradoras, talleres, distribuidoras) y equipos de TI que necesitan desarrolladores .NET/SAP.

---

## 2. Una página por servicio

### Por qué importa

- Google posiciona **URLs**, no secciones. Una ancla `#pricing` no puede posicionar por "tienda online Perú precio".
- Los asistentes de IA (ChatGPT, Gemini, Perplexity, AI Overviews) citan páginas que **responden a una pregunta concreta**, con datos verificables: precio, plazo, qué incluye, para quién es.
- Hoy el sitio tiene **dos rutas**: `''` y `':lang'` (`site.routes.ts`), y ambas cargan el mismo `HomeComponent`. Además:
  - El `<title>` es fijo ("Rtres Web Solutions") y no hay `<meta name="description">` (`src/index.html`).
  - No hay `hreflang`, `canonical`, `sitemap.xml`, `robots.txt` ni datos estructurados (JSON-LD).

### Mapa de servicios (sacado de lo que realmente vendéis)

Los servicios salen del catálogo del portal y de las facturas de 2026, no de una lista genérica.

| Página (ES) | Servicio | Evidencia en el portal / documentos | Intención de búsqueda objetivo |
|---|---|---|---|
| `/es/diseno-web` | Sitio vitrina / blog | Plan $390, folleto "Planes web" | "diseño de páginas web Lima", "crear página web para empresa precio" |
| `/es/tienda-online` | E-commerce | Plan $490 | "tienda online Perú", "crear e-commerce con pasarela de pago" |
| `/es/software-a-medida` | Sistemas de gestión a medida | "Desarrollo personalizado" (11 facturas en 2026): Bajaj, ALAS, Euroamerican, Pyramis | "desarrollo de software a medida Lima", "empresa de desarrollo de sistemas" |
| `/es/integracion-sap` | Integraciones SAP | DMS Kawasaki/Bajaj con stock y garantías en SAP | "integración SAP con sistema web", "desarrollador SAP .NET Perú" |
| `/es/facturacion-electronica-sunat` | Interfaz SUNAT | Building Connections | "integración facturación electrónica SUNAT API" |
| `/es/api-validacion-dni-ruc` | APIs de validación | Pyramis: DNI, RUC y cuentas bancarias (plan mensual) | "API consulta RUC", "API validar DNI", "validar cuenta bancaria API Perú" |
| `/es/hosting` | Hosting Cloud / WordPress / zona EUR | Catálogo: Cloud Medium, Pro, Empresa, WordPress Medium/Pro, Zona EUR | "hosting WordPress Perú", "hosting para empresas" |
| `/es/dominios-y-ssl` | Dominios .pe/.com/.it y SSL estándar/wildcard | Catálogo | "registrar dominio .pe", "certificado SSL wildcard precio" |
| `/es/mantenimiento-web` | Soporte mensual (Uni / Multi Empresa) | 18 facturas de soporte en 2026 | "mantenimiento de páginas web mensual", "soporte WordPress" |
| `/es/staff-augmentation-net-sap` | Extensión de equipo .NET / SAP | Carta Comercial | "outsourcing desarrolladores .NET", "staff augmentation Perú" |
| `/es/seo` | SEO & SEM | Aparece en la web, sin evidencia de ventas | Crear solo si es un servicio activo; si no, quitarlo de la home |

Más páginas de apoyo: `/es/casos-de-exito` (con una página por caso, ver punto 3), `/es/precios`, `/es/contacto` y `/es/nosotros`.

**Versiones EN / IT:** usar el mismo mapa con slugs traducidos (`/it/sviluppo-software-su-misura`, `/en/custom-software-development`). Para Italia, dar prioridad a hosting zona EUR, dominios `.it` y desarrollo a medida: ya tenéis un cliente allí (ristorantemadeinperu.it).

### Plantilla de cada página de servicio

1. **H1 con el servicio y la ubicación:** "Desarrollo de software a medida en Lima".
2. **Párrafo de respuesta directa** (40–60 palabras), el que citaría una IA: qué es, para quién, plazo típico y desde cuánto cuesta.
3. **Qué incluye**: lista concreta.
4. **Proceso**: 3–5 pasos con plazos.
5. **Caso de éxito relacionado**: tarjeta con enlace al caso completo.
6. **Precio o "desde"**, cuando aplique. Los precios del folleto ya son públicos.
7. **FAQ específica** del servicio (4–6 preguntas).
8. **CTA principal** (ver punto 4) y formulario corto incrustado.
9. **Enlaces internos** a servicios relacionados: hosting ↔ dominios ↔ mantenimiento.

### Cambios técnicos necesarios

- **Rutas:** `/:lang/:servicio` con su componente y su contenido. Conviene que el contenido sea editable desde WordPress, que ya alimenta proyectos y reseñas vía `PublicContentController` (`GET /api/public/{locale}/pages/{slug}` ya existe).
- **Título y meta description por ruta** con los servicios `Title` y `Meta` de Angular, en SSR.
- **`<link rel="canonical">`** y **`hreflang`** (es, en, it y `x-default`) en cada página.
- **`<html lang>`** correcto por idioma. Hay que verificarlo en la build localizada.
- **`sitemap.xml`** (con alternativas por idioma) y **`robots.txt`**.
- **JSON-LD:**
  - `Organization` / `ProfessionalService` en todas las páginas: nombre, logo, `sameAs` (GBP, LinkedIn), teléfono y `areaServed` (PE, IT, ES).
  - `Service` en cada página de servicio.
  - `BreadcrumbList`.
  - `FAQPage`: Google ya casi no muestra el resultado enriquecido de FAQ, pero sigue ayudando a los asistentes de IA a extraer respuestas.
- **`/llms.txt`**: un resumen en texto plano de quiénes sois, qué servicios ofrecéis (con URL) y cómo contactar, para los rastreadores de IA.
- **Coherencia de la entidad:** el mismo nombre ("Rtres Web Solutions"), la misma descripción y los mismos datos en la web, GBP, LinkedIn y los directorios. Es la base para que Google y las IA reconozcan la marca como una sola entidad.
- **Migración de dominio:** redirigir `r3solucionesweb.com` a `rtres.net` con **301, URL a URL**. Actualizar firmas de email y documentos comerciales (Carta presentación, Casos de éxito y Planes web siguen usando `r3solucionesweb.com` y `roberto.ramos@r3solucionesweb.com`).

---

## 3. Prueba social: reseñas, logos y casos de éxito

### Problemas actuales (corregir ya)

- **Logos falsos.** `hero.component.ts` y `reviews.component.ts` muestran **Assist Card, Cabalgatas Andinas, Ransa, Claro y Rimac** bajo "Marcas que confían en nosotros". Confirmaste que no son clientes. Es un riesgo reputacional y legal (uso de marcas ajenas), y si un prospecto lo comprueba, se pierde toda la confianza. **Hay que reemplazarlos por clientes reales.**
- **Rating sin fuente.** "★★★★★ 5.0 · 18 años" en la tarjeta del hero no enlaza a ninguna fuente. Debe mostrar el rating real de Google Business Profile con un enlace a la ficha.
- **Las reseñas vienen de WordPress**, no de Google, y sin autor no muestran estrellas. Un visitante no puede verificarlas.
- **Foto de ejemplo.** Si WordPress no responde, el hero usa una foto de `picsum.photos` con el alt "Equipo de Rtres trabajando". Para una sección que tiene que generar confianza, es mejor una foto real del equipo.
- **Proyectos sin detalle.** Las tarjetas tienen `href="#"` y no llevan a ningún caso.

### Google Business Profile (ya tenéis ficha con reseñas)

1. **Mostrar el rating y el número de reseñas reales** cerca del hero, con un enlace "Ver reseñas en Google".
2. **Sección de reseñas** con 3–6 reseñas reales de GBP (autor, fecha, texto) y un enlace a la ficha. Opciones:
   - Copia manual periódica: es lo más simple y no depende de terceros.
   - Places API: muestra un máximo de 5 reseñas y exige atribución a Google.
3. **Datos estructurados:** **no marcar** las reseñas propias con `AggregateRating` en `Organization`/`LocalBusiness`. Google no muestra estrellas en "reseñas sobre uno mismo" desde 2019. El valor de las reseñas está en la ficha de GBP y en la confianza del visitante.
4. **Plan para conseguir más reseñas:** enviar un enlace directo de reseña de GBP:
   - a los clientes con soporte mensual activo (Euroamerican, PASA…);
   - al cerrar un ticket en el portal, con un mensaje opcional en la notificación de ticket resuelto.
5. **Optimizar la ficha de GBP:**
   - Categoría principal: "Diseñador de sitios web" o "Empresa de software".
   - Servicios: los de la tabla del punto 2.
   - Publicaciones mensuales, fotos de proyectos.
   - Enlace a `rtres.net` con UTM.
   - Valorar si conviene una segunda ficha en Italia, si hay dirección real allí.

### Logos de clientes (con permiso confirmado)

Sustituir el marquee por logos reales, en escala de grises y con `alt` descriptivo:

- **Confirmados:** Grupo Crosland (Kawasaki · Bajaj), Euroamerican Assistance, Building Connections y Alliance.
- **"Otros clientes": tienes que decirme cuáles exactamente.** Candidatos según el portal: Pyramis, ALAS, PASA (pasasurf.org), Triz / Soldimix, TSA / SOS 24, Dertec, Atiq Consultoría, Jonny Motors, Joshua's Tailor, Ristorante Made in Perú, Federación Peruana de Tabla y Asociación Latinoamericana de Surf.

### Casos de éxito (una página por caso: `/es/casos-de-exito/{cliente}`)

Estructura de cada caso: **sector → reto → solución → resultado (con cifras) → tecnologías → servicio relacionado (enlace) → CTA**. Borradores, basados en `Casos de exito Rtres.docx` y en lo facturado en el portal:

| # | Caso | Reto | Solución | Servicio al que enlaza |
|---|---|---|---|---|
| 1 | **Kawasaki – Grupo Crosland** | Controlar talleres y venta de repuestos sincronizados con el inventario corporativo | DMS: órdenes de trabajo, presupuestos, stock y reservas en tiempo real en SAP, interfaz de facturación. Hosting Cloud Empresa + SSL wildcard | Software a medida · Integración SAP · Hosting |
| 2 | **Bajaj – Grupo Crosland** | Red de talleres con reclamos de garantía a fábrica | Gestión masiva de reparaciones, módulo de garantías, sincronización de repuestos en SAP. Evolución continua con bolsa de horas | Software a medida · Integración SAP |
| 3 | **Euroamerican Assistance** | Operación 24/7 crítica: ventas, comisiones, cobranza | Ecosistema central desde 2008: ventas, BI, cobranza. Nueva web Innova Doctors (2026). Soporte mensual | Software a medida · Mantenimiento |
| 4 | **Alliance** | Ventas descentralizadas en varios continentes | Sistema central de ventas mantenido desde 2008 | Software a medida |
| 5 | **Building Connections** | Unificar imagen y automatizar facturación | Web corporativa, sistema de cotizaciones, interfaz SUNAT | Diseño web · Facturación SUNAT |
| 6 | **Pyramis** *(pendiente de permiso)* | Validar la identidad y las cuentas de sus usuarios | APIs de validación de DNI, RUC y cuentas bancarias en plan mensual | API validación DNI/RUC |
| 7 | **ALAS** *(pendiente de permiso)* | Nueva web y gestión de contenidos | Web + CMS a medida 2026 + hosting | Diseño web · Hosting |
| 8 | **PASA – pasasurf.org** *(pendiente de permiso)* | Web WordPress siempre al día | Hosting WordPress + soporte, respaldo y optimización mensual | Hosting · Mantenimiento |

Cada caso necesita **al menos una cifra de resultado**. Hoy los textos dicen "estabilidad garantizada" u "optimización del flujo", lo cual no se puede medir ni citar. Ver las preguntas al final.

---

## 4. Un CTA claro en cada página

### Problemas actuales

| Ubicación | CTA | Problema |
|---|---|---|
| Cabecera | "Solicitar cotización" → `#contact` | Lleva a un pie sin formulario |
| Hero | "Solicitar cotización" / "Ver planes" | El primario tiene el mismo problema |
| Precios | "Empezar" / "Hablemos" | **El `<a>` no tiene `href`**: el botón no hace nada (`pricing.component.ts`) |
| Proyectos | "Ver todos los proyectos" → `#contact` | El texto promete proyectos y lleva a contacto |
| Banda oscura | "Empezar mi proyecto" → `#contact` | Igual que la cabecera |
| Barra superior | "Iniciar sesión" → `localhost:4201` | Roto en producción |
| Features | "Preview del portal →" → `portal.rtres.net` | Saca al prospecto a un login: pierde el foco de venta |

### CTA recomendado por tipo de página

Regla: **un CTA principal por página**, visible arriba, repetido al final y fijo en móvil. WhatsApp como alternativa secundaria.

| Página | CTA principal | Secundario |
|---|---|---|
| Home | **Pedir presupuesto** | Escríbenos por WhatsApp |
| Diseño web / Tienda online | **Quiero mi web desde $390** / **Quiero mi tienda desde $490** (formulario con el plan preseleccionado) | Ver ejemplos |
| Software a medida / SAP / SUNAT | **Agendar una llamada de 30 min** (diagnóstico gratuito) | Ver casos de éxito |
| API validación DNI/RUC | **Solicitar acceso de prueba** | Ver documentación |
| Hosting / Dominios / SSL | **Contratar** (con precio "desde") | Hablar con un asesor |
| Mantenimiento web | **Quiero que me contacten** | Ver qué incluye |
| Staff augmentation | **Solicitar perfiles .NET / SAP** | Descargar la presentación |
| Caso de éxito | **Quiero un proyecto similar** | Ver el servicio |
| Contacto | **Enviar** (formulario) | WhatsApp · teléfono · email |

Detalles de implementación:

- Cada CTA lleva al formulario **con el servicio ya seleccionado** (`/es/contacto?servicio=tienda-online`).
- Medir conversiones: `generate_lead` en GA4 o similar, más clics a WhatsApp y teléfono.
- Después de enviar, mostrar una página de gracias (`/es/contacto/gracias`) con el tiempo de respuesta comprometido ("te respondemos en menos de 24 h hábiles").

---

## Otros hallazgos (técnicos y de calidad)

- **Contenido de WordPress con 5 s de espera** (`public-api.service.ts`). Si en SSR WordPress tarda o falla, el HTML que ve Google sale **sin proyectos ni reseñas**. Conviene cachear ese contenido en el API.
- **FAQ:** el contenido es bueno, pero conviene moverlo a cada página de servicio y añadir preguntas de precio y plazo por servicio.
- **Botón de menú móvil `☰`** sin `aria-label`. Accesibilidad básica.
- **"18+ años · 300+ proyectos"** se repite en la web y en el folleto. Debe cuadrar con "Fundada en 2007" de la Carta presentación (2007 → 2026 = 19 años). Hay que mantenerlo coherente.
- **Precios con "IGV no incluido"** en USD: está bien para Perú, pero en las versiones EN/IT conviene aclarar el IVA y la moneda para clientes europeos.

---

## Hoja de ruta propuesta

| Fase | Tareas | Impacto |
|---|---|---|
| **0 · Urgente** (1–2 días) | Quitar los logos falsos y el rating sin fuente. Corregir el teléfono `+51 999…` y el enlace `localhost`. Dar `href` a los botones de precios. Cambiar la foto de ejemplo | Credibilidad |
| **1 · Base** (1 semana) | `/contacto` con formulario y WhatsApp. Title y meta description por ruta. Canonical, hreflang, sitemap, robots. JSON-LD de organización. Rating real de GBP | Conversión e indexación |
| **2 · Servicios** (2–3 semanas) | 6 páginas prioritarias: software a medida, integración SAP, API DNI/RUC, diseño web, tienda online, mantenimiento. Después hosting, dominios/SSL, SUNAT y staff augmentation | Posicionamiento por servicio |
| **3 · Prueba social** (en paralelo) | Logos reales, 5 casos de éxito con cifras, plan de reseñas en GBP, `llms.txt` | Confianza y citas en IA |
| **4 · Idiomas** | Versiones EN/IT de las páginas de servicio y de casos | Mercado europeo |
| **5 · Medición** | GA4 / Search Console. Revisar consultas e impresiones por página cada mes | Mejora continua |

---

## Preguntas pendientes (para completar el punto 3)

**Google Business Profile**
1. ¿Cuál es la URL de la ficha? ¿Qué rating y cuántas reseñas tiene hoy?
https://www.google.com/search?sca_esv=3cc28e5c82341c61&rlz=1C5CHFA_enIT1033__1034&sxsrf=APpeQnsKj4F-wrrCnZAnYc1qXAceGr24mg:1790884858579&q=Rtres+Web+Solutions+-+Dise%C3%B1o+de+Sitios+Web&si=APenkKm7iecQ4G6P-TsbSMFKIQtv3EFIqRAFw-i8uEbk55Z-_2oCnFhf5u6N9VL-64kUmOMXFkTY2WwHLDjpDbblBaXXg1sAPeJW9zCA5UvM983e3rFUfg8%3D&uds=AJ5uw1_p2fu4EkZbzvA9FH-tMwgO130jdj1VUZ92CS2OrqRtJOs1Jk5v-bX9xUhhoPkhfFejqRFU2R1iuLcCHllO9VZR8o-NwymYN85Xq3rXp_ac3Wjg0W_6Sb5fDcq01yPkIlvEEb5VplGzkz_MRupyN_feVOSxlQ&sa=X&ved=2ahUKEwiT0tD-zZmXAxU1xgIHHcdKMhAQ3PALegQIGBAE&biw=1440&bih=723&dpr=2#sv=CAESzQEKuQEStgEKd0FKaVQ0dEw3VVVPY1ViMXJ6QTNNWnpVaElLN2ZiakFRX0piQVBDalpRNjBIc1VsZjAwY29DTzdrWDc0UExJSWJYTXhnWE43VkVHRjl0cElJUHVhS0JZTDQ3RkhRV1lSUUlrY3QzRXM2TXVoX3lRcG96dEQ0RlJvEhdFYnktYXRfTkE0YU0tZDhQak1pVDBBZxoiQURzcjlmUkJUdEpkd0lkMTNLWDB2YnlZM1haMW83X25aZxIEODA1MRoBMyoAMAA4AUAAGAAgiuPh2AtKAhAB:~:text=verifican%20las%20opiniones-,Google,-5/5
2. ¿La ficha está en Lima, en Italia o en ambos? ¿Con qué dirección pública?
En Lima
3. ¿Hay reseñas destacadas que queráis mostrar sí o sí?
Si todas

**Logos**
4. Dentro de "Otros clientes", ¿cuáles tienen permiso exactamente? Ver la lista de candidatos en el punto 3.
Pon algunos luego lo vamos ampliando
5. ¿Tenéis los logos en buena calidad (SVG o PNG con fondo transparente), o hay que pedírselos a cada cliente?
Si los tengo, por el momento usa place holders

**Casos de éxito**
6. ¿Podéis dar cifras por caso? Por ejemplo:
   - número de talleres o usuarios del DMS (Kawasaki/Bajaj);
   - transacciones o ventas al mes que procesa el sistema de Euroamerican;
   - tiempo ahorrado en facturación (Building Connections);
   - validaciones al mes (Pyramis);
   - uptime de los hostings.
7. ¿Algún cliente daría una cita textual con nombre y cargo para su caso?
8. ¿Hay capturas de pantalla o fotos de los sistemas que se puedan publicar, o hay que anonimizarlas?
9. ¿Pyramis, ALAS y PASA autorizan un caso publicado?

**Contacto y negocio**
10. ¿Qué teléfono es el principal para la web: el peruano (+51 997 893 258) o el italiano (+39 328 191 5399)? ¿WhatsApp en cuál?
11. ¿Seguís ofreciendo SEO/SEM como servicio? Si no, conviene quitarlo de la home.
12. ¿Staff augmentation .NET/SAP debe aparecer en la web pública o solo se ofrece por venta directa?
