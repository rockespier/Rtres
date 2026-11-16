# Auditoría SEO — https://rtres.net/es/

- **Puntuación:** 72/100 (Mejorable)
- **Fecha:** 2026-11-13T09:03:25.741482+00:00

4 aspectos a corregir y 12 a mejorar detectados: revísalos abajo.

## 1. Rastreo e indexación — 91.7/100

### Cadena de redirecciones antes del 200 [Mejorable]

La URL solicitada pasa por 1 redirección(es) antes de devolver 200: https://rtres.net → https://rtres.net/es/. Cada salto añade latencia y diluye la señal de rastreo; enlaza siempre directamente a la URL final.

```
[(302, 'https://rtres.net')]
```

- Fuente: [Google Search Central: HTTP status codes](https://developers.google.com/crawling/docs/troubleshooting/http-status-codes?hl=es)

### Sin indicios de soft 404 [Correcto]

No se detectan señales típicas de soft 404 (200 con contenido vacío o de error).

- Fuente: [Google Search Central: Soft 404 errors](https://developers.google.com/crawling/docs/troubleshooting/http-status-codes?hl=es)

### No bloqueada en robots.txt [Correcto]

robots.txt permite el rastreo de esta ruta tanto a Googlebot como al user-agent genérico.

- Fuente: [Google Search Central: Introducción a robots.txt](https://developers.google.com/search/docs/crawling-indexing/robots/intro?hl=es)

### robots.txt no bloquea el CSS/JS de la página [Correcto]

Los 4 recursos CSS/JS enlazados desde esta página son accesibles para Googlebot según robots.txt.

- Fuente: [Google Search Central: JavaScript SEO y renderizado](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics?hl=es)
- Fuente: [Google Search Central: Introducción a robots.txt](https://developers.google.com/search/docs/crawling-indexing/robots/intro?hl=es)

### Meta robots / X-Robots-Tag (noindex, nofollow) [Correcto]

No se han encontrado las directivas 'noindex' ni 'nofollow' en meta robots ni en X-Robots-Tag.

```
meta robots='' | X-Robots-Tag=''
```

- Fuente: [Google Search Central: meta robots y X-Robots-Tag](https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag?hl=es)

### Sin meta refresh (redirección obsoleta) [Correcto]

No se usa <meta http-equiv="refresh">.

- Fuente: [MDN: atributo http-equiv de <meta>](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta/http-equiv)

### Canonical autorreferencial y absoluta [Correcto]

La canonical (https://rtres.net/es/) es absoluta y apunta a la propia URL (en el HTML).

- Fuente: [Google Search Central: Consolidar URLs duplicadas con rel=canonical](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls?hl=es)

### Sitemap declarado e incluye la URL [Correcto]

Declarado en robots.txt. La URL aparece en el sitemap (https://rtres.net/sitemap.xml).

- Fuente: [Google Search Central: Cómo crear un sitemap](https://developers.google.com/search/docs/crawling-indexing/sitemaps/build-sitemap?hl=es)

### Sin parámetros de consulta [Correcto]

La URL no lleva parámetros de consulta que puedan generar contenido duplicado.

- Fuente: [Google Search Central: Contenido duplicado](https://developers.google.com/search/docs/crawling-indexing/canonicalization?hl=es)

## 2. URL y arquitectura — 100/100

### URL corta y legible [Correcto]

La URL tiene 21 caracteres, dentro de un rango razonable.

- Fuente: [Google Search Central: Estructura de URLs](https://developers.google.com/search/docs/crawling-indexing/url-structure?hl=es)

### URL en minúsculas y con guiones [Correcto]

La URL sigue el formato recomendado (minúsculas, guiones medios).

- Fuente: [Google Search Central: Estructura de URLs](https://developers.google.com/search/docs/crawling-indexing/url-structure?hl=es)

### Sin fechas/IDs innecesarios [Correcto]

No se detectan patrones de fecha ni IDs numéricos largos en la ruta.

- Fuente: [Google Search Central: Estructura de URLs](https://developers.google.com/search/docs/crawling-indexing/url-structure?hl=es)

### Profundidad de la URL [Correcto]

Profundidad de 1 nivel(es) respecto a la raíz, razonable.

- Fuente: [Google Search Central: Estructura de URLs](https://developers.google.com/search/docs/crawling-indexing/url-structure?hl=es)

### Breadcrumbs visibles y marcados [No evaluable]

Esta página está en el primer nivel (o es la home): los breadcrumbs no suelen aportar aquí.

- Fuente: [Google Search Central: Datos estructurados BreadcrumbList](https://developers.google.com/search/docs/appearance/structured-data/breadcrumb?hl=es)

## 3. Etiquetas on-page — 100/100

### Estructura de encabezados (H1 único, primero y sin saltos) [Correcto]

Un único H1 ("Tecnología que hace avanzar tu negocio."), es el primer encabezado de la página, y los niveles siguientes son consecutivos sin saltos.

```
Secuencia real: H1 → H2 → H2 → H3 → H3 → H3 → H2 → H2 → H2
```

- Fuente: [Google: Mejores prácticas de encabezados (SEO Starter Guide)](https://developers.google.com/search/docs/fundamentals/seo-starter-guide?hl=es#make_your_site_interesting_and_useful)

### Encabezados razonablemente descriptivos [Correcto]

Los encabezados parecen suficientemente descriptivos.

- Fuente: [Google: Mejores prácticas de encabezados (SEO Starter Guide)](https://developers.google.com/search/docs/fundamentals/seo-starter-guide?hl=es#make_your_site_interesting_and_useful)

### Encabezados sin texto [Correcto]

Los 9 encabezados tienen contenido.

- Fuente: [Google: Mejores prácticas de encabezados (SEO Starter Guide)](https://developers.google.com/search/docs/fundamentals/seo-starter-guide?hl=es#make_your_site_interesting_and_useful)

### Title con longitud adecuada [Correcto]

El title tiene 56 caracteres: "Software a medida y desarrollo web en Lima, Perú | Rtres".

- Fuente: [Google Search Central: Título de página (title link)](https://developers.google.com/search/docs/appearance/title-link?hl=es)

### Meta description con longitud adecuada [Correcto]

La meta description tiene 145 caracteres: "Desarrollamos software a medida, apps web e integraciones con SAP y SUNAT para empresas en Perú, Italia y España. Socios tecnológicos desde 2007.".

- Fuente: [Google Search Central: Snippets y meta description](https://developers.google.com/search/docs/appearance/snippet?hl=es)

### Atributo lang en <html> [Correcto]

El atributo lang está definido como 'es'.

- Fuente: [W3C: El atributo lang en HTML](https://www.w3.org/International/questions/qa-html-language-declarations)

### Meta charset declarado [Correcto]

Se declara la codificación de caracteres (<meta charset> o Content-Type con charset).

- Fuente: [MDN: elemento <meta>](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/meta)

### Open Graph [Correcto]

5 de 5 atributos presentes.

- [pass] og:title: Software a medida y desarrollo web en Lima, Perú | Rtres
- [pass] og:description: Desarrollamos software a medida, apps web e integraciones con SAP y SUNAT para empresas en Perú, Italia y España. Socios tecnológicos desde 2007.
- [pass] og:image: https://rtres.net/es/assets/og-image-es.jpg
- [pass] og:url: https://rtres.net/es/
- [pass] og:type: website

- Fuente: [Meta: The Open Graph protocol](https://ogp.me/)

### Twitter/X Cards [Correcto]

4 de 4 atributos presentes.

- [pass] twitter:card: summary_large_image
- [pass] twitter:title: Software a medida y desarrollo web en Lima, Perú | Rtres
- [pass] twitter:description: Desarrollamos software a medida, apps web e integraciones con SAP y SUNAT para empresas en Perú, Italia y España. Socios tecnológicos desde 2007.
- [pass] twitter:image: https://rtres.net/es/assets/og-image-es.jpg

- Fuente: [X (Twitter): Cards markup](https://developer.x.com/en/docs/x-for-websites/cards/overview/markup)

### Favicon declarado [Correcto]

Se ha encontrado <link rel="icon">: https://rtres.net/es/assets/favicon.svg

- Fuente: [Google Search Central: Favicon en los resultados de búsqueda](https://developers.google.com/search/docs/appearance/favicon-in-search?hl=es)

### Enlaces internos sin nofollow innecesario [Correcto]

No se encuentran enlaces internos con rel="nofollow" innecesario.

- Fuente: [Google Search Central: Cualifica tus enlaces salientes](https://developers.google.com/search/docs/crawling-indexing/qualify-outbound-links?hl=es)

## 4. Contenido — 87.5/100

### Extensión del contenido [Correcto]

El texto visible tiene aproximadamente 547 palabras. Extensión suficiente para desarrollar el tema, siempre que no sea relleno.

- Fuente: [Google Search Central: Sistema de contenido útil](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es)

### Autor identificado [No evaluable]

No se detecta autor, pero esta página no se declara a sí misma como artículo/post (sin schema Article/BlogPosting, og:type="article" ni article:published_time) — en landings, fichas de servicio/producto o la home, marcar autoría individual no suele aplicar.

- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)

### Fechas de publicación/actualización [No evaluable]

No se detectan fechas, pero esta página no se declara a sí misma como artículo/post — en landings, fichas de servicio/producto o la home no suele ser necesario mostrar fecha de publicación.

- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)

### Texto alternativo en imágenes [Correcto]

2 de 2 imágenes (100%) tienen atributo alt (vacío o con texto). Faltan 0 sin el atributo.

- Fuente: [Google Search Central: Uso del atributo alt](https://developers.google.com/search/docs/appearance/google-images?hl=es#alt-text)
- Fuente: [Google Search Central: Prácticas recomendadas para imágenes](https://developers.google.com/search/docs/appearance/google-images?hl=es)

### Nombres de archivo de imagen semánticos [Correcto]

0 de 2 imágenes tienen nombres de archivo genéricos (ej. IMG_1234.jpg) en vez de describir el contenido de la imagen.

- Fuente: [Google Search Central: Prácticas recomendadas para imágenes](https://developers.google.com/search/docs/appearance/google-images?hl=es)

### Contenido en pestañas/acordeones [Correcto]

No se detectan patrones evidentes de contenido oculto en pestañas o acordeones.

- Fuente: [Google Search Central: Sistema de contenido útil](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es)

### Texto no depende únicamente de imágenes [Correcto]

Hay suficiente texto extraíble en el HTML respecto al número de imágenes.

- Fuente: [Google Search Central: Uso del atributo alt](https://developers.google.com/search/docs/appearance/google-images?hl=es#alt-text)

### Legibilidad del texto [Mejorable]

Puntuación de legibilidad estimada: 56.9/100 (Fernández Huerta (adaptación al español de Flesch)). Moderadamente difícil. La longitud de las frases es razonable; lo que más penaliza aquí es la densidad de palabras largas (nombres de producto, categorías, términos técnicos...) — habitual en páginas de listado/menú, no necesariamente un problema real de redacción.

```
palabras/frase: 14.4 — densidad de sílabas: 225.3
```

- Fuente: [Wikipedia: Legibilidad (fórmulas de Flesch y Fernández Huerta)](https://es.wikipedia.org/wiki/Legibilidad)

### Responde a la intención de búsqueda real [Sin API detectada]

Con API key, se evalúa si el contenido responde con claridad a lo que buscaría alguien con esta consulta, ya desde los primeros párrafos.

- Fuente: [Google Search Central: Sistema de contenido útil](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es)

### Cobertura temática completa (entidades y subtemas) [Sin API detectada]

Con API key, se evalúa si el tema se cubre con profundidad (subtemas, entidades relacionadas, preguntas relevantes) o de forma superficial.

- Fuente: [Google Search Central: Sistema de contenido útil](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es)

### Contenido original, no plantilla ni reescritura genérica [Sin API detectada]

Con API key, se evalúa si el contenido parece original y con voz propia, o genérico/plantilla sin aporte real.

- Fuente: [Google Search Central: Sistema de contenido útil](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es)

### Ortografía y gramática (evaluado por IA) [Sin API detectada]

Con API key, se revisa el texto en busca de errores ortográficos y gramaticales, en el idioma en que esté escrito.

## 5. Datos estructurados (Schema.org) — 75/100

### Datos estructurados Schema detectados [Correcto]

1 tipo(s) de contenido detectado(s) (además de los estructurales/de identidad, que se muestran abajo).

- [na] ProfessionalService: Válido en Schema.org, sin resultado enriquecido de Google asociado

- Fuente: [Schema.org: ProfessionalService](https://schema.org/ProfessionalService)

### BreadcrumbList marcado [Mejorable]

No se detecta BreadcrumbList en JSON-LD.

- Fuente: [Google Search Central: Datos estructurados BreadcrumbList](https://developers.google.com/search/docs/appearance/structured-data/breadcrumb?hl=es)

### Identidad del sitio marcada (Organization / WebSite) [Correcto]

Detectado: Organization . Esto describe QUIÉN es el sitio/marca (su identidad), no de qué trata esta página en concreto — son cosas distintas y ambas pueden estar bien marcadas a la vez.

- Fuente: [Schema.org: Organization](https://schema.org/Organization)

### Logo de marca en schema Organization [Correcto]

El schema Organization/LocalBusiness incluye la propiedad 'logo'.

- Fuente: [Schema.org: Organization](https://schema.org/Organization)

### Enlaces sameAs a perfiles externos [Correcto]

Se encuentra 'sameAs' con 3 enlace(s) a perfiles externos (redes sociales, Wikidata, Wikipedia...) — ayuda a Google a confirmar la entidad en su Knowledge Graph.

- [pass] https://maps.google.com/?cid=1846831983078032863
- [pass] https://pe.linkedin.com/company/rtres-web-solutions
- [pass] https://clutch.co/profile/rtres-web-solutions

- Fuente: [Schema.org: Organization](https://schema.org/Organization)

### Sin autor en datos estructurados [No evaluable]

No se encuentra el campo 'author', pero no aplica: 'author' es una propiedad de contenido redactado (artículos, recetas, reseñas...), no de este tipo de página.

- Fuente: [Schema.org: Person](https://schema.org/Person)

### No aplica: no es una página de producto [No evaluable]

No se ha detectado schema Product.

- Fuente: [Google Search Central: Datos estructurados Product](https://developers.google.com/search/docs/appearance/structured-data/product?hl=es)

### Marcado de entidades (about/mentions) [Mejorable]

No se usan las propiedades 'about'/'mentions' en el JSON-LD para reforzar de qué trata realmente la página ante buscadores y motores de IA.

- Fuente: [Schema.org: Vocabulario de datos estructurados](https://schema.org/)

### Sin vídeo embebido detectado [No evaluable]

No se detecta ningún <video> ni iframe de YouTube/Vimeo/Dailymotion en la página.

- Fuente: [Google Search Central: Datos estructurados VideoObject](https://developers.google.com/search/docs/appearance/structured-data/video?hl=es)

### Preparado para Top Stories / Google Discover [No evaluable]

No se detecta schema Article/NewsArticle/BlogPosting en esta página; no aplica.

- Fuente: [Google Search Central: Datos estructurados Article](https://developers.google.com/search/docs/appearance/structured-data/article?hl=es)

## 6. Rendimiento y Core Web Vitals — 35/100

### Compresión Brotli/Gzip activa [Correcto]

Content-Encoding: 'gzip'.

- Fuente: [web.dev: Reduce payloads de red con compresión de texto](https://web.dev/articles/optimizing-content-efficiency-optimize-encoding-and-transfer?hl=es)

### Cabeceras de caché configuradas [Correcto]

Cache-Control: 'no-cache'.

- Fuente: [web.dev: Estrategias de caché HTTP eficaces](https://web.dev/articles/http-cache?hl=es)

### Protocolo HTTP moderno (HTTP/2 o HTTP/3) [Correcto]

La conexión usa HTTP/2, que permite multiplexar peticiones sobre la misma conexión (más rápido que HTTP/1.1, sobre todo con muchos recursos).

- Fuente: [High Performance Browser Networking: HTTP/2](https://hpbn.co/http2/)

### Imágenes con dimensiones reservadas [Fallo]

2 de 2 imágenes no declaran width/height ni aspect-ratio: el navegador no puede reservarles espacio antes de cargarlas, lo que suele causar Cumulative Layout Shift.

- [fail] logo-rtres.png: https://rtres.net/es/assets/logo-rtres.png
- [fail] logo-rtres.png: https://rtres.net/es/assets/logo-rtres.png

- Fuente: [web.dev: Establece el tamaño de imágenes y vídeos](https://web.dev/articles/optimize-cls?hl=es#images_without_dimensions)

### Carga diferida de imágenes fuera del viewport [No evaluable]

La página tiene 2 imágenes; se descartan las primeras 3 por ser previsiblemente visibles sin hacer scroll, y no quedan más para evaluar.

- Fuente: [web.dev: Carga diferida de imágenes](https://web.dev/articles/browser-level-image-lazy-loading?hl=es)

### Imagen principal (LCP) sin lazy-load [No evaluable]

No se identifica una imagen principal clara en el HTML (solo logos, iconos o ninguna imagen).

- Fuente: [web.dev: Largest Contentful Paint (LCP)](https://web.dev/articles/lcp?hl=es)
- Fuente: [web.dev: Carga diferida de imágenes](https://web.dev/articles/browser-level-image-lazy-loading?hl=es)

### Carga diferida de vídeos [No evaluable]

La página no contiene elementos <video> ni vídeos embebidos (YouTube/Vimeo/Dailymotion); no aplica.

- Fuente: [web.dev: Carga diferida de vídeos](https://web.dev/articles/lazy-loading-video?hl=es)

### Tamaño del DOM [Correcto]

El HTML inicial tiene 282 nodos — dentro de un rango razonable.

```
nodos totales: 282
```

- Fuente: [web.dev: Tamaño del DOM e interactividad](https://web.dev/articles/dom-size-and-interactivity?hl=es)

### Preconnect/dns-prefetch a orígenes de terceros [Mejorable]

1 de 1 orígenes de terceros que carga la página no tienen <link rel="preconnect"> ni "dns-prefetch" declarado: el navegador no puede adelantar la conexión DNS/TLS hasta que encuentra el primer recurso real de ese origen, añadiendo latencia.

- [fail] www.googletagmanager.com: https://www.googletagmanager.com/gtag/js?id=G-MLW2PGGR1K

- Fuente: [web.dev: Preconnect a orígenes requeridos](https://web.dev/articles/preconnect-and-dns-prefetch?hl=es)

### Tamaño del documento HTML [Correcto]

El HTML inicial pesa 0.04 MB — dentro de un rango razonable.

```
0.04 MB (44127 bytes)
```

- Fuente: [web.dev: Reduce payloads de red con compresión de texto](https://web.dev/articles/optimizing-content-efficiency-optimize-encoding-and-transfer?hl=es)

### Datos de campo (CrUX) disponibles [Correcto]

Hay datos reales de usuarios (CrUX) disponibles para esta URL.

- Fuente: [Chrome Developers: Acerca del Chrome UX Report (CrUX)](https://developer.chrome.com/docs/crux)

### LCP < 2.5s (móvil) [Fallo]

LCP en móvil (datos de campo real): 4.15s. Objetivo: ≤ 2.5s.

- Fuente: [web.dev: Largest Contentful Paint (LCP)](https://web.dev/articles/lcp?hl=es)

### INP < 200ms (móvil) [Correcto]

INP en móvil (datos de campo real): 176ms. Objetivo: ≤ 200ms. INP no tiene una buena aproximación de laboratorio; solo se mide con datos de campo reales.

- Fuente: [web.dev: Interaction to Next Paint (INP)](https://web.dev/articles/inp?hl=es)

### CLS < 0.1 (móvil) [Correcto]

CLS en móvil (datos de campo real): 0.000. Objetivo: ≤ 0.1.

- Fuente: [web.dev: Cumulative Layout Shift (CLS)](https://web.dev/articles/cls?hl=es)

### TTFB razonable [Correcto]

Tiempo de respuesta del servidor: 2ms. Objetivo: ≤ 600ms.

- Fuente: [web.dev: Time to First Byte (TTFB)](https://web.dev/articles/ttfb?hl=es)

### Sin JavaScript innecesario/sin usar [Fallo]

Ahorro estimado de 119 KiB

- [fail] js: https://www.googletagmanager.com/gtag/js?id=G-MLW2PGGR1K — 177 KiB — 73 KiB de ahorro potencial
- [fail] main-POWAO77C.js: https://rtres.net/es/main-POWAO77C.js — 120 KiB — 46 KiB de ahorro potencial

- Fuente: [web.dev: Elimina JavaScript sin usar](https://web.dev/articles/remove-unused-code?hl=es)

## 7. Experiencia, móvil y accesibilidad — 87.5/100

### Meta viewport correcta y sin bloquear el zoom [Correcto]

viewport='width=device-width,initial-scale=1': incluye width=device-width y no bloquea el zoom táctil.

- Fuente: [Google Search Central: Configuración de viewport](https://developers.google.com/search/docs/crawling-indexing/mobile/mobile-sites-mobile-first-indexing?hl=es)
- Fuente: [W3C: Web Content Accessibility Guidelines (WCAG)](https://www.w3.org/WAI/standards-guidelines/wcag/)

### Uso de etiquetas HTML semánticas [Correcto]

5 de 5 etiquetas semánticas presentes.

```
<div>/<span>: 51 de 282 etiquetas (18%)
```

- [pass] main
- [pass] article
- [pass] nav
- [pass] header
- [pass] footer

- Fuente: [MDN: Estructurar documentos (HTML semántico)](https://developer.mozilla.org/es/docs/Learn_web_development/Core/Structuring_content/Structuring_documents)
- Fuente: [web.dev: Aprende HTML semántico](https://web.dev/learn/html/semantic-html?hl=es)

### Enlace "saltar al contenido" [Mejorable]

No se detecta un enlace "saltar al contenido" al inicio de la página; ayuda a usuarios de teclado y lectores de pantalla a evitar repetir la navegación en cada carga.

- Fuente: [W3C: Web Content Accessibility Guidelines (WCAG)](https://www.w3.org/WAI/standards-guidelines/wcag/)

### Campos de formulario con <label> asociado [No evaluable]

La página no contiene campos de formulario (input/textarea/select) que necesiten <label>.

- Fuente: [W3C: Web Content Accessibility Guidelines (WCAG)](https://www.w3.org/WAI/standards-guidelines/wcag/)

### Iframes con título accesible [No evaluable]

La página no contiene ningún <iframe>.

- Fuente: [W3C: Título en iframes (Técnica H64)](https://www.w3.org/WAI/WCAG21/Techniques/html/H64)

### Botones con nombre accesible [Correcto]

Los 11 botones/controles tienen nombre accesible (texto, aria-label, aria-labelledby, title o alt de una imagen interior).

- Fuente: [W3C: Fallo por controles sin nombre accesible (F84)](https://www.w3.org/WAI/WCAG21/Techniques/failures/F84)

### Sin tabindex positivo (orden de tabulación) [Correcto]

No se usa ningún tabindex positivo; el orden de tabulación sigue el orden natural del documento.

- Fuente: [web.dev: Controla el foco con tabindex](https://web.dev/articles/control-focus-with-tabindex?hl=es)

### Tablas de datos con cabeceras (<th>) [No evaluable]

La página no contiene tablas con pinta de tabla de datos (≥2 filas y ≥2 columnas).

- Fuente: [WebAIM: Tablas de datos accesibles](https://webaim.org/techniques/tables/data)

### Enlaces sin texto descriptivo [Correcto]

No se detectan enlaces con texto genérico habitual ("leer más", "click aquí"...).

- Fuente: [W3C: Propósito del enlace en su contexto (WCAG 2.4.4)](https://www.w3.org/WAI/WCAG21/Understanding/link-purpose-in-context.html)

## 8. Confianza y E-E-A-T — 35/100

### HTTPS con certificado válido [Correcto]

La página se sirve sobre HTTPS y respondió correctamente (si hubiera error de certificado, la petición habría fallado).

- Fuente: [Google Search Central: HTTPS como señal de posicionamiento](https://developers.google.com/search/blog/2014/08/https-as-ranking-signal?hl=es)

### Caducidad del certificado SSL [Correcto]

El certificado SSL es válido 37 día(s) más (emisor: Let's Encrypt).

- Fuente: [Google Search Central: HTTPS como señal de posicionamiento](https://developers.google.com/search/blog/2014/08/https-as-ranking-signal?hl=es)

### Enlaces a contacto, sobre nosotros, aviso legal y privacidad [Mejorable]

Comprobado en esta página y en la portada del sitio. Sin encontrar: Sobre nosotros, Aviso legal, Privacidad. 'Privacidad' cuenta como válida tanto con una política dedicada como con una de cookies (práctica habitual); si aun así falta, puede estar fusionada dentro del aviso legal.

- [pass] Contacto: Enlazado
- [fail] Sobre nosotros: No encontrado
- [fail] Aviso legal: No encontrado
- [fail] Privacidad: No encontrado

- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)

### Reseñas/testimonios marcados [Mejorable]

Hay un widget de reseñas visible, pero sin marcado JSON-LD (Review/AggregateRating) que lo respalde: te quedas sin la posibilidad de mostrar estrellas en el resultado de Google.

- Fuente: [Google Search Central: Datos estructurados Review/AggregateRating](https://developers.google.com/search/docs/appearance/structured-data/review-snippet?hl=es)

### Datos de empresa verificables en la página [Mejorable]

Heurística textual, no una verificación real contra el registro mercantil o Google Business Profile.

- [pass] Teléfono: Detectado
- [na] Dirección: No detectada
- [na] NIF / CIF / VAT: No detectado

- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)

### Cabeceras de seguridad HTTP [Fallo]

0 de 4 cabeceras de seguridad presentes. Faltan: Strict-Transport-Security, X-Content-Type-Options, Content-Security-Policy, X-Frame-Options.

- [fail] Strict-Transport-Security
- [fail] X-Content-Type-Options
- [fail] Content-Security-Policy
- [fail] X-Frame-Options

- Fuente: [web.dev: Cabeceras de seguridad HTTP](https://web.dev/articles/security-headers?hl=es)

### Sin contenido mixto (recursos http:// en página https://) [Correcto]

No se detectan recursos (script/img/link/iframe/video/audio) cargados por http:// en esta página https://.

- Fuente: [web.dev: Arregla el contenido mixto](https://web.dev/articles/what-is-mixed-content?hl=es)

### Profundidad de E-E-A-T (experiencia, pericia, autoridad, confianza) [Sin API detectada]

Con API key, se evalúa si hay señales reales de experiencia de primera mano, pericia y confianza, no solo afirmaciones vacías.

- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)
- Fuente: [Google: Search Quality Rater Guidelines](https://static.googleusercontent.com/media/guidelines.raterhub.com/en//searchqualityevaluatorguidelines.pdf)

## 9. Internacional — 100/100

### og:locale coherente con lang [Correcto]

og:locale='es_PE' coincide en idioma con lang='es'.

- Fuente: [Meta: The Open Graph protocol](https://ogp.me/)

### x-default declarado [Correcto]

Se declara x-default.

- Fuente: [Google Search Central: hreflang para contenido localizado](https://developers.google.com/search/docs/specialty/international/localized-versions?hl=es)

### Códigos hreflang bien formados [Correcto]

Todos los códigos hreflang tienen formato válido (ej. es-ES, en, x-default).

- Fuente: [Google Search Central: hreflang para contenido localizado](https://developers.google.com/search/docs/specialty/international/localized-versions?hl=es)

### hreflang recíproco (muestra de 1 URL) [Correcto]

La URL alternativa comprobada (https://rtres.net/en/) enlaza de vuelta a esta página vía hreflang.

- Fuente: [Google Search Central: hreflang para contenido localizado](https://developers.google.com/search/docs/specialty/international/localized-versions?hl=es)

### Coherencia entre hreflang y canonical [Correcto]

Esta URL se referencia a sí misma en el bloque hreflang y coincide con su canonical.

- Fuente: [Google Search Central: hreflang para contenido localizado](https://developers.google.com/search/docs/specialty/international/localized-versions?hl=es)
- Fuente: [Google Search Central: Consolidar URLs duplicadas con rel=canonical](https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls?hl=es)

## 10. AI SEO (optimización para asistentes de IA) — 55/100

### Acceso de crawlers de IA en robots.txt [Correcto]

11 de 11 bots permitidos. Revisa si cada bloqueo es una decisión consciente: bloquear Google-Extended, por ejemplo, te excluye de las AI Overviews de Google sin mejorar tu SEO clásico; bloquear GPTBot/ClaudeBot/PerplexityBot te excluye del entrenamiento y/o de las citas en esos asistentes.

- [pass] GPTBot
- [pass] OAI-SearchBot
- [pass] ChatGPT-User
- [pass] ClaudeBot
- [pass] Claude-User
- [pass] PerplexityBot
- [pass] Google-Extended
- [pass] Applebot-Extended
- [pass] Meta-ExternalAgent
- [pass] Bytespider
- [pass] CCBot

- Fuente: [OpenAI: Visión general de GPTBot](https://developers.openai.com/api/docs/bots)
- Fuente: [Anthropic: Documentación de ClaudeBot](https://support.claude.com/en/articles/8896518-does-anthropic-crawl-data-from-the-web-and-how-can-site-owners-block-the-crawler)
- Fuente: [Perplexity: PerplexityBot](https://docs.perplexity.ai/guides/bots)
- Fuente: [Google: Google-Extended (control de uso en IA generativa)](https://developers.google.com/crawling/docs/crawlers-fetchers/google-common-crawlers?hl=es)

### Sin bloqueo por firewall/WAF a bots de IA [Mejorable]

No responden en absoluto ni siquiera tras reintentar, como si la conexión se descartara: Bytespider, CCBot. Esto suele pasar cuando el servidor encola o descarta peticiones bajo una ráfaga de varias solicitudes casi simultáneas a la misma URL (justo lo que hace esta prueba, al comprobar varios bots seguidos), no necesariamente un bloqueo dirigido a bots de IA — pero si persiste también con tráfico real, sí puede impedirles el acceso.

- [pass] GPTBot: 200
- [pass] OAI-SearchBot: 200
- [pass] ChatGPT-User: 200
- [pass] ClaudeBot: 200
- [pass] Claude-User: 200
- [pass] PerplexityBot: 200
- [pass] Meta-ExternalAgent: 200
- [na] Bytespider: sin respuesta
- [na] CCBot: sin respuesta

- Fuente: [OpenAI: Visión general de GPTBot](https://developers.openai.com/api/docs/bots)
- Fuente: [Anthropic: Documentación de ClaudeBot](https://support.claude.com/en/articles/8896518-does-anthropic-crawl-data-from-the-web-and-how-can-site-owners-block-the-crawler)

### Contenido presente en el HTML inicial (sin ejecutar JS) [Correcto]

El HTML inicial contiene ~547 palabras de texto visible sin ejecutar JavaScript.

```
word_count=547, body_children=3, script_tags=5
```

- Fuente: [Google Search Central: JavaScript SEO y renderizado](https://developers.google.com/search/docs/crawling-indexing/javascript/javascript-seo-basics?hl=es)

### Archivo llms.txt [Mejorable]

No se ha encontrado https://rtres.net/llms.txt. Es una convención emergente (todavía no un estándar oficial como robots.txt) para dar a los LLM un resumen curado del sitio en texto plano — cada vez más adoptada, pero su ausencia no es un fallo de SEO establecido.

- Fuente: [llms.txt: propuesta de estándar para contexto de IA](https://llmstxt.org/)

### Herramientas WebMCP para agentes de IA [Mejorable]

No se detectan herramientas WebMCP (ni el atributo declarativo 'toolname' en formularios ni document.modelContext.registerTool() en scripts inline). Es una propuesta muy reciente para que un agente de IA pueda invocar acciones de la página (buscar, añadir al carrito...) sin depender de interpretar el DOM — cada vez más relevante de cara al AI SEO, pero su ausencia no es (todavía) un fallo establecido. Nota: esta comprobación no detecta un registro que viva solo en un archivo JS externo, no ejecutamos JavaScript al auditar.

- Fuente: [WebMCP: especificación (W3C Web Machine Learning CG)](https://webmachinelearning.github.io/webmcp/)

### Resumen/TL;DR o respuesta directa al inicio [Sin API detectada]

Con API key, se comprueba si hay un resumen o respuesta directa cerca del inicio, sin obligar a leer todo el artículo.

- Fuente: [Google: Cómo funcionan las AI Overviews / IA generativa en la Búsqueda](https://developers.google.com/search/docs/appearance/ai-features?hl=es)

### Secciones autocontenidas, extraíbles por chunks [Sin API detectada]

Con API key, se evalúa si cada sección se entendería de forma aislada (útil para que un LLM la cite por fragmentos) o depende del contexto anterior.

- Fuente: [Google: Cómo funcionan las AI Overviews / IA generativa en la Búsqueda](https://developers.google.com/search/docs/appearance/ai-features?hl=es)
- Fuente: [Estudio académico: optimización de contenido para motores de IA generativa (arXiv)](https://arxiv.org/abs/2311.09735)

### Datos verificables que un asistente de IA pueda citar con seguridad [Sin API detectada]

Con API key, se buscan datos concretos y comprobables (cifras propias, estadísticas con fuente, casos reales) que un asistente de IA pueda citar con seguridad.

- Fuente: [Estudio académico: optimización de contenido para motores de IA generativa (arXiv)](https://arxiv.org/abs/2311.09735)
- Fuente: [Google Search Central: E-E-A-T y calidad de contenido](https://developers.google.com/search/docs/fundamentals/creating-helpful-content?hl=es#eat)

### Marca/producto nombrados de forma consistente [Sin API detectada]

Con API key, se comprueba si el nombre de la marca/producto se escribe siempre igual, de forma reconocible como entidad.

- Fuente: [Schema.org: Vocabulario de datos estructurados](https://schema.org/)
