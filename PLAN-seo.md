# Plan SEO — rtres.net (sitio multipágina)

**Fecha de la auditoría:** 12 de octubre de 2026, sobre el sitio en producción (`https://rtres.net`, ES/EN/IT, 27 páginas prerenderizadas).
**Reemplaza a** `AUDITORIA-SEO-WEB.md` (1 de octubre), que describía el sitio anterior de una sola página. Varios de sus puntos ya se resolvieron: hay páginas por servicio y por caso, testimonios reales y un enlace correcto al portal.
**Límites:** no hay herramientas SEO conectadas (Ahrefs/Semrush), así que la dificultad y la oportunidad de las palabras clave son estimaciones cualitativas. La API de PageSpeed no tenía cuota el día de la auditoría, así que la velocidad se midió con `curl`.

## Resumen

La base es buena: HTML prerenderizado, un H1 por página, URLs limpias, título y description en servicios y casos, `alt` en las imágenes y 3 idiomas. Faltan las señales técnicas con las que Google descubre, entiende y ubica el sitio:
- sin `robots.txt`, sin sitemap, sin canonical, sin `hreflang`, sin Open Graph ni datos estructurados;
- un home que no dice qué ofrece Rtres ni dónde (0 menciones de Lima, Perú, Italia o España);
- imágenes muy pesadas (≈3.9 MB en el home) y un servidor que tarda entre 0.8 y 5.4 s en responder.

## Hallazgos técnicos

| Revisión | Estado | Detalle |
|---|---|---|
| HTTPS, www → apex | ✅ | 301 a `https://rtres.net` |
| HTML prerenderizado, `lang` por idioma | ✅ | 27 rutas |
| Un H1 por página y `alt` en imágenes | ✅ | |
| `robots.txt` | ❌ | 404 |
| Sitemap XML | ❌ | 404 |
| Canonical | ❌ | Ausente en todas las páginas |
| `hreflang` | ❌ | Solo como atributo de los enlaces de idioma, que apuntan al home de cada idioma; no hay `<link rel="alternate">` |
| Open Graph / Twitter | ❌ | Al compartir en WhatsApp o LinkedIn no sale imagen ni descripción |
| Datos estructurados | ❌ | No hay JSON-LD |
| 404 | ❌ | Una URL inexistente devuelve 200 con el home (soft 404), por la regla de respaldo del `.htaccess` |
| Favicon | ❌ | `/favicon.ico` da 404 |
| Enlaces internos | ⚠️ | `/es/nosotros` (sin `/`) responde con un 301 a `/es/nosotros/` en cada enlace |
| TTFB | ⚠️ | Entre 0.8 y 5.4 s para HTML estático; falla la microcaché de Nginx del hosting |
| Imágenes | ⚠️ | `hero-dashboard.webp` 1.1 MB, `casos_exito.png` 1.4 MB, `portal-assistance.webp` 1.0 MB |
| Fuentes | ⚠️ | 3 familias de Google Fonts (14 archivos) |
| Dominios | ⚠️ | `www.r3solucionesweb.com` pasa por 3 saltos; `soluzionipersitiweb.it` no redirige (página de parking, sin SSL) |

## Hallazgos on-page

| Página | Problema | Severidad |
|---|---|---|
| Home (ES/EN/IT) | Sin meta description; título genérico "Rtres Web Solutions" | Crítico |
| Home | H1 sin servicio ni lugar; el único teléfono es italiano (+39), no hay +51 | Alto |
| Servicios y casos | Títulos sin palabra clave local; 290–350 palabras (contenido delgado) | Medio |
| EN / IT | Slugs en español (`/en/servicios/software-a-medida`) | Bajo |
| Recursos | 106 palabras en el HTML (los videos cargan en el navegador) | Bajo |

## Palabras clave objetivo (estimación cualitativa)

- **Alta oportunidad:**
  - desarrollo de software a medida Lima
  - empresa de desarrollo de software Perú
  - integración SAP Perú
  - integración de facturación electrónica SUNAT
  - software para talleres / DMS Perú
  - sistema de ventas y comisiones a medida
  - API consulta RUC DNI
  - API validación de cuentas bancarias Perú
- **Media:**
  - software para aseguradoras / asistencia al viajero
  - staff augmentation .NET Perú
  - hosting administrado con soporte Perú
  - portal de clientes a medida
  - cuánto cuesta un software a medida
  - qué es un DMS
  - sviluppo software su misura (IT)
  - nearshore custom software Latin America (EN)

---

## Plan

### Fase 1 — Esta semana (técnico y metadatos)
> **Estado (12/10/2026):** S1–S9 están implementadas en el código. Pendiente: desplegar, verificar con la lista de abajo y que el usuario haga S10.
> - S1: `scripts/deploy/seo-files.mjs`, que `Deploy-Local.ps1` ejecuta después del build.
> - S2–S5: `site/src/app/core/seo.service.ts`; el título y la description del home están en `home-page.component.ts`.
> - S6–S7: página `pages/not-found` y `scripts/deploy/site.htaccess`. Las reglas de Apache no se pudieron probar en local (no hay Apache ni Docker): verificar después del despliegue.
> - S8: imágenes recodificadas a WebP/JPEG (de ≈4.4 MB a ≈650 KB). `casos_exito.png` pasó a `casos_exito.webp`.
> - S9: `favicon.svg`, `favicon-32.png`, `apple-touch-icon.png` y `/favicon.ico`.
- [x] **S1.** `robots.txt` y `sitemap.xml` generados en el build, con las 27 URLs y sus alternates por idioma.
- [x] **S2.** Canonical absoluto, `<link rel="alternate" hreflang>` es/en/it y `x-default` en cada página.
- [x] **S3.** Título y meta description del home en los 3 idiomas, con servicio y lugar.
- [x] **S4.** Open Graph y Twitter cards por página, con una imagen para compartir de 1200×630.
- [x] **S5.** JSON-LD: `Organization` en todo el sitio y `BreadcrumbList` en las páginas internas.
- [x] **S6.** 404 real: quitar la regla de respaldo, crear una página 404 por idioma y servirla con `ErrorDocument`.
- [x] **S7.** Enlaces internos sin redirección. La URL canónica va sin `/` final; el `.htaccess` sirve el `index.html` de la carpeta sin 301.
- [x] **S8.** Comprimir las 3 imágenes grandes (a menos de 250 KB cada una).
- [x] **S9.** Favicon propio, `apple-touch-icon` y `/favicon.ico`.
- [ ] **S10.** *(Panel del dominio, lo hace el usuario.)* `soluzionipersitiweb.it` → 301 a `https://rtres.net/it/`. Dar de alta `rtres.net` en Google Search Console y enviar el sitemap.

### Fase 2 — Este trimestre (contenido y autoridad)
- [ ] **T1.** Landing de las APIs (RUC, DNI, cuentas bancarias), con precios y botón "Contratar" que lleva al portal.
- [ ] **T2.** Landings "Sistema para talleres (DMS)" e "Integración SUNAT / SAP", enlazadas a los casos Crosland y Euroamerican.
- [ ] **T3.** Página `/contacto` con formulario que envíe el lead al API y avise por correo, con medición de conversiones.
- [ ] **T4.** Señales locales: Google Business Profile en Lima, teléfono +51 y los mismos datos de contacto (NAP) en la web, LinkedIn y directorios como Clutch o Elioplus.
- [ ] **T5.** Ampliar servicios y casos a 700–1,000 palabras: proceso, tecnologías y FAQ con schema `FAQPage`.
- [ ] **T6.** Slugs traducidos en EN/IT (`/en/services/custom-software`, `/it/servizi/software-su-misura`) con 301 desde los actuales.
- [ ] **T7.** Velocidad del hosting: revisar la microcaché con Webempresa o poner Cloudflare delante del sitio estático.
- [ ] **T8.** Reducir las fuentes a 2 familias y precargar la fuente del H1.

## Verificación
- Después de cada despliegue: `curl` a `/robots.txt`, `/sitemap.xml`, `/favicon.ico` y una URL inexistente, que debe dar 404. Revisar en el HTML de cada página el canonical, los alternates, `og:*` y el JSON-LD.
- Validar con [Rich Results Test](https://search.google.com/test/rich-results) y con la inspección de URL de Search Console.
- PageSpeed Insights móvil del home cuando haya cuota: LCP menor a 2.5 s.
