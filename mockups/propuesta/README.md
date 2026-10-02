# Mockups Rtres: web, servicios y casos

Propuesta navegable en español. Inicio: `index.html`. Son 18 páginas: inicio, directorio de servicios, 10 servicios independientes, listado de casos, 4 casos y contacto. Diseño B2B blanco, negro y verde; jerarquía asimétrica, movimiento discreto y adaptación móvil.

## Decisiones confirmadas

- Mercados: Perú, España, Estados Unidos e Italia.
- Canales: formulario, correo y WhatsApp.
- WhatsApp principal: +39 328 191 5399.
- CTA: «Pedir presupuesto», con contexto del servicio; en casos: «Quiero un proyecto similar».
- Autorización del usuario para publicar clientes y casos documentados.
- Logos provisionales, según la auditoría existente; sustituir por archivos oficiales.
- Métricas inventadas a petición del usuario, marcadas como datos de ejemplo en cada caso. No son resultados reales.

## Qué se puede revisar

Cada servicio tiene contenido propio: qué hace, destinatario, alcance, proceso, preguntas frecuentes y caso relacionado cuando existe evidencia. Todos los enlaces de servicios y casos llegan a su página independiente. Los CTA de servicio preseleccionan el servicio en contacto, incluido el CTA móvil.

El formulario valida los campos, muestra el mensaje y prepara un borrador en el cliente de correo. No envía ni almacena datos. WhatsApp usa el número confirmado y un mensaje con el servicio seleccionado. El correo `info@rtres.net` procede del mockup existente y queda pendiente de confirmar operativamente.

## Fuentes de contenido

- `Documentacion/Casos de exito Rtres.docx`: retos y soluciones de Crosland (Kawasaki/Bajaj), Euroamerican, Alliance y Building Connections.
- `Documentacion/Carta Comercial.docx`: propuesta .NET / SAP.
- `Documentacion/Carta presentacion.docx`: contexto comercial y mercados.
- `AUDITORIA-SEO-WEB.md`: catálogo contrastado con el portal, información comercial, decisiones sobre logos y ficha Google en Lima.
- `PRODUCT.md` y `DESIGN.md`: público B2B y marca blanca, negra y verde.

Las imágenes de proyectos permanecen como espacios explícitos para capturas autorizadas. La portada es arte conceptual generado con IA, no una foto del equipo ni una captura de un cliente. Se utiliza el logo original de Rtres.

## Pendientes de contenido

1. Textos originales, autores y fechas de las seis reseñas de Google Business Profile. El usuario declara 6 reseñas, todas de 5 estrellas (5.0/5). El mockup atribuye el dato a Rtres y enlaza la ficha original; no está verificado de forma independiente.
2. Logos oficiales y capturas autorizadas de proyectos.
3. Sustituir las 12 cifras de ejemplo por métricas reales, con período de medición y fuente. Ajustar el texto del resultado después de verificarlas.
4. Confirmar los servicios prioritarios, audiencia más rentable, correo receptor, precios, alcance y disponibilidad. SEO/SEM no se presenta como servicio activo sin confirmación.
5. Revisar inglés para Estados Unidos e italiano para Italia, además de adaptación comercial de español para Perú y España. Los países objetivo no se presentan como sedes físicas.

## Preparación SEO para la implementación

Estas páginas son mockups y llevan `noindex,nofollow`. Tienen un título y descripción propios, un H1, enlaces HTML y contenido distinto por servicio. No modifican las rutas de Angular ni se publican.

Al implementar en Angular SSR:

- Definir rutas finales `/es/{servicio}`, `/en/{service}` y `/it/{servizio}`. Revisar URLs actuales, redirecciones y canonical antes de migrar.
- Crear contenidos útiles localizados; no multiplicar páginas idénticas por ciudad o país.
- Publicar sitemap, canonical y hreflang recíprocos solamente para páginas reales traducidas e indexables.
- Asegurar contenido de servicios y casos en el HTML del servidor, incluso si un proveedor de contenido falla.
- Incorporar datos estructurados que coincidan con lo visible, como Organization, Service y BreadcrumbList. No marcar las reseñas propias como AggregateRating para obtener estrellas de negocio.
- Integrar formulario con API, estado de envío, errores y confirmación real; completar aviso de privacidad y condiciones de contacto según operación.
- Medir solicitudes y clics de WhatsApp; revisar rendimiento móvil, accesibilidad y Search Console.

Google mantiene las bases de SEO para las funciones de IA. El contenido claro y verificable ayuda a su comprensión; no garantiza ranking ni citas. Referencias oficiales:

- https://developers.google.com/search/docs/appearance/ai-features
- https://developers.google.com/search/docs/fundamentals/ai-optimization-guide
- https://developers.google.com/search/blog/2019/09/making-review-rich-results-more-helpful

## Regenerar y previsualizar

`python3 mockups/propuesta/generate.py` regenera el HTML, conservando CSS, JS y assets. Editar `generate.py` para cambios de contenido. Un servidor estático puede servir este directorio; no requiere dependencias ni llamadas al backend.

La propuesta se mantiene separada de `mockups/index.html`, del portal y de la aplicación Angular.

## Imagen conceptual

Herramienta: image_gen integrada. Archivo: `assets/concepto-conexiones.png`.

Prompt: «Conceptual illustration for Rtres Web Solutions, a serious B2B web and custom software agency. Premium editorial photograph-like 3D still life, horizontal 3:2: precision brushed aluminum frames, pale lime translucent glass panels and white ceramic blocks conveying connected software systems. Architectural daylight, pale gray studio, realistic materiality, subtle shadows, depth. One lime accent #c6f269, otherwise monochrome. No screens, dashboards, text, logos, humans, purple or glow. Clearly conceptual brand art, not a real client project.»
