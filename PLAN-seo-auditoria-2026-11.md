# Plan SEO — auditoría del 13 de noviembre de 2026

**Origen:** `documentacion/auditoria-seo-rtres.net-2026-11-13.md` (72/100).

Contexto: complementa `PLAN-seo.md` (12-oct, ya ejecutado en su mayor parte). Puntos de la auditoría 2026-11-13 sobre `https://rtres.net/es/`. Hosting: Apache con `scripts/deploy/site.htaccess` (SSL termina en Nginx del hosting).

### Fallos
1. **Cabeceras de seguridad (0/4)** — `site.htaccess`, bloque `mod_headers`:
   `Strict-Transport-Security: max-age=31536000; includeSubDomains`, `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin`. CSP primero como `Content-Security-Policy-Report-Only` (permitir googletagmanager/google-analytics, youtube-nocookie, script inline de gtag en `index.html`, API), y pasar a enforce tras 1-2 semanas sin violaciones.
2. **Imágenes sin width/height** — `site-header.component.ts:18` y `site-footer.component.ts:16` (`logo-rtres.png`): añadir `width`/`height` con las dimensiones reales del PNG (CSS mantiene el tamaño visual).
3. **LCP móvil 4.15 s** — medir con PageSpeed qué elemento es el LCP (probablemente H1 del hero o `hero-dashboard.webp` como background). Acciones: `<link rel="preload" as="image" fetchpriority="high">` de la imagen del hero si es LCP (o pasarla a `<img fetchpriority="high">` con srcset móvil); revisar carga de fuentes (`font-display: swap`, preload de la fuente del H1); retrasar gtag (ver 4).
4. **JS sin usar (119 KiB)** — gtag 177 KiB: cargarlo solo tras aceptar cookies (ya hay Consent Mode y `CookieConsentService`) o tras `requestIdleCallback`/primera interacción. `main-*.js` 46 KiB: lazy-load de rutas (`loadComponent`) en `site.routes.ts` para páginas que no son home.

### Mejorables
5. **Redirección raíz** — `site.htaccess`: `RewriteRule ^$ https://rtres.net/es/ [L,R=302]` → 301; enlaces internos/externos siempre a `/es/`.
6. **Páginas legales + datos de empresa** — nuevas rutas en `site.routes.ts` con slugs por idioma en `core/site-paths.ts` (`/es/privacidad`, `/en/privacy`, `/it/privacy`; `/es/aviso-legal`, `/en/legal-notice`, `/it/note-legali`), componentes en `pages/legal/`, textos con `$localize` + targets en `messages.{en,it}.xlf`. Enlazar en el footer junto a "Cookies", con razón social, RUC y dirección visibles. Añadir slugs a la tabla de redirecciones del htaccess si aplica. **El usuario redacta/valida el texto legal y aporta RUC y dirección.**
7. **"Sobre nosotros" no detectado** — el footer enlaza "Nosotros"; cambiar el texto a "Sobre nosotros" (o `title`) en es, y equivalente en en/it.
8. **Preconnect a googletagmanager** — `<link rel="preconnect" href="https://www.googletagmanager.com">` en `index.html` (si gtag sigue cargándose al inicio).
9. **Enlace "Saltar al contenido"** — primer elemento del layout del site: `<a class="skip-link" href="#main">`, visible al foco; `id="main"` en `<main>`.
10. **Schema** — en `seo.service.ts`: añadir `WebSite` con `@id` al grafo de identidad; `about`/`mentions` en páginas de servicio. BreadcrumbList en home: no aplica (se deja). Reseñas: **no** añadir `AggregateRating` sobre la propia Organization (Google no muestra estrellas en reseñas autoatribuidas); se descarta con nota.
11. **llms.txt** — generarlo en `scripts/deploy/seo-files.mjs` junto a robots/sitemap: descripción de Rtres, servicios y casos con sus URLs por idioma.
12. **Bytespider/CCBot sin respuesta** — comprobar en logs del hosting si es rate-limit del WAF; decisión consciente (permitir o bloquear en robots.txt). Sin cambio de código salvo decisión.
13. **Legibilidad (56.9)** y **WebMCP**: sin acción (la propia auditoría los califica como no problemáticos / emergentes).

### Orden
PR 1: 1, 2, 5, 8, 9 (rápidos). PR 2: 3, 4 (rendimiento, medir antes/después). PR 3: 6, 7 (legales + i18n). PR 4: 10, 11. Punto 12: operativo.

### Verificación
- `bash factory/checks.sh`; revisar en `src/web/dist/site/browser/{es,en,it}/` el HTML prerenderizado: width/height del logo, skip-link, JSON-LD (`WebSite`, `about`), enlaces legales, `llms.txt` en la raíz.
- `npx ng extract-i18n site --output-path projects/site/src/locale` sin mensajes sin traducir.
- Tras deploy manual: `curl -sI https://rtres.net/` (301) y `curl -sI https://rtres.net/es/` (cabeceras de seguridad); PageSpeed Insights móvil (LCP y JS sin usar); Rich Results Test; volver a pasar la herramienta de auditoría y comparar con 72/100.
