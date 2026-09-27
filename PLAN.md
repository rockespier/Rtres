# Plan: Sitio web + Portal de clientes Rtres Web Solutions

## Contexto

Rtres necesita (1) un sitio corporativo trilingüe (ES/EN/IT) moderno para captar clientes, y (2) un portal donde los clientes actuales gestionen sus productos contratados (hosting, dominio, SSL, backup, soporte), paguen suscripciones vía PayPal, y registren tickets de soporte/cambio que se sincronizan automáticamente con GitHub Issues del repo del proyecto correspondiente.

**Fase 0 (mockups HTML) está completa y el diseño fue aprobado por el cliente** (`mockups/index.html` + `mockups/portal/*.html`, documentado en `DESIGN.md`/`PRODUCT.md`). Este plan detalla la **Fase 1: puesta en marcha del código real** (Angular + .NET) con el nivel de detalle necesario para delegar tareas concretas — nombres de componentes, comandos exactos, entidades con sus campos, endpoints. Las Fases 2-6 (WordPress, PayPal, GitHub, notificaciones) se mantienen como estaban planeadas y se detallan más cuando llegue su turno.

Decisiones ya confirmadas (no volver a preguntar): pasarela **PayPal**, **un repo de GitHub por producto/proyecto**, token/App de GitHub a **nivel de organización Rtres**.

## Dominios e infraestructura

3 dominios registrados y vacíos: `rtres.net`, `r3solucionesweb.com`, `soluzionipersitiweb.it`.

- **`rtres.net`**: dominio único del sitio público, rutas `/es`, `/en`, `/it`.
- `r3solucionesweb.com` → 301 a `rtres.net/es`. `soluzionipersitiweb.it` → 301 a `rtres.net/it`.
- **WordPress** headless en `cms.rtres.net` (instancia única, Polylang ES/EN/IT), consumido server-side por el BFF .NET.
- **Portal** en `portal.rtres.net`, mismo backend .NET, app Angular separada (ver decisión de arquitectura abajo).

## Stack y arquitectura

- **Frontend**: Angular 18+ standalone, **dos aplicaciones separadas en un mismo workspace** (ver justificación abajo), Tailwind CSS.
- **Backend**: .NET 10 Web API como **BFF único** para ambas apps Angular — Angular nunca llama a WordPress/PayPal/GitHub directamente.
- **CMS**: WordPress headless (solo contenido editorial). Plugin **Polylang** ES/EN/IT.
- **DB portal**: SQL Server + EF Core (cambiado de PostgreSQL el 2026-09-25 — el usuario ya tiene SQL Server instalado localmente).
- **Jobs**: Hangfire (recordatorios de vencimiento, sync GitHub, emails).
- **Auth portal**: JWT, roles `Cliente` / `Admin` (admin del equipo de un cliente, ve solo su propio cliente) / **`SuperAdmin`** (staff de Rtres, ve y actúa sobre todos los clientes — ver "Rol SuperAdmin" más abajo).

### Decisión de arquitectura: dos apps Angular, no una

Los mockups confirman que el sitio público y el portal son **dos sistemas visuales y funcionales genuinamente distintos** (paleta, tipografía de componentes, registro de diseño, necesidad de SSR/SEO) con **cero componentes compartidos** en la práctica (el catálogo de los mockups no encontró superposición real entre `styles.css`/`portal.css`). Forzarlos en una sola app Angular con un solo `styles.css` global mezclaría dos design systems y complicaría el build SSR (el portal no necesita SSR, el sitio sí). Se recomienda:

- Un **workspace Angular** (`src/web/`) con **dos proyectos**: `site` (SSR, público, `rtres.net`) y `portal` (SPA CSR, autenticado, `portal.rtres.net`).
- Cada proyecto tiene sus propios estilos globales (migrados casi 1:1 desde `mockups/assets/styles.css` y `mockups/assets/portal.css` respectivamente — ver sección de tokens).
- Ambos consumen la misma `Rtres.Api` (.NET) pero desde `environments` distintos si hace falta.
- Deploy independiente por subdominio (dos builds, dos artefactos).

## Repo layout (comandos exactos)

```bash
# Desde la raíz del repo (C:\repo\rtres-net\Rtres)

# --- Angular workspace con 2 apps ---
npx -p @angular/cli@18 ng new web --directory=src/web --create-application=false --routing=false --style=css --strict
cd src/web
ng generate application site --routing --style=css --ssr
ng generate application portal --routing --style=css
cd ../..

# --- Tailwind en cada app ---
cd src/web/projects/site && npm install -D tailwindcss postcss autoprefixer && npx tailwindcss init && cd ../../../..
cd src/web/projects/portal && npm install -D tailwindcss postcss autoprefixer && npx tailwindcss init && cd ../../../..

# --- .NET ---
mkdir -p src/api && cd src/api
dotnet new sln -n Rtres
dotnet new webapi -n Rtres.Api -controllers
dotnet new classlib -n Rtres.Domain
dotnet new classlib -n Rtres.Infrastructure
dotnet new xunit -n Rtres.Api.Tests
dotnet sln add Rtres.Api Rtres.Domain Rtres.Infrastructure Rtres.Api.Tests
dotnet add Rtres.Api reference Rtres.Domain Rtres.Infrastructure
dotnet add Rtres.Infrastructure reference Rtres.Domain
dotnet add Rtres.Api.Tests reference Rtres.Api
cd ../..
```

Resultado:

```
Rtres/
  Documentacion/            (existente)
  inspiracion/               (existente, referencia de diseño)
  mockups/                   (existente, Fase 0 — mantener como referencia visual, no borrar)
  PLAN.md  DESIGN.md  PRODUCT.md
  src/
    web/
      projects/
        site/                 Angular SSR — rtres.net
        portal/                Angular SPA — portal.rtres.net
    api/
      Rtres.Api/               Controllers, Program.cs, webhooks PayPal/GitHub
      Rtres.Domain/             Entidades, enums, interfaces de repositorio
      Rtres.Infrastructure/     EF Core (DbContext, migrations), clientes WP/PayPal/GitHub (Octokit)
      Rtres.Api.Tests/
```

Agregar `.gitignore` (Node + .NET: `node_modules/`, `dist/`, `.angular/`, `bin/`, `obj/`, `.env`, `appsettings.*.local.json`) como primera tarea — el repo tiene un solo commit placeholder (`README.md`) y todavía no ignora nada.

## Migración de design tokens (mockups → Angular) — mapeo de archivos

No rediseñar nada: portar el CSS que ya existe y fue aprobado, casi literal.

| Origen (mockup) | Destino |
|---|---|
| `mockups/assets/styles.css` (:root, `.on-dark`, `.glass`, `.btn*`, `.badge`, `.huge*`, `.sunburst`, `.photo-duotone`, `.num-row`, `.float-card`, `.proj-*`, `.marquee*`, `.acc-*`) | `src/web/projects/site/src/styles.css` (global styles del proyecto `site`) |
| `mockups/assets/portal.css` (:root claro + `html[data-theme="dark"]`, `.card*`, `.btn*`, `.pill-*`, `.side-*`, `.search-field`, `.field*`, `.p-table*`, `.pagination-btn`, `.switch*`, `.avatar`, `.text-accent`, `.text-warn`) | `src/web/projects/portal/src/styles.css` |
| `tailwind.config` inline de `index.html` (colores `bg/surface/primary.DEFAULT-strong-dim/green/accent/accent2/warning/ink/muted`, fonts) | `src/web/projects/site/tailwind.config.js` |
| Colores inline de `portal/*.html` (`primary.DEFAULT-strong-soft/ink/muted`) | `src/web/projects/portal/tailwind.config.js` |
| Google Fonts (Inter 400-800, Space Grotesk 500-700, Instrument Serif italic) | `<link>` en el `index.html` de **ambos** proyectos (portal solo usa Inter + Space Grotesk, sin Instrument Serif — confirmar si se quiere igual) |
| `mockups/assets/logo.png` | `src/web/projects/site/src/assets/logo.png` y `src/web/projects/portal/src/assets/logo.png` |

**Nota de limpieza detectada al catalogar el mockup** (resolver al portar, no bloquea el arranque):
- Las dos hojas de estilo tienen **paletas parcialmente duplicadas con nombres distintos** (`--accent-2` en CSS vars vs `accent2` en Tailwind config) — al portar, unificar en un solo archivo de tokens por app en vez de mantener dos fuentes de verdad.
- `.mask-fade` se usa en `index.html` (marquee del hero) pero **no está definida en `styles.css`** — decidir si se define (fade en los bordes del marquee) o se quita la clase del template.
- `.noise`, `.bento`, `.bento-glow` están definidas en `styles.css` pero **no se usan** en el `index.html` actual — no portar salvo que se reactiven.
- `.huge` (solo contorno, sin relleno) ya no se usa standalone — todo el sitio usa `.huge-fill` (ver conversación de diseño). Portar igual por si se reintroduce.

## Contenido pendiente de decidir antes/durante el port de i18n

El catálogo del mockup encontró 5 keys de `i18n.js` que existen en el diccionario pero **no se usan en ningún `data-i18n` del HTML** (huérfanas): `features.eyebrow`, `cta.title`, `faq.eyebrow`, `reviews.eyebrow`, `footer.col4.title`. Decisión por defecto: **no portarlas** al esquema de i18n de Angular (dead content) salvo que se quiera restaurar el eyebrow en esas secciones o una 4ª columna en el footer — avisar si se prefiere lo segundo.

También hay contenido que **no pasa por `data-i18n`** hoy y quedaría igual en Angular salvo que se decida lo contrario:
- Email/teléfono de contacto (duplicados en top bar y footer, español-neutral, no traducidos) → mantener como constantes, no i18n.
- Nombres de clientes en los marquees (hero y reviews) y en la grilla de Proyectos, y sus categorías de imagen (`alt`) → nombres de clientes se mantienen tal cual (son reales); el `alt` actualmente dice siempre "Proyecto — {name}" en español fijo — **corregir para que el `alt` sí se traduzca** (bug menor detectado).
- El link "Preview del portal →" en la fila 6 de Características está **hardcodeado en español, sin `data-i18n`** (inconsistente con el resto de la fila) — agregar la key `feat.6.cta` en las 3 lenguas al portar.
- Las imágenes son placeholders de `picsum.photos` (hero: id 48; proyectos: ids 60/96/119/180/250/342) — reemplazar por assets reales de Rtres cuando estén disponibles; mientras tanto portar las mismas URLs para no bloquear.

## Inventario de componentes — app `site` (público)

Cada fila = un componente Angular standalone. "Contenido" indica si viene de i18n (build-time, `@angular/localize`) o de WordPress vía BFF (Fase 2) — para Fase 1 todo el contenido de WP se **mockea con el mismo JSON que hoy vive en `i18n.js`**, para no bloquear el arranque en WP.

| Componente | Selector sugerido | Contenido | Notas de migración |
|---|---|---|---|
| `TopBarComponent` | `app-top-bar` | i18n (`nav.login`) + constantes (email/tel) | `hidden sm:block`, no sticky |
| `SiteHeaderComponent` | `app-site-header` | i18n (`nav.*`) | Sticky + `.glass`/`.glass-strong` según scroll (HostListener en window:scroll); logo 80px; contiene `MobileMenuComponent` |
| `MobileMenuComponent` | `app-mobile-menu` | mismos items de nav | Recibe la lista de nav vía `@Input()` desde `SiteHeaderComponent` — **no duplicar el array de links**, a diferencia del mockup que repite el HTML dos veces |
| `LangSwitcherComponent` | `app-lang-switcher` | — | Usado dentro de TopBar y MobileMenu; con Angular i18n build-time, cambiar de idioma = navegar a `/en/...` etc, no swap de texto en runtime |
| `HeroComponent` | `app-hero` | i18n `hero.*` (11 keys) + mock WP: foto, stat card | Reproduce `.huge.huge-fill`, `.sunburst`, `.photo-duotone`, `.float-card`; trust marquee con `MarqueeComponent` |
| `MarqueeComponent` | `app-marquee` | `@Input() items: string[]` | Reemplaza el truco `innerHTML += innerHTML` del mockup por `*ngFor` sobre `[...items, ...items]` |
| `FeaturesComponent` | `app-features` | i18n `features.*` + `feat.1-6.*` | Lista de 6 `NumRowComponent` |
| `NumRowComponent` | `app-num-row` | `@Input() index, title, description, ctaLabel?` | Reutilizado también por FAQ (con `open`/toggle en vez de cta) |
| `ProjectsComponent` | `app-projects` | i18n `projects.*` + `proj.1-6.cat` + mock WP: 6 proyectos (nombre, foto, categoría) | Grilla de `ProjectCardComponent` |
| `ProjectCardComponent` | `app-project-card` | `@Input() name, category, imageUrl, href` | Hover overlay `.proj-overlay`/`.proj-pill` vía CSS `:hover`, no JS |
| `PricingComponent` | `app-pricing` | i18n `pricing.*`, `plan.1-3.*`, `addons.*`, `addon.1-5` | **Los precios son hoy strings i18n opacos** (`plan.1.price`="$390" en las 3 lenguas) — para Fase 1 mantener igual; si más adelante se necesita lógica de moneda/checkout dinámico, migrar a `{amount:number, currency:string}` + formateo con `Intl.NumberFormat` |
| `CtaBandComponent` | `app-cta-band` | i18n `cta.giant/sub/button` | Sección `.on-dark` — ver `OnDarkSectionComponent` |
| `OnDarkSectionComponent` (wrapper) | `app-on-dark-section` | `<ng-content>` | Encapsula el mecanismo de inversión de tema (host con `class="on-dark"`) usado por CTA band y Reviews — evita repetir la lógica de scoping de variables CSS en dos sitios |
| `FaqComponent` | `app-faq` | i18n `faq.title` + `faq.1-5.q/a` | 5 `AccordionItemComponent`; **decidir** si se mantiene `<details>` nativo (más simple, cada item independiente) o se controla el estado para exclusividad (solo uno abierto a la vez) — el mockup actual permite varios abiertos simultáneamente, mantener ese comportamiento por defecto |
| `AccordionItemComponent` | `app-accordion-item` | `@Input() index, question, answer, openByDefault` | — |
| `ReviewsComponent` | `app-reviews` (dentro de `OnDarkSectionComponent`) | i18n `reviews.*`, `review.1-3.*`, `clients.label` + mock WP: rating | Panel destacado + 2 quotes planas + `MarqueeComponent` de clientes |
| `FooterComponent` | `app-footer` | i18n `footer.*` | 3 columnas de links + tagline + contacto |

**Routing** (`site`): `/:{lang}` con `lang` en `es|en|it`, o usar los i18n locales de Angular (`ng build --localize`) generando `/es/`, `/en/`, `/it/` como carpetas separadas servidas por subruta — preferido para SSR + hreflang. Página única (todas las secciones son anclas `#inicio` `#features` `#projects` `#pricing` `#faq` `#reviews` `#contact` de una sola ruta, como hoy).

## Inventario de componentes — app `portal`

| Componente | Selector sugerido | Notas |
|---|---|---|
| `PortalShellComponent` | `app-portal-shell` | Layout con `<router-outlet>`; contiene sidebar + topbar + drawer móvil. Todas las páginas autenticadas lo usan vía ruta padre. |
| `SidebarComponent` | `app-sidebar` | Search field (decorativo por ahora), nav (`Mis productos`, `Tickets` con badge de conteo, grupo "Cuenta": `Facturación`/`Perfil` — **stubs sin página real todavía**, dejar rutas que rendericen un placeholder "Próximamente"), toggle de tema, help card, chip de usuario |
| `TopbarComponent` | `app-topbar` | Breadcrumb + acciones a la derecha vía `@Input()`/`ng-content` (difiere por página: dashboard tiene campana+CTA+avatar, tickets solo CTA, ticket-new tiene Cancelar+Enviar) |
| `ThemeToggleComponent` | `app-theme-toggle` | Switch reutilizable; usa `ThemeService` (ver abajo) |
| `ThemeService` (servicio, no componente) | — | Puerto directo de `portal.js`: `localStorage` key `rtres_portal_theme`, aplica `document.documentElement.dataset.theme` **antes del primer render** — en Angular SPA esto se resuelve con un script inline mínimo en `portal/src/index.html` (mismo mecanismo que hoy, Angular no puede evitar el FOUC solo con un servicio que arranca después del bootstrap) |
| `LoginComponent` | `app-login` (ruta pública) | Reactive form: `email` (`Validators.required, Validators.email`), `password` (`Validators.required`), `rememberMe`. Submit real: `POST /api/auth/login` → guardar JWT → redirigir a `/dashboard`. Mostrar error si credenciales inválidas (estado que el mockup no tiene) |
| `DashboardComponent` | `app-dashboard` | 4 stat cards (`StatCardComponent` × 4) + grilla de `ProductCardComponent`. Fase 1: consumir `GET /api/dashboard/summary` y `GET /api/client-products` (ver contrato de API) |
| `StatCardComponent` | `app-stat-card` | `@Input() label, value, variant?: 'default'|'warn'|'accent'` |
| `ProductCardComponent` | `app-product-card` | `@Input() product: ClientProductDto` — debe soportar los 3 tipos de fecha encontrados en el mockup (`renewsAt`, `nextChargeAt`, `lastBackupAt`) y CTA opcional (el card de Backup no tiene botón) |
| `TicketsListComponent` | `app-tickets-list` (ruta `/tickets`) | Toolbar (search + 2 filtros + botón "Filtrar", todos **decorativos en Fase 1** — implementar filtrado real es Fase 5) + `TicketTableComponent` + paginación |
| `TicketTableComponent` | `app-ticket-table` | Columnas: Ticket(+id), Tipo, Proyecto, GitHub(issue link), Estado(pill), Actualizado — mismas responsive `hidden sm/md/lg:table-cell` que el mockup |
| `StatusPillComponent` | `app-status-pill` | `@Input() status: TicketStatus` → mapea a variante de pill (`pill-success/warn/info/neutral/danger`) — ver enum abajo |
| `TicketFormComponent` | `app-ticket-form` (ruta `/tickets/new`) | Reactive form con **todos** los campos listados en la sección de modelo de datos; `type` (`soporte`\|`cambio`) como `FormControl` que controla visibilidad de "Impacto/alcance estimado" vía `*ngIf` y alimenta un `computed()`/`Signal` para el panel de preview en vivo (reemplaza `syncPreview()`/`setType()` del mockup) |
| `TicketPreviewCardComponent` | `app-ticket-preview-card` | `@Input() formValue` (o recibe el signal directamente) — puramente presentacional |
| `FileDropzoneComponent` | `app-file-dropzone` | El mockup solo tiene el div decorativo ("Arrastra capturas...") sin `<input type=file>` real — implementar input real + preview de archivos adjuntos + subida a `POST /api/tickets/{id}/attachments` (multipart) |

**Nota**: el mockup no implementa el toggle del menú móvil (`data-menu-btn`/`data-mobile-menu`) con JS real en el portal — en Angular, `PortalShellComponent` debe manejarlo con un simple `signal<boolean>` propio, no hace falta portar nada porque no existía lógica que portar.

## Modelo de datos (EF Core — `Rtres.Domain`)

Ampliando el modelo core con los campos exactos que exige el mockup:

```csharp
public class Client {
    public Guid Id; public string CompanyName; public string ContactName;
    public string Email; public string? Phone; public string PreferredLanguage; // es|en|it
    public DateTime CreatedAt;
}

public class UserAccount {
    public Guid Id; public Guid? ClientId; public string Email; public string PasswordHash;
    public UserRole Role; // Cliente, Admin (admin del equipo de un cliente), SuperAdmin (staff Rtres)
    public bool IsActive;
    // ClientId es NULL solo para SuperAdmin — no pertenece a ningún cliente, ve todos.
}

public class Project { // = "cabalgatas-andinas-web" en el mockup
    public Guid Id; public Guid ClientId; public string Name; public string Slug;
    public string GithubRepoOwner; public string GithubRepoName;
}

public enum ProductType { Hosting, Dominio, Ssl, BackupBd, SoporteMensual, DesarrolloWeb }
public enum BillingCycle { Unico, Mensual, Anual }

public class Product {
    public Guid Id; public ProductType Type; public string Name;
    public BillingCycle BillingCycle; public decimal? BasePrice; public string Currency; // USD
}

public enum ClientProductStatus { Activo, PorVencer, Vencido, Cancelado }

public class ClientProduct { // = cada card del dashboard
    public Guid Id; public Guid ClientId; public Guid ProjectId; public Guid ProductId;
    public ClientProductStatus Status;
    public DateTime? RenewsAt;       // Hosting, SSL: "Renueva el 14 oct 2026"
    public DateTime? NextChargeAt;   // Soporte mensual: "Próximo cobro: 1 oct 2026"
    public DateTime? LastBackupAt;   // Backup BD: "Último backup: hoy, 03:00 a.m."
    public decimal? Price; public string? PriceLabelOverride; // ej. "Incluido en plan"
    public string? PayPalSubscriptionId; public string? PayPalPlanId;
    public string? DomainName; // solo para Dominio, ej. "cabalgatasandinas.com"
}

public enum TicketType { Soporte, Cambio }
public enum TicketStatus { Abierto, EnProgreso, Resuelto, Publicado, Cerrado } // Cerrado reservado (pill-danger sin uso aún en mockup)

public class Ticket {
    public Guid Id; public string Code; // "RT-108"
    public Guid ClientId; public Guid ProjectId; public Guid CreatedByUserId;
    public TicketType Type; public TicketStatus Status;
    public string Title; public string Description;
    public string? CurrentBehavior; public string? ExpectedBehavior; // solo aplican como "*" en ambos tipos, no solo Cambio
    public string? StepsToReproduce; public string? Environment;
    public string? AcceptanceCriteria;
    public string? EstimatedImpact; // solo Cambio — "change-only" en el mockup
    public int? GithubIssueNumber; public string? GithubIssueUrl;
    public DateTime CreatedAt; public DateTime UpdatedAt;
}

public class TicketAttachment {
    public Guid Id; public Guid TicketId; public string FileName; public string Url; public long SizeBytes;
}

public class TicketComment {
    public Guid Id; public Guid TicketId; public Guid? AuthorUserId; public string Body;
    public bool FromGithub; public DateTime CreatedAt;
}

public class PaymentTransaction {
    public Guid Id; public Guid ClientProductId; public string PayPalOrderIdOrSubscriptionId;
    public decimal Amount; public string Currency; public string Status; public DateTime CreatedAt;
}

public class NotificationLog {
    public Guid Id; public Guid ClientId; public string Type; // RenewalReminder, TicketStatusChange
    public string Channel; public DateTime SentAt; public bool Success;
}
```

## Contrato de API — Fase 1 (lo mínimo para que el portal deje de usar datos falsos)

Todos bajo `/api`, JWT Bearer salvo `/auth/login`. Devuelven DTOs (no las entidades EF directamente).

| Método | Ruta | Uso | Body/Query | Respuesta |
|---|---|---|---|---|
| POST | `/auth/login` | `LoginComponent` | `{ email, password }` | `{ token, user: { name, initials, clientName } }` |
| GET | `/dashboard/summary` | `DashboardComponent` stat cards | — | `{ activeProducts, expiringSoon, openTickets, nextPaymentAmount }` |
| GET | `/client-products` | `DashboardComponent` grilla | — | `ClientProductDto[]` (con `product.type`, `status`, fechas, precio, proyecto) |
| GET | `/tickets` | `TicketsListComponent` | `?status=&type=&page=` (filtros reales llegan en Fase 5, pero el endpoint ya pagina desde Fase 1) | `{ items: TicketDto[], page, totalPages }` |
| GET | `/tickets/{id}` | detalle de ticket (página nueva, no existe en el mockup — agregar ruta `/tickets/:id` cuando se construya) | — | `TicketDto` + `comments[]` |
| POST | `/tickets` | `TicketFormComponent` submit | todos los campos del form + `projectId` + `type` | `TicketDto` (id, code) — dispara creación de issue en GitHub de forma asíncrona (Fase 5) |
| POST | `/tickets/{id}/attachments` | `FileDropzoneComponent` | multipart/form-data | `TicketAttachmentDto` |
| GET | `/projects` | poblar el `<select>` de Proyecto en `TicketFormComponent` (el mockup solo tiene 1 opción hardcodeada) | — | `ProjectDto[]` |

Fuera de Fase 1 (documentar pero no implementar todavía): `/paypal/*` (Fase 4), `/webhooks/github` (Fase 5), `/webhooks/paypal` (Fase 4), endpoints de contenido WP (Fase 2), `Facturación`/`Perfil` (stubs en el sidebar hoy sin página).

## Checklist de tareas — Fase 1 (delegable, en orden)

- [x] **T1.0** — `.gitignore`, primer `git add`/commit del estado actual (mockups + docs) antes de empezar a generar código nuevo.
- [x] **T1.1** — Workspace Angular con las 2 apps (`site`, `portal`) + Tailwind en cada una. *Criterio: `ng serve site` y `ng serve portal` levantan una página en blanco sin errores.*
- [x] **T1.2** — Portar tokens/CSS globales según la tabla de migración (`styles.css`→`site`, `portal.css`→`portal`, configs de Tailwind, fuentes, logo). *Criterio: abrir `ng serve site` y `ng serve portal` muestra el fondo/tipografía correctos aunque la página esté vacía.*
- [x] **T1.3** — `.NET` solution con las 4 proyectos + referencias. *Criterio: `dotnet build` sin errores.* ✅
- [x] **T1.4** — Entidades de `Rtres.Domain` (modelo de arriba) + `RtresDbContext` en `Rtres.Infrastructure` + primera migración EF Core contra SQL Server local. *Criterio: `dotnet ef database update` crea el schema.* ✅ Verificado contra `localhost\SQLEXPRESS`.
- [x] **T1.5** — `site`: `TopBarComponent`, `SiteHeaderComponent`, `MobileMenuComponent`, `LangSwitcherComponent`, `FooterComponent` + shell de rutas `/es /en /it`. *Criterio: header/footer se ven igual que el mockup en las 3 rutas.*
- [x] **T1.6** — `site`: `HeroComponent`, `MarqueeComponent`, `FeaturesComponent`/`NumRowComponent`, `ProjectsComponent`/`ProjectCardComponent` con datos mock calcados de `i18n.js`. *Criterio: comparación visual 1:1 contra `mockups/index.html` hasta la sección Proyectos.*
- [x] **T1.7** — `site`: `PricingComponent`, `OnDarkSectionComponent` + `CtaBandComponent`, `FaqComponent`/`AccordionItemComponent`, `ReviewsComponent`. *Criterio: página completa visualmente idéntica al mockup, incluyendo las dos islas oscuras.*
- [x] **T1.8** — i18n build-time: resolver las 5 keys huérfanas (decidir restaurar o borrar), agregar la key faltante del link "Preview del portal", corregir el `alt` de las fotos de proyecto para que sí se traduzca; generar builds `/es /en /it` con `ng build --localize`. *Criterio: `ng build site --localize` genera 3 carpetas de salida sin warnings de i18n.* ✅ 60 mensajes extraídos y traducidos (EN/IT), verificado en runtime.
- [x] **T1.9** — `portal`: `PortalShellComponent`, `SidebarComponent`, `TopbarComponent`, `ThemeToggleComponent` + `ThemeService` (con el script anti-FOUC en `index.html`). *Criterio: toggle de modo oscuro persiste entre recargas, igual que el mockup.*
- [x] **T1.10** — `portal`: `LoginComponent` con formulario reactivo real. *Criterio: validaciones de email/password funcionan, error visible si se deja vacío.* ✅ Conectado a `/api/auth/login` real.
- [x] **T1.11** — `portal`: `DashboardComponent`, `StatCardComponent`, `ProductCardComponent`. *Criterio: visualmente idéntico a `dashboard.html`.* ✅ Datos reales desde la API.
- [x] **T1.12** — `portal`: `TicketsListComponent`, `TicketTableComponent`, `StatusPillComponent`. *Criterio: visualmente idéntico a `tickets.html`, incluyendo los 4 valores de estado distintos.* ✅ Datos reales desde la API.
- [x] **T1.13** — `portal`: `TicketFormComponent` (reactive form completo, los 11 campos listados), `TicketPreviewCardComponent`, `FileDropzoneComponent` (input real). *Criterio: alternar Soporte/Cambio muestra/oculta "Impacto" y el preview se actualiza en vivo, igual que `syncPreview()` en el mockup.* ✅ Bug del preview congelado corregido (`toSignal` sobre `valueChanges`); submit crea tickets reales.
- [x] **T1.14** — `Rtres.Api`: controllers + DTOs para los 8 endpoints del contrato de Fase 1, con datos desde SQL Server (seed manual del cliente/proyecto "Cabalgatas Andinas" para probar). Auth con JWT. CORS habilitado para los dos orígenes de Angular en dev. *Criterio: Swagger muestra los 8 endpoints y responden 200 con el seed de datos.* ✅ Verificado con `curl` end-to-end (login, dashboard/summary, client-products, projects, POST tickets).
- [x] **T1.15** — Conectar `portal` a la API real: reemplazar todos los mocks de T1.10-T1.13 por `HttpClient` + interceptor de JWT + guard de ruta. *Criterio: login real, dashboard y tickets muestran datos que vienen de SQL Server, no hardcodeados.* ✅ `AuthService`/`authInterceptor`/`authGuard`/`PortalApiService` implementados.

Las tareas T1.5–T1.8 (sitio) y T1.9–T1.13 (portal) son independientes entre sí y pueden delegarse/paralelizarse a dos personas o dos sesiones distintas una vez completadas T1.1–T1.4.

## Fases siguientes (sin detallar todavía, se profundizan cuando toquen)

2. **Sitio público conectado a WordPress**: ✅ implementado y verificado 2026-09-25 (ver "Estado de la Fase 2" abajo). Pendiente dentro de esta fase: redirects 301 desde los otros 2 dominios, hreflang, Lighthouse SEO.
3. **Portal — roles y alta de clientes**: pantallas de `Facturación`/`Perfil` (hoy stubs), gestión de usuarios por Admin, y el **rol SuperAdmin** (ver sección dedicada abajo).
4. **Suscripciones PayPal**: detallada abajo en "Fase 4 — detalle (suscripciones y facturación PayPal)".
5. **Tickets ↔ GitHub**: detallada abajo en "Fase 5 — detalle (tickets: tipos, comentarios, GitHub)".
6. **Notificaciones**: detallada abajo en "Fase 6 — detalle (notificaciones por email)".
7. **Contabilidad Perú**: detallada abajo en "Fase 7 — detalle (contabilidad Perú: multi-moneda, documentos tributarios, IGV/Renta, gastos)".

## Fase 3 — detalle (roles, Facturación, Perfil, gestión de equipo, SuperAdmin)

### Contexto y alcance

Hoy el portal tiene exactamente **un** usuario por cliente (el seed de "Cabalgatas Andinas"), sin forma de invitar más gente, sin página de Facturación ni Perfil reales (son `PlaceholderComponent` con "Próximamente"), y sin ningún camino para que Rtres (no el cliente) vea más de una cuenta a la vez. Fase 3 cierra esas tres cosas. Decisiones de alcance (para no bloquear en dependencias de fases futuras):

- **Facturación**: de solo lectura — tabla del historial de `PaymentTransaction`. No hay botones de pago real todavía (eso es Fase 4/PayPal); si no hay transacciones, se muestra un estado vacío ("Aún no tienes pagos registrados").
- **Perfil**: el usuario edita su propio nombre y cambia su contraseña. El email queda de solo lectura (cambiarlo requeriría reverificación, fuera de alcance).
- **Gestión de equipo**: solo visible si `role === 'Admin'`. El Admin invita usuarios nuevos (quedan con rol `Cliente` por defecto), puede subir/bajar entre `Cliente`↔`Admin`, y activar/desactivar. Como Fase 6 (notificaciones/email) todavía no existe, al invitar se genera una contraseña temporal que se muestra **una sola vez** en pantalla para que el Admin la copie y se la pase a la persona manualmente (nada de email real todavía).
- **SuperAdmin**: como se documentó antes — mismo portal, selector de cliente en el topbar, sin app/subdominio separado.

### Modelo de datos — cambios sobre lo ya implementado

```csharp
public class UserAccount {
    public Guid Id; public Guid? ClientId; public string Email; public string PasswordHash;
    public string Name; // NUEVO — nombre propio del usuario (antes se usaba Client.ContactName para todos)
    public UserRole Role; // Cliente, Admin, SuperAdmin
    public bool IsActive;
}
```

Requiere una nueva migración EF Core (`AddUserAccountName` o similar). El seed (`DbSeeder.cs`) debe actualizarse para poblar `Name` en el usuario de prueba existente.

### Inventario de componentes — app `portal` (Fase 3)

| Componente | Selector | Ruta | Notas |
|---|---|---|---|
| `BillingComponent` | `app-billing` | `/billing` (reemplaza el `PlaceholderComponent` actual) | Tabla con fecha, producto, monto, estado de cada `PaymentTransaction` propio. Estado vacío si no hay filas. |
| `ProfileComponent` | `app-profile` | `/profile` (reemplaza el `PlaceholderComponent` actual) | Form reactivo: nombre (editable), email (readonly), y un form separado de cambio de contraseña (actual + nueva + confirmación). |
| `TeamComponent` | `app-team` | `/team` (nueva ruta, nuevo link "Equipo" en `SidebarComponent`, grupo Cuenta — visible solo si `role==='Admin'`) | Tabla de usuarios del propio cliente (nombre, email, rol, estado) + botón "Invitar" que abre `TeamInviteDialogComponent`. Acciones por fila: cambiar rol, activar/desactivar. |
| `TeamInviteDialogComponent` | `app-team-invite-dialog` | — | Form (nombre + email) → `POST /api/team/users` → muestra la contraseña temporal generada una sola vez, con botón "Copiar". |
| `ClientSwitcherComponent` | `app-client-switcher` | — (vive dentro de `TopbarComponent`, visible solo si `role==='SuperAdmin'`) | Dropdown/typeahead con los clientes de `GET /api/admin/clients`; al elegir uno, setea `PortalUiService.viewingClientId` y fuerza recarga de la página actual (dashboard/tickets/etc). |
| `AdminClientsComponent` | `app-admin-clients` | `/admin/clients` (nueva ruta, solo `role==='SuperAdmin'`, accesible sin seleccionar cliente) | Listado agregado de todos los clientes con sus métricas básicas (productos activos, tickets abiertos) — la vista "sin cliente seleccionado" que reemplaza el dashboard normal para SuperAdmin. |

`SidebarComponent`/drawer móvil: agregar el link "Equipo" (condicional a `role==='Admin'`) y, para SuperAdmin, un link fijo "Todos los clientes" que navega a `/admin/clients`.

### Contrato de API — Fase 3

Todos bajo `/api`, JWT Bearer. Los de Facturación/Perfil/Equipo se scopean al `client_id` del JWT (o al `?clientId=` activo si es SuperAdmin, igual que el resto del contrato de Fase 1).

| Método | Ruta | Uso | Body/Query | Respuesta | Rol |
|---|---|---|---|---|---|
| GET | `/billing/transactions` | `BillingComponent` | — | `PaymentTransactionDto[]` | Cliente, Admin |
| GET | `/profile` | `ProfileComponent` | — | `{ name, email }` | Cliente, Admin |
| PATCH | `/profile` | `ProfileComponent` guardar nombre | `{ name }` | 200 | Cliente, Admin |
| POST | `/profile/change-password` | `ProfileComponent` form contraseña | `{ currentPassword, newPassword }` | 200 o 400 si `currentPassword` no coincide | Cliente, Admin |
| GET | `/team/users` | `TeamComponent` | — | `TeamUserDto[]` (id, name, email, role, isActive) | **Admin** |
| POST | `/team/users` | `TeamInviteDialogComponent` | `{ name, email }` | `{ id, temporaryPassword }` — la password solo viaja en esta respuesta, nunca se vuelve a exponer | **Admin** |
| PATCH | `/team/users/{id}` | Cambiar rol / activar-desactivar | `{ role?, isActive? }` | 200 | **Admin** (no puede modificarse a sí mismo a `Cliente` ni desactivarse) |
| GET | `/admin/clients` | `ClientSwitcherComponent`, `AdminClientsComponent` | — | `AdminClientSummaryDto[]` (id, companyName, activeProducts, openTickets) | **SuperAdmin** |

### Checklist de tareas — Fase 3 (delegable, en orden)

- [x] **T3.0** — Migración EF Core: `UserAccount.Name` (nuevo campo) + `UserAccount.ClientId` pasa a `Guid?`. Actualizar `DbSeeder` para poblar `Name` del usuario existente. *Criterio: `dotnet ef database update` aplica sin error, login sigue funcionando.* ✅ Aplicada contra SQL Server real (`ALTER TABLE ... ADD [Name]`), verificado con `SELECT`.
- [x] **T3.1** — Backend: `AuthController` incluye `Name` en la respuesta de login (reemplaza el uso de `Client.ContactName`); agregar rol `SuperAdmin` al enum `UserRole` y al claim JWT.
- [x] **T3.2** — Backend: endpoints de Perfil (`GET/PATCH /api/profile`, `POST /api/profile/change-password`) con `PasswordHasher` para verificar/actualizar el hash. ✅ Probado con `curl`: update de nombre y rechazo de contraseña actual incorrecta (400).
- [x] **T3.3** — Backend: endpoints de Facturación (`GET /api/billing/transactions`), devuelve `[]` si no hay filas. ✅ Verificado visualmente: estado vacío "Aún no tienes pagos registrados."
- [x] **T3.4** — Backend: endpoints de Equipo (`GET/POST /api/team/users`, `PATCH /api/team/users/{id}`), todos `[Authorize(Roles="Admin")]` y scopeados al `client_id` del JWT. Generar contraseña temporal aleatoria (no reversible, solo se devuelve una vez). ✅ Probado con `curl`: invitar usuario real, login del usuario invitado con la password temporal.
- [x] **T3.5** — Backend: `GET /api/admin/clients` + guard `?clientId=` en los endpoints existentes de `PortalController` para SuperAdmin. ✅ Probado con `curl`: sin `clientId` → 400; con `clientId` de cada uno de los 2 clientes de prueba → datos distintos y correctos por cliente.
- [x] **T3.6** — Frontend: `BillingComponent` + `ProfileComponent` reemplazan a `PlaceholderComponent` en `portal.routes.ts` para `/billing` y `/profile`.
- [x] **T3.7** — Frontend: `TeamComponent` + `TeamInviteDialogComponent`, ruta `/team`, link condicional en `SidebarComponent`/drawer móvil.
- [x] **T3.8** — Frontend: `ClientSwitcherComponent` en `TopbarComponent`, `AdminClientsComponent` en `/admin/clients`, `PortalUiService.viewingClientId`, `PortalApiService` agrega `?clientId=` cuando corresponde. Todo condicional a `role==='SuperAdmin'`. ✅ Verificado en navegador: SuperAdmin ve "Todos los clientes" → selecciona uno → topbar muestra "Viendo como: X" → dashboard con datos reales de ese cliente.
- [x] **T3.9** — Seed: segundo cliente de prueba ("Selva Viva") + usuario SuperAdmin (`admin@rtres.net` / `RtresAdmin2026!`).
- [x] **T3.10** — Verificación: `dotnet build`, `ng build site` y `ng build portal` sin errores; flujo completo probado de punta a punta (Admin invita → nuevo usuario hace login con la password temporal → Perfil actualiza nombre y rechaza contraseña incorrecta → SuperAdmin cambia entre los 2 clientes y ve datos reales distintos por cliente).

**Bugs reales encontrados y corregidos durante la verificación** (Codex implementó T3.0–T3.10 pero no pudo compilar/probar en su sandbox — igual que en Fases 1 y 2, todo se verificó y arregló manualmente):
- La migración `AddUserAccountName` tenía el archivo `.cs` pero le faltaba el `.Designer.cs` (con el atributo `[Migration(...)]`) — sin él, EF Core no la reconocía y nunca se aplicaba (`dotnet ef database update` decía "ya está actualizado" sin tocar la DB). Al regenerarla, además el `ModelSnapshot.cs` ya había sido editado a mano para reflejar el estado final, así que el primer intento de regeneración produjo una migración vacía. Se reconstruyó el snapshot correcto a partir del `Designer.cs` de `InitialCreate` y se regeneró la migración real.
- El usuario de prueba (`roberto.ramos@...`) quedó con rol `Cliente` en la base de datos existente — el seed solo actualizaba `Name`, no `Role`, y la rama que crea el usuario como `Admin` desde cero nunca corre en una DB que ya tiene datos. Sin esto, Equipo/Facturación devolvían 403/vacío. Corregido para que el seed también sincronice el rol.
- `TeamComponent`, `ProfileComponent`: usaban `btn-primary`/`btn-ghost` sin la clase base `.btn` (botones sin padding ni bordes redondeados), y `ProfileComponent` tenía la clase `.field` en el `<label>` en vez del `<input>` (inputs completamente sin estilo). Corregido.
- El diálogo de invitación estaba inline dentro de `TeamComponent` en vez de ser `TeamInviteDialogComponent` como pedía el plan — se extrajo a su propio componente.
- Faltaban los links "Equipo"/"Todos los clientes" en el drawer móvil del portal (solo estaban en el sidebar desktop) — agregados.

## Fase 3 — ampliación de alcance (2026-09-25): gestión de clientes y catálogo de productos (SuperAdmin)

### Contexto y decisiones confirmadas

El cliente pidió ampliar el rol SuperAdmin: hoy solo puede *ver* clientes (`AdminClientsComponent`, de solo lectura); necesita poder **crear/importar clientes**, **crear/modificar/importar productos**, y **asociar productos a un cliente** (lo que hoy solo hace el seed manualmente). Tres decisiones confirmadas con el usuario para no bloquear el diseño:

- **Autoservicio del cliente** (agregar/dar de baja/pagar renovación) va por **checkout directo vía PayPal**, sin aprobación manual — detallado en Fase 4.
- **Asociación manual por SuperAdmin** puede ser **manual/offline** (sin PayPal, ej. cliente que paga por transferencia o cortesía) o **vía PayPal** (queda pendiente hasta que el cliente aprueba el cobro) — ambos modos se implementan aquí; el modo PayPal se completa en Fase 4.
- **Tipos de ticket** (Bug/Funcionalidad/Requerimiento) son alcance de Fase 5, no de esta sección.

### Modelo de datos — cambios sobre lo ya implementado

```csharp
public class Product {
    // ...campos existentes (Type, Name, BillingCycle, BasePrice, Currency)...
    public string? Description; // NUEVO — se muestra en el catálogo de autoservicio (Fase 4) y en /admin/products
    public bool IsActive = true; // NUEVO — solo productos activos aparecen en el catálogo de autoservicio del cliente
}

public class ClientProduct {
    // ...campos existentes...
    public BillingCycle BillingCycle; // NUEVO — copiado de Product.BillingCycle al asociar, pero puede sobreescribirse por cliente (ej. un producto "Anual" facturado como "Unico" para un caso puntual)
    public bool IsManualBilling; // NUEVO — true = facturación offline (sin PayPal), lo fija el SuperAdmin al asociar
}

public enum ClientProductStatus { Activo, PorVencer, Vencido, Cancelado, Pendiente }
// Pendiente es NUEVO, agregado al final (no reordenar los existentes — son valores int ya persistidos).
// Se usa cuando la asociación es vía PayPal y todavía no se confirma el pago/aprobación (ver Fase 4).
```

Requiere una nueva migración EF Core (`AddProductCatalogAndClientProductBilling` o similar). Al aplicarla, poblar `ClientProduct.BillingCycle` para las filas existentes copiando el `BillingCycle` del `Product` relacionado (no debe quedar en el default `Unico` por accidente).

### Importación por Excel — formato

Usar **ClosedXML** (MIT, sin dependencia de Excel/COM) en `Rtres.Infrastructure` para leer/generar `.xlsx`.

| Plantilla | Columnas |
|---|---|
| Clientes (`clientes-plantilla.xlsx`) | `CompanyName`, `ContactName`, `Email`, `Phone`, `PreferredLanguage` (es/en/it) |
| Productos (`productos-plantilla.xlsx`) | `Type` (uno de los valores del enum `ProductType`), `Name`, `BillingCycle` (Unico/Mensual/Anual), `BasePrice`, `Currency`, `Description`, `IsActive` (true/false) |

El import es **best-effort por fila**: una fila inválida (email duplicado, enum inválido, campo requerido vacío) se salta y se reporta en `errors[]` con el número de fila y el motivo — no aborta el resto del archivo.

### Inventario de componentes — app `portal` (ampliación Fase 3)

| Componente | Selector | Ruta | Notas |
|---|---|---|---|
| `AdminClientsComponent` | `app-admin-clients` | `/admin/clients` (ya existe, de solo lectura) | Ampliar: botones "Nuevo cliente" e "Importar Excel" en la toolbar; cada fila navega a `AdminClientDetailComponent`. |
| `AdminClientDetailComponent` | `app-admin-client-detail` | `/admin/clients/:id` (nueva) | Datos del cliente (editable), lista de sus `ClientProduct` con acciones (asociar nuevo, editar, cancelar). |
| `ClientFormDialogComponent` | `app-client-form-dialog` | — | Form crear/editar cliente (`CompanyName`, `ContactName`, `Email`, `Phone`, `PreferredLanguage`). |
| `AdminProductsComponent` | `app-admin-products` | `/admin/products` (nueva) | Tabla del catálogo completo (incluye inactivos): tipo, nombre, ciclo, precio, activo/inactivo. Toolbar: "Nuevo producto" / "Importar Excel". |
| `ProductFormDialogComponent` | `app-product-form-dialog` | — | Form crear/editar producto. |
| `ClientProductAssignDialogComponent` | `app-client-product-assign-dialog` | — (vive en `AdminClientDetailComponent`) | Selecciona producto + proyecto + ciclo de facturación + modo (`Manual`/`PayPal`) + campos condicionales (dominio si `Type=Dominio`, override de precio). |
| `ImportDialogComponent` | `app-import-dialog` | — | Genérico, reutilizado por clientes y productos: input `.xlsx`, botón "Descargar plantilla", muestra el resumen `{created, skipped, errors[]}` tras subir. |

`SidebarComponent`/drawer móvil: agregar link "Catálogo de productos" (`/admin/products`, condicional a `role==='SuperAdmin'`) junto al ya existente "Todos los clientes".

### Contrato de API — ampliación Fase 3

Todos bajo `/api/admin`, `[Authorize(Roles="SuperAdmin")]`.

| Método | Ruta | Uso | Body/Query | Respuesta |
|---|---|---|---|---|
| POST | `/admin/clients` | `ClientFormDialogComponent` crear | `{ companyName, contactName, email, phone?, preferredLanguage }` | `ClientDto` |
| PATCH | `/admin/clients/{id}` | `ClientFormDialogComponent` editar | campos parciales | 200 |
| POST | `/admin/clients/import` | `ImportDialogComponent` | multipart `.xlsx` | `{ created, skipped, errors: [{row, reason}] }` |
| GET | `/admin/clients/import/template` | `ImportDialogComponent` "Descargar plantilla" | — | archivo `.xlsx` |
| GET | `/admin/products` | `AdminProductsComponent` | — | `ProductDto[]` (incluye inactivos) |
| POST | `/admin/products` | `ProductFormDialogComponent` crear | `{ type, name, billingCycle, basePrice?, currency, description?, isActive }` | `ProductDto` |
| PATCH | `/admin/products/{id}` | `ProductFormDialogComponent` editar | campos parciales | 200 |
| POST | `/admin/products/import` | `ImportDialogComponent` | multipart `.xlsx` | `{ created, skipped, errors: [{row, reason}] }` |
| GET | `/admin/products/import/template` | `ImportDialogComponent` | — | archivo `.xlsx` |
| POST | `/admin/clients/{clientId}/products` | `ClientProductAssignDialogComponent` | `{ productId, projectId, billingCycle, billingMode: 'Manual'\|'PayPal', price?, domainName?, priceLabelOverride? }` | `ClientProductDto` — `billingMode=Manual` crea con `Status=Activo` directo; `billingMode=PayPal` crea con `Status=Pendiente` y devuelve el `clientProductId` para que Fase 4 dispare el checkout |
| PATCH | `/admin/client-products/{id}` | `AdminClientDetailComponent` editar asociación | campos parciales (`price`, `status`, etc.) | 200 |

### Checklist de tareas — ampliación Fase 3 (delegable, en orden)

- [x] **T3.11** — Migración EF Core: `Product.Description`/`Product.IsActive`, `ClientProduct.BillingCycle`/`ClientProduct.IsManualBilling`, `ClientProductStatus.Pendiente`. Backfill de `ClientProduct.BillingCycle` desde `Product.BillingCycle` para filas existentes. ✅ Aplicada contra SQL Server real (`20260925134436_AddProductCatalogAndClientProductBilling`); `dotnet ef migrations has-pending-model-changes` confirma modelo/DB sincronizados; los 5 `ClientProduct` sembrados conservaron su ciclo correcto tras el backfill.
- [x] **T3.12** — Backend: `AdminController` — `POST/PATCH /api/admin/clients`. ✅ Probado con `curl`: crear cliente responde 201 con el DTO correcto.
- [x] **T3.13** — Backend: import de clientes con ClosedXML — `POST/GET /api/admin/clients/import(/template)`. ✅ Probado con un `.xlsx` real (2 filas válidas + 1 inválida a propósito): `{"created":2,"skipped":1,"errors":[{"row":4,"reason":"..."}]}`.
- [x] **T3.14** — Backend: `GET/POST/PATCH /api/admin/products`. ✅ Probado con `curl`: listar y crear responden 200/201.
- [x] **T3.15** — Backend: import de productos — `POST/GET /api/admin/products/import(/template)`. ✅ Probado con un `.xlsx` real (1 fila válida + 1 inválida): `{"created":1,"skipped":1,"errors":[...]}`.
- [x] **T3.16** — Backend: `POST /api/admin/clients/{clientId}/products` + `PATCH /api/admin/client-products/{id}`. ✅ Probado con `curl`: modo `Manual` crea `Status=Activo` inmediato, modo `PayPal` crea `Status=Pendiente`, tal como especifica el contrato.
- [x] **T3.17** — Frontend: `AdminClientsComponent` ampliado + `ClientFormDialogComponent` + `AdminClientDetailComponent`. ✅ Verificado en navegador: listado, detalle de cliente con tabla de productos asociados.
- [x] **T3.18** — Frontend: `AdminProductsComponent` + `ProductFormDialogComponent`. ✅ Verificado en navegador: catálogo completo, diálogo "Nuevo producto" bien estilizado.
- [x] **T3.19** — Frontend: `ClientProductAssignDialogComponent` + `ImportDialogComponent`. ✅ Verificado en navegador: asocié un producto en modo Manual end-to-end (seleccionar producto/proyecto/ciclo → Asociar → fila nueva aparece con `Status=Activo` sin recargar), y el diálogo de importación (subir/descargar plantilla) se ve y abre correctamente para clientes y productos.
- [x] **T3.20** — Verificación end-to-end. ✅ `dotnet build`, `dotnet ef database update` y `ng build portal` sin errores; ciclo completo probado por `curl` + navegador: crear cliente a mano, importar 2 clientes por Excel (1 fila inválida reportada correctamente), crear producto a mano, importar producto por Excel, asociar en modo Manual (`Activo` inmediato) y en modo PayPal (`Pendiente`, listo para Fase 4).

**Nota de verificación**: Codex (segundo thread, T3.11–T3.20) generó todo el código pero no pudo compilar/aplicar la migración/buildear el portal en su sandbox por restricciones de permisos sobre `NuGet.Config`/`obj`/`node_modules` — igual que en fases anteriores, todo se verificó manualmente de punta a punta (build, migración, `curl` y navegador) y funcionó sin bugs reales encontrados esta vez, a diferencia de Fases 1–3 originales.

### Bugs reportados por el usuario tras la verificación inicial y corregidos (2026-09-25)

- **No existía forma de dar de baja a un cliente.** Se agregó `Client.IsActive` (bool, default `true`) + migración `AddClientIsActive`. `PATCH /api/admin/clients/{id}` ahora acepta `isActive`; `AuthController.Login` rechaza con `403` a cualquier usuario cuyo `Client.IsActive` sea `false` ("Este cliente está dado de baja. Contacta a Rtres."). Frontend: botón "Dar de baja"/"Reactivar" + pill de estado en `AdminClientDetailComponent`, badge "Inactivo" en las tarjetas de `AdminClientsComponent`. Nueva clase `.btn-danger` agregada a `portal.css` (mismo patrón que `.btn-primary`/`.btn-ghost`). Verificado con `curl` end-to-end: usuario de un cliente dado de baja no puede loguearse (403), vuelve a poder tras reactivar.
  - **Bug real encontrado en el proceso**: la migración generada por `dotnet ef migrations add` puso `defaultValue: false` en el `ADD COLUMN` (EF no lee el inicializador `= true` de la propiedad C#, solo usa el default del tipo CLR) — esto **desactivó momentáneamente los 5 clientes ya existentes** en la base real al aplicar la migración. Detectado inmediatamente con `sqlcmd` antes de que impactara al usuario; corregido editando la migración a `defaultValue: true` y con un `UPDATE Clients SET IsActive = 1` de una sola vez sobre los datos ya afectados. **Lección para futuras migraciones de columnas booleanas con default `true`**: siempre verificar el `defaultValue` generado, EF no lo infiere del código C#.
- **El selector de cliente del SuperAdmin (topbar) no actualizaba la pantalla.** Causa: `ClientSwitcherComponent.choose()` hace `router.navigateByUrl('/dashboard')`, que es un no-op si ya se está en `/dashboard` (la página de aterrizaje por defecto) — Angular no reactiva rutas idénticas. `DashboardComponent`, `BillingComponent`, `TicketsListComponent` y `TicketFormComponent` solo cargaban sus datos una vez en `ngOnInit`, sin reaccionar a cambios de `PortalUiService.viewingClientId`. Corregido envolviendo la carga de datos de los 4 componentes en un `effect()` que depende de `ui.viewingClientId()`, en vez de depender de la navegación del router. Verificado en navegador: seleccionar un cliente desde `/dashboard` ahora refresca los stat cards y la grilla de productos al instante.

## Fase 4 — detalle (suscripciones y facturación PayPal)

### Contexto y alcance

Ya existe un esqueleto sin verificar heredado del commit inicial del repo (anterior a todo el trabajo de Fases 1–3): `PaymentsController`, `IPayPalClient`/`PayPalClient`, `CheckoutRequest`. **No asumir que funciona** — predata el modelo multi-tenant (`?clientId=` de SuperAdmin), `ClientProduct.BillingCycle` propio, `ClientProductStatus.Pendiente`, etc., y el webhook actual hardcodea `Amount = 0` en el `PaymentTransaction` (bug real, no cosmético) en vez de leer el monto real del evento de PayPal. Revisar y reescribir contra el contrato de abajo, no extender tal cual.

### Datos de PayPal para pruebas

App sandbox "Rtres" ya creada en el Developer Dashboard de PayPal (Client ID + Secret configurados 2026-09-25). **Las credenciales NO se guardan en este archivo** (`PLAN.md` está versionado en git) — viven en `src/api/Rtres.Api/appsettings.Development.local.json` (ignorado por `.gitignore`, patrón `appsettings.*.local.json`), cargado automáticamente por `Program.cs` (`AddJsonFile("appsettings.{Environment}.local.json", optional: true)`). `appsettings.json` solo tiene los placeholders vacíos (`PayPal:ClientId`, `PayPal:Secret`) para que quede claro qué configurar en cualquier entorno nuevo.

Alcance confirmado con el usuario:
- **Autoservicio del cliente**: ve un catálogo de productos activos, agrega uno, y el checkout se completa **directo en PayPal** (Orders API si `billingCycle=Unico`, Subscriptions API si `Mensual`/`Anual`) — sin paso de aprobación manual de Rtres. Al confirmarse el pago (webhook), el `ClientProduct` pasa de `Pendiente` a `Activo` automáticamente.
- **Asociación manual por SuperAdmin en modo PayPal** (Fase 3, T3.16) alimenta el mismo flujo: el `ClientProduct` ya existe en `Pendiente`, y esta fase debe generar su checkout y procesarlo igual que el autoservicio.
- **Dar de baja**: para productos con ciclo `Mensual` que tienen una suscripción PayPal viva (`PayPalSubscriptionId` seteado) — cancela la suscripción real vía Subscriptions API, `Status → Cancelado`.
- **Pagar la renovación**: para productos `Anual`/`Unico` (Hosting, Dominio, SSL — no son suscripciones PayPal continuas, se modelan con `RenewsAt`) — genera una nueva orden Orders API; al completarse, extiende `RenewsAt` +1 año/mes y `Status → Activo`.
- Los productos con `IsManualBilling=true` (asociación offline de Fase 3) **no** exponen botones de pago/baja en el portal — se gestionan solo desde `/admin`.

### Modelo de datos — cambios sobre lo ya implementado

Sin cambios de entidades adicionales a los ya declarados en la ampliación de Fase 3 (`ClientProduct.BillingCycle`/`IsManualBilling`, `ClientProductStatus.Pendiente`) — esta fase es la que los consume. Único ajuste: `PaymentTransaction.Amount`/`Currency` deben poblarse con el monto real del evento de PayPal (hoy el webhook hardcodea `0`).

### Inventario de componentes — app `portal` (Fase 4)

| Componente | Selector | Ruta | Notas |
|---|---|---|---|
| `CatalogComponent` | `app-catalog` | `/catalog` (nueva) | Grilla de productos con `Product.IsActive=true`, botón "Agregar" por producto. |
| `SubscribeDialogComponent` | `app-subscribe-dialog` | — | Confirma proyecto + ciclo de facturación antes de redirigir a PayPal; llama `POST /api/subscriptions` y navega a `approvalUrl`. |
| `PayPalReturnComponent` | `app-paypal-return` | `/billing/return` (nueva, destino del `returnUrl`/`cancelUrl` de PayPal) | Pantalla "Procesando tu pago...", hace polling corto a `GET /api/client-products/{id}` esperando que el webhook confirme, luego redirige al dashboard. |
| `ProductCardComponent` | `app-product-card` (ya existe) | — | Ampliar: botón "Renovar ahora" si `Status` es `PorVencer`/`Vencido` y ciclo `Anual`/`Unico`; botón "Cancelar suscripción" si `Status=Activo`, ciclo `Mensual` y `PayPalSubscriptionId` no nulo. Ninguno de los dos si `IsManualBilling=true`. |

### Contrato de API — Fase 4

Todos bajo `/api`, JWT Bearer, scopeados al `client_id` del JWT (o `?clientId=` si es SuperAdmin, igual que el resto del contrato).

| Método | Ruta | Uso | Body/Query | Respuesta | Rol |
|---|---|---|---|---|---|
| GET | `/catalog/products` | `CatalogComponent` | — | `ProductDto[]` (solo `IsActive=true`) | Cliente, Admin, SuperAdmin |
| POST | `/subscriptions` | `SubscribeDialogComponent` | `{ productId, projectId, billingCycle }` | `{ clientProductId, approvalUrl }` — crea `ClientProduct` en `Pendiente` + orden/suscripción PayPal | Cliente, Admin |
| POST | `/client-products/{id}/renew` | Botón "Renovar ahora" | — | `{ approvalUrl }` | Cliente, Admin |
| POST | `/client-products/{id}/cancel` | Botón "Cancelar suscripción" | — | 200 | Cliente, Admin |
| GET | `/client-products/{id}` | `PayPalReturnComponent` polling | — | `ClientProductDto` (incluye `status` actualizado) | Cliente, Admin |
| POST | `/payments/webhooks/paypal` | PayPal → backend (reescribir el existente) | evento PayPal firmado | 200 | público (verificado por firma, no JWT) |

### Checklist de tareas — Fase 4 (delegable, en orden)

- [x] **T4.0** — Auditar el esqueleto heredado (`PaymentsController`, `IPayPalClient`/`PayPalClient`) contra este contrato; decidir por archivo si se reescribe o se conserva. ✅ `PaymentsController` reescrito contra las rutas de Fase 4 (el antiguo `/checkout` no estaba scopeado para SuperAdmin y el webhook no leía importes/órdenes). `IPayPalClient`/`PayPalClient` reescritos: OAuth2 client-credentials real (`v1/oauth2/token`, antes usaba un `AccessToken` estático que nunca hubiera funcionado), `VerifyWebhookAsync` real contra `v1/notifications/verify-webhook-signature`, `CancelSubscriptionAsync` agregado, `custom_id` en `CreateOrderAsync`/`CreateSubscriptionAsync` para correlación confiable en el webhook.
- [x] **T4.1** — Backend: `GET /api/catalog/products`. ✅ Probado con `curl`.
- [x] **T4.2** — Backend: `POST /api/subscriptions`. ✅ Probado con `curl` **contra el sandbox real de PayPal**: generó una orden real y devolvió `approvalUrl` de `sandbox.paypal.com`; `ClientProduct` quedó en `Pendiente` con `PayPalOrderId` seteado.
- [x] **T4.3** — Backend: `POST /api/client-products/{id}/renew` y `/cancel`. ✅ Probadas las validaciones (rechaza renovar algo `Pendiente`, rechaza cancelar sin suscripción activa).
- [x] **T4.4** — Backend: webhook reescrito — verifica firma, resuelve por `custom_id` o por `PayPalOrderId`/`PayPalSubscriptionId`, lee monto/moneda reales del payload. ✅ Probado que rechaza (401) sin cabeceras de firma de PayPal.
- [x] **T4.5** — Backend: asociaciones `billingMode=PayPal` de Fase 3 disparan el checkout real. ✅ Probado con `curl`: modo Manual → `Activo` inmediato con `approvalUrl:null`; modo PayPal → `Pendiente` con `approvalUrl` real de PayPal sandbox.
- [x] **T4.6** — Frontend: `CatalogComponent` + `SubscribeDialogComponent`. ✅ Verificado en navegador de punta a punta: catálogo → diálogo → clic en "Continuar a PayPal" → el navegador llega genuinamente a la pantalla de login del sandbox de PayPal.
- [x] **T4.7** — Frontend: `PayPalReturnComponent`, ruta `/billing/return`.
- [x] **T4.8** — Frontend: `ProductCardComponent` — botones "Renovar ahora"/"Cancelar suscripción" condicionales (excluidos si `isManualBilling`).
- [x] **T4.9** — Verificación end-to-end contra el sandbox de PayPal. ✅ Ver "Bugs reales encontrados" abajo — checkout de un producto `Unico` verificado de punta a punta (API → PayPal real); no se completó un pago real (requeriría credenciales de comprador sandbox que el usuario no compartió), pero se confirmó cada tramo de la cadena: creación de orden, `approvalUrl`, redirección real del navegador.

**Bugs reales encontrados y corregidos durante la verificación** (Codex no pudo compilar/migrar/buildear en su sandbox — mismo patrón de fases anteriores — y reportó honestamente esa limitación en vez de afirmar que todo funcionaba):
- La migración `AddPayPalOrderId` (escrita a mano por Codex) no tenía `.Designer.cs` — mismo bug recurrente de Fases 1/3: sin el atributo `[Migration(...)]`, EF nunca la aplicaba. Regenerada correctamente (requirió revertir temporalmente el fragmento ya editado a mano del `ModelSnapshot.cs` para que el diff no saliera vacío, mismo procedimiento de recuperación ya documentado en Fase 3).
- El build de `ng build portal` que Codex reportó como "crash (`exit -1073741819`)" era un artefacto de su sandbox — se ejecutó igual en este entorno y compiló limpio sin ningún cambio de código.
- **Bug real de UX/datos**: cuando el SuperAdmin asocia un producto en modo PayPal (T4.5), el backend generaba una orden real de PayPal y devolvía su `approvalUrl`, pero el frontend (`AdminClientDetailComponent.assign()`) ignoraba la respuesta por completo — la orden quedaba creada en PayPal sin que nadie tuviera el link para completarla. Corregido: la respuesta de `POST /api/admin/clients/{clientId}/products` ahora siempre trae `{ clientProduct, approvalUrl }` (antes el shape difería entre modo Manual y PayPal), y el frontend muestra el link con `prompt()` para que el SuperAdmin lo copie y se lo envíe al cliente.
- No se verificó el link de "Catálogo" en la navegación del cliente porque **no existía**: la ruta y el componente estaban completos pero ningún link del sidebar ni del drawer móvil apuntaba a `/catalog` — un cliente real nunca hubiera podido llegar a la página. Agregado en `SidebarComponent` y `PortalShellComponent`.

## Fase 5 — detalle (tickets: tipos, comentarios, GitHub)

### Contexto y alcance

Hoy `TicketType` es `{ Soporte, Cambio }`. El backend ya expone `GET /api/tickets/{id}` devolviendo el ticket + sus `TicketComment` (`PortalController.cs:39`), pero el frontend no tiene página de detalle ni forma de comentar — es contrato sin UI. Tampoco hay integración real con GitHub: existe `IGitHubIssuesClient`/`GitHubIssuesClient` (esqueleto heredado del commit inicial, sin verificar) pero `POST /api/tickets` no lo invoca todavía.

**Decisión confirmada**: `TicketType` pasa a `{ Bug, Funcionalidad, Requerimiento }` (reemplaza `Soporte`/`Cambio`). Como `Soporte=0`→`Bug=0` y `Cambio=1`→`Funcionalidad=1` numéricamente, **no hace falta un fixup de datos** al migrar — solo renombrar los dos valores existentes y agregar `Requerimiento=2` al final. `Bug` usa los campos "reporte de error" (`StepsToReproduce`, `CurrentBehavior`, `ExpectedBehavior`, `Environment`); `Funcionalidad` y `Requerimiento` usan los campos "cambio" (`ExpectedBehavior` requerido, `EstimatedImpact`, `CurrentBehavior` opcional ya que suele ser algo net-new sin comportamiento previo).

### Modelo de datos — cambios sobre lo ya implementado

```csharp
public enum TicketType { Bug, Funcionalidad, Requerimiento } // reemplaza { Soporte, Cambio } — mismos valores 0/1, agrega 2
```

Migración EF Core puramente de metadata (el enum ya es compatible a nivel de storage, no requiere `UPDATE` de filas existentes).

### Inventario de componentes — app `portal` (Fase 5)

| Componente | Selector | Ruta | Notas |
|---|---|---|---|
| `TicketDetailComponent` | `app-ticket-detail` | `/tickets/:id` (nueva — el backend ya la soporta, falta el frontend) | Header con Code/Status/Type; cuerpo con todos los campos del ticket; link al issue de GitHub si `GithubIssueUrl` no es null; `CommentThreadComponent` + `CommentFormComponent`. |
| `CommentThreadComponent` | `app-comment-thread` | — | Lista de `TicketComment`, distingue visualmente `FromGithub=true` (ej. ícono/etiqueta "vía GitHub"). |
| `CommentFormComponent` | `app-comment-form` | — | Textarea + submit → `POST /api/tickets/{id}/comments`. |
| `TicketFormComponent` (ya existe) | — | `/tickets/new` | Actualizar `<select>` de tipo a Bug/Funcionalidad/Requerimiento; ajustar visibilidad de campos según el nuevo mapeo (arriba). |
| `TicketTableComponent` (ya existe) | — | — | Las filas hoy no navegan a ningún lado — deben enlazar a `/tickets/:id`. |
| `TicketTypePillComponent` | `app-ticket-type-pill` | — | Nuevo, análogo a `StatusPillComponent` pero para `TicketType` (color distinto por Bug/Funcionalidad/Requerimiento). |

### Contrato de API — Fase 5

| Método | Ruta | Uso | Body/Query | Respuesta | Rol |
|---|---|---|---|---|---|
| GET | `/tickets/{id}` | `TicketDetailComponent` (ya implementado, sin frontend) | — | `{ ticket, comments[] }` | Cliente, Admin, SuperAdmin |
| POST | `/tickets/{id}/comments` | `CommentFormComponent` | `{ body }` | `TicketCommentDto` | Cliente, Admin |
| POST | `/webhooks/github` | GitHub → backend | payload de issue comment/closed | 200 | público (verificado por firma del webhook) |

### Checklist de tareas — Fase 5 (delegable, en orden)

- [x] **T5.0** — Migración EF Core: renombrar `TicketType` (metadata únicamente, ver nota arriba). Actualizar el `<select>` y las validaciones condicionales de `TicketFormComponent`.
- [x] **T5.1** — Backend: `POST /api/tickets/{id}/comments`.
- [x] **T5.2** — Backend: auditar `IGitHubIssuesClient`/`GitHubIssuesClient` heredado (esqueleto sin verificar); conectar `POST /api/tickets` para que dispare `CreateIssueAsync` (fire-and-forget o job de Hangfire) y guarde `GithubIssueNumber`/`GithubIssueUrl`. Labels por tipo: `bug`/`enhancement`/`requirement`.
- [x] **T5.3** — Backend: `POST /api/webhooks/github` — verifica firma, mapea comentarios entrantes a `TicketComment(FromGithub=true)` y cierres de issue a `TicketStatus.Resuelto`/`Cerrado`.
- [x] **T5.4** — Frontend: `TicketDetailComponent`, `CommentThreadComponent`, `CommentFormComponent`, ruta `/tickets/:id`.
- [x] **T5.5** — Frontend: `TicketTableComponent` — filas navegables a `/tickets/:id`; `TicketTypePillComponent`.
- [x] **T5.6** — Verificación end-to-end: crear un ticket de cada tipo (Bug/Funcionalidad/Requerimiento) y confirmar que aparece un Issue real en el repo de GitHub del proyecto correspondiente con las labels correctas; comentar desde el portal y desde GitHub y confirmar que ambos lados se reflejan en `CommentThreadComponent`.

### Estado de la Fase 5 (implementado 2026-09-26)

T5.0–T5.6 completos. **T5.6 verificada 2026-09-26** contra GitHub real (repo de pruebas en cuenta personal, API local expuesta con ngrok, SQL Server remoto): creación de issues con labels, comentarios portal→GitHub y GitHub→portal, y cambios de estado vía labels/cierre. La verificación destapó un 500 en `POST /tickets/{id}/comments` (filtro sobre DTO no traducible en SQL Server), corregido en rockespier/Rtres#3. Detalles de la implementación:

- **Issue al crear ticket**: `POST /api/tickets` encola `GitHubIssueSyncJob.CreateIssueAsync` (Hangfire, 5 reintentos, idempotente). Título `[RT-xxx] <título>`, cuerpo con solo las secciones completadas (Impacto solo en Funcionalidad/Requerimiento), labels `bug`/`enhancement`/`requirement` + `estado:abierto` + `proyecto:<slug>`. Proyectos sin `GithubRepoOwner/Name` se omiten con warning.
- **Comentarios portal → GitHub**: `POST /api/tickets/{id}/comments` (Cliente/Admin; SuperAdmin recibe 403) guarda el `TicketComment` y encola `PostCommentAsync`, que lo publica en el issue como `**<nombre>** (vía portal de clientes)` con una marca oculta `<!-- rtres-portal-comment:<id> -->`. Si el issue aún no existe, se publica cuando `CreateIssueAsync` lo crea.
- **Webhook GitHub → portal** (`POST /api/webhooks/github`): exige `X-Hub-Signature-256` válido con `GitHub:WebhookSecret` (sin secreto → 401 siempre). Configurar en cada repo u org con eventos **Issues** e **Issue comments**, `application/json`. Busca el ticket por repo + número de issue.
  - Estado: en un issue abierto manda el label `estado:{abierto|en-progreso|resuelto|publicado|cerrado}` más avanzado (sin label → `Abierto`). En un issue cerrado solo cuentan los labels de cierre (`resuelto`/`publicado`/`cerrado`), porque todo issue nace con `estado:abierto`; sin label de cierre, *not planned* → `Cerrado` y cualquier otro cierre → `Resuelto`. Cada cambio real llama a `INotificationSender` (`ticket-status-changed`) y registra `NotificationLog` (`TicketStatusChange`); el email real llega en Fase 6.
  - Comentarios humanos del issue se replican como `TicketComment(FromGithub=true)` (crear/editar/borrar, dedupe por `GithubCommentId`); se ignoran bots y los que llevan la marca del portal. **Ojo: todo comentario humano del issue queda visible al cliente.**
- `GET /api/tickets` acepta `?status=&type=`; `GET /api/tickets/{id}` devuelve `comments` como `TicketCommentDto` con `authorName`.
- Migración `GitHubTicketSync`: `TicketComment.GithubCommentId`/`GithubAuthorLogin` + índices. El renombre de `TicketType` no genera cambios de esquema (int).
- Frontend: filtros de estado/tipo y paginación reales en `TicketsListComponent`; formulario con Bug/Funcionalidad/Requerimiento (tras crear navega al detalle).

## Fase 6 — detalle (notificaciones por email)

### Decisiones (confirmadas 2026-09-26)

- **Proveedor**: SMTP de una cuenta de correo propia (ej. `notificaciones@rtres.net` en el hosting), vía MailKit. Sin `Smtp:Host` configurado, los emails solo se escriben en el log (desarrollo).
- **Emails de esta fase**: vencimientos, cambio de estado de ticket, respuesta del equipo en un ticket, pago recibido y pago fallido.
- **Vencimientos**: avisos a **30, 7 y 1 día** de `ClientProduct.RenewsAt`.
- **Idioma**: `Client.PreferredLanguage` (`es`/`en`/`it`, por defecto `es`). **Destinatario**: `Client.Email` (el contacto del cliente, no cada usuario del equipo).

### Diseño

- `INotificationSender.SendAsync(client, Notification)` → `QueuedNotificationSender` encola `NotificationJob` en Hangfire (un SMTP lento no frena los webhooks de GitHub/PayPal; 3 reintentos).
- `NotificationJob`: omite clientes inactivos o sin email; renderiza con `EmailTemplates` (HTML + texto plano, ES/EN/IT, datos escapados); envía con `IEmailSender`; registra cada intento en `NotificationLog` (`Recipient`, `DedupeKey`, `Success`, `Error`).
- **Dedupe**: un aviso con `DedupeKey` ya enviado con éxito no se repite (un fallo no bloquea el reintento). Claves: `renewal:{clientProductId}:{yyyyMMdd}:{30|7|1}`, `ticket-reply:{githubCommentId}`, `payment:{orderId}`, `payment-failed:{webhookEventId}`.
- `RenewalReminderJob` (diario 13:00 UTC = 8:00 Lima): productos `Activo`/`PorVencer` con `RenewsAt` en los próximos 30 días; elige el umbral más chico que aplica (a 20 días → aviso de 30; a 5 → de 7; a 0–1 → de 1), así un producto dado de alta a 5 días del vencimiento no recibe el de 30, y un día sin correr el job no pierde el aviso. Marca el producto `PorVencer`. El texto distingue renovación automática (`PayPalSubscriptionId`) de manual.
- Disparadores: `GitHubWebhookProcessor` (cambio real de `TicketStatus`; comentario humano nuevo en el issue, no ediciones/bots/eco del portal) y webhook de PayPal (`PAYMENT.CAPTURE.COMPLETED`/`PAYMENT.SALE.COMPLETED` que crean un `PaymentTransaction` nuevo; `PAYMENT.CAPTURE.DENIED`/`PAYMENT.SALE.DENIED`/`BILLING.SUBSCRIPTION.PAYMENT.FAILED`).
- Migración `NotificationLogDetails`: `NotificationLog.Recipient`/`DedupeKey`/`Error` + índice en `DedupeKey`.

### Configuración (`appsettings.*.local.json`)

```json
"Smtp": { "Host": "mail.rtres.net", "Port": 587, "Security": "StartTls", "User": "notificaciones@rtres.net", "Password": "…", "From": "notificaciones@rtres.net", "FromName": "Rtres Web Solutions" }
```

`Security`: `Auto` (defecto), `StartTls` (587), `SslOnConnect` (465) o `None`. `Frontend:PortalUrl` se usa para los enlaces de los emails.

### Checklist de tareas — Fase 6

- [x] **T6.0** — Modelo `Notification`/`NotificationType`, `IEmailSender` (SMTP con MailKit + fallback a log), `EmailTemplates` ES/EN/IT, `NotificationJob` con log y dedupe, migración.
- [x] **T6.1** — `RenewalReminderJob` con umbrales 30/7/1 y dedupe.
- [x] **T6.2** — Avisos de estado y respuesta de ticket desde el webhook de GitHub.
- [x] **T6.3** — Avisos de pago recibido/fallido desde el webhook de PayPal.
- [x] **T6.4** — Verificación con el SMTP real: configurar `Smtp:*`, forzar el job `renewal-reminders` desde `/jobs` con un producto a ≤30 días, cambiar el estado de un ticket y comentar desde GitHub; confirmar la recepción (y que no caiga en spam: revisar SPF/DKIM del dominio remitente) y las filas en `NotificationLogs`. ✅ Verificado 2026-09-27 contra `mail.rtres.net` real: cierre de issue en GitHub → cambio de estado del ticket + email recibido; `renewal-reminders` forzado manualmente también entregó el correo. Bug real encontrado y corregido: MailKit rechazaba el TLS del servidor por `SslHandshakeException` (revocación de certificado incompleta) — se desactivó `CheckCertificateRevocation` en `SmtpEmailSender`.

**Pendiente/riesgo conocido**: Hangfire usa `MemoryStorage`, así que los emails encolados se pierden si la API se reinicia antes de enviarlos. Para producción conviene pasar a `Hangfire.SqlServer` (también afecta a los jobs de GitHub de la Fase 5).

## Fase 7 — detalle (contabilidad Perú: multi-moneda, documentos tributarios, IGV/Renta, gastos)

### Contexto y alcance

Rtres opera legalmente en Perú (declara ante SUNAT en Soles), pero cobra a clientes en USD (la mayoría) y EUR (clientes en Italia). Hoy no hay ningún rastro contable en el sistema más allá de `PaymentTransaction` (monto + moneda, sin conversión ni relación con documentos tributarios). Fase 7 agrega la capa de **registro contable/tributario interno** — no reemplaza al contador ni presenta declaraciones ante SUNAT.

**Disclaimer explícito que debe quedar visible en la UI de reportes**: los montos de IGV/Renta que calcula el sistema son una **estimación basada en tasas configurables por el propio usuario**, no una liquidación oficial — el sistema no conoce ni valida el régimen tributario real de Rtres ante SUNAT (RER/MYPE/General calculan Renta sobre bases distintas: ventas brutas vs. utilidad neta). La responsabilidad de la tasa y la base de cálculo correctas es del usuario/su contador; el sistema solo aplica fielmente la fórmula configurada.

Decisiones confirmadas con el usuario (vía `AskUserQuestion`):
- **Documentos tributarios**: el sistema **solo registra** Facturas/Recibos por Honorarios ya emitidos con el facturador externo de Rtres (serie, correlativo, tipo, monto) — **no emite ni timbra nada ante SUNAT** (evita certificado digital, PSE/OSE, XML/UBL firmado, homologación — todo eso queda fuera de alcance, tal como ya decía la sección "Supuestos" del plan original).
- **IGV en precios existentes**: `Product.BasePrice`/`ClientProduct.Price` se tratan como **precios sin IGV** — el 18% se calcula y muestra aparte en los reportes, no se resta de lo ya guardado.
- **Tasas de IGV/Renta**: configurables en una pantalla de ajustes (`TaxSettings`), no hardcodeadas en código — default IGV=18%, Renta=10%, editables por SuperAdmin en cualquier momento.
- **Tipo de cambio**: automatizado — USD desde el **tipo de cambio publicado por SUNAT** (el oficial para efectos tributarios en Perú); EUR desde una **API de tipos de cambio general** (SUNAT no publica EUR/PEN diario). **Nota de implementación**: la URL/endpoint exacto de SUNAT para el TC diario (y el de la API de EUR elegida) deben verificarse en el momento de implementar — no asumir una URL sin probarla primero, SUNAT ha cambiado el formato de esta publicación en el pasado.

### Modelo de datos (EF Core — nuevo)

```csharp
public class ExchangeRate {
    public Guid Id; public DateOnly Date; public string CurrencyCode; // "USD" | "EUR"
    public decimal RateToPen; public string Source; // "SUNAT" | "API:<nombre>"
}

public enum TaxDocumentType { Factura, ReciboPorHonorarios }

public class TaxDocument {
    public Guid Id; public Guid? PaymentTransactionId; public Guid ClientId;
    public TaxDocumentType Type; public string Series; public int Number; // serie+correlativo, ej. "F001"-123
    public DateOnly IssueDate; public string Currency; public decimal BaseAmount; // sin IGV
    public decimal IgvAmount; public decimal TotalAmount; public string? Notes;
}

public enum ExpenseType { Fijo, Variable }
public enum ExpenseCategory { Hosting, Dominios, SuscripcionesIA, ApisPorUso, Sueldos, Otros }

public class Expense {
    public Guid Id; public string Description; public ExpenseCategory Category; public ExpenseType Type;
    public decimal Amount; public string Currency; public decimal AmountPen; // snapshot al tipo de cambio del día
    public DateOnly Date; public bool Recurring; public BillingCycle? RecurrenceCycle; // reusa el enum existente
}

public class TaxSettings { // fila única, tipo singleton
    public Guid Id; public decimal IgvRate = 0.18m; public decimal RentaRate = 0.10m; public DateTime UpdatedAt;
}
```

Cambio sobre `PaymentTransaction` (ya existente): agregar `public decimal AmountPen` (snapshot calculado al crear la transacción, usando el `ExchangeRate` del día — **no recalcular después**, para que el reporte de un mes cerrado no cambie retroactivamente si el tipo de cambio histórico se corrige en la fuente) y `public string? InternalCode` (código interno autogenerado, ej. `RT-INT-000123`, poblado siempre — el documento tributario vinculado, si existe, es la referencia "oficial"; si no existe `TaxDocument`, `InternalCode` es la única referencia de esa venta).

### Job de tipo de cambio (Hangfire)

`ExchangeRateSyncJob` — diario, temprano en la mañana: obtiene el TC USD/PEN de SUNAT y EUR/PEN de la API elegida para la fecha del día, inserta una fila en `ExchangeRate` por moneda (si el día ya tiene fila, no la duplica). Si la fuente falla (fin de semana sin publicación, error de red), reutilizar el último `ExchangeRate` disponible como fallback y loguearlo — nunca dejar una transacción sin `AmountPen`.

### Contrato de API — Fase 7

Todos bajo `/api/admin`, `[Authorize(Roles="SuperAdmin")]` salvo donde se indique.

| Método | Ruta | Uso | Body/Query | Respuesta |
|---|---|---|---|---|
| GET | `/admin/tax-settings` | `TaxSettingsComponent` | — | `{ igvRate, rentaRate }` |
| PATCH | `/admin/tax-settings` | `TaxSettingsComponent` guardar | `{ igvRate?, rentaRate? }` | 200 |
| GET | `/admin/exchange-rates?from=&to=` | `ReportsComponent` (referencia) | — | `ExchangeRateDto[]` |
| GET | `/admin/tax-documents?clientId=&month=&year=` | `TaxDocumentsComponent` | — | `TaxDocumentDto[]` |
| POST | `/admin/tax-documents` | `TaxDocumentsComponent` registrar | `{ paymentTransactionId?, clientId, type, series, number, issueDate, currency, baseAmount, igvAmount, totalAmount, notes? }` | `TaxDocumentDto` |
| GET | `/admin/expenses?month=&year=&category=` | `ExpensesComponent` | — | `ExpenseDto[]` |
| POST | `/admin/expenses` | `ExpensesComponent` crear | `{ description, category, type, amount, currency, date, recurring, recurrenceCycle? }` | `ExpenseDto` |
| PATCH | `/admin/expenses/{id}` | `ExpensesComponent` editar | campos parciales | 200 |
| GET | `/admin/reports/sales?month=&year=&currency=PEN\|USD\|EUR` | `ReportsComponent` | — | `{ baseImponible, igv, total }` en la moneda pedida (convertido con `AmountPen` snapshot + TC del mes para USD/EUR) |
| GET | `/admin/reports/tax-summary?month=&year=` | `ReportsComponent` | — | `{ ventasGravadasPen, igvEstimado, rentaEstimada, tasa: {igvRate, rentaRate} }` — **incluye el disclaimer como campo de texto en la respuesta**, no solo en el frontend |
| GET | `/admin/reports/expenses?month=&year=` | `ReportsComponent` | — | `{ total, porCategoria: {categoria, monto}[] }` |
| GET | `/admin/reports/net?month=&year=` | `ReportsComponent` | — | `{ ventasPen, gastosPen, impuestosEstimadosPen, netoEstimadoPen }` |

### Inventario de componentes — app `portal` (Fase 7, todos SuperAdmin)

| Componente | Selector | Ruta | Notas |
|---|---|---|---|
| `TaxSettingsComponent` | `app-tax-settings` | `/admin/tax-settings` | Form simple: IGV%, Renta%, con advertencia visible de que son tasas configurables por el usuario, no validadas por el sistema. |
| `TaxDocumentsComponent` | `app-tax-documents` | `/admin/tax-documents` | Tabla + form de registro: tipo, serie, correlativo, cliente, monto, fecha. Puede vincularse a un `PaymentTransaction` existente (selector) o quedar suelto. |
| `ExpensesComponent` | `app-expenses` | `/admin/expenses` | CRUD de gastos, filtro por mes/categoría, total del período visible arriba. |
| `ReportsComponent` | `app-reports` | `/admin/reports` | Dashboard mensual: selector de mes + moneda, tarjetas de ventas/IGV/Renta estimada/gastos/neto, con el disclaimer de la API renderizado siempre visible (no solo en el primer render). |

`SidebarComponent`/drawer móvil: nuevo grupo "Finanzas" (SuperAdmin) con links a Reportes, Documentos tributarios, Gastos y Configuración de tasas.

### Checklist de tareas — Fase 7 (delegable, en orden)

- [x] **T7.0** — Investigar y confirmar el endpoint real de SUNAT para el TC diario USD/PEN (verificar formato de respuesta actual, no asumir), y elegir + confirmar la API de tipo de cambio para EUR/PEN (ej. BCRP, exchangerate-api). Documentar ambos en este plan antes de codificar el job. ✅ Verificado 2026-09-27 con fetch real a ambos endpoints:
  - **USD/PEN — SUNAT**: `GET https://www.sunat.gob.pe/a/txt/tipoCambio.txt` (público, sin token). Texto plano, una línea: `DD/MM/YYYY|compra|venta|` (ej. `27/09/2026|3.416|3.425|`). Usar **venta** (3er campo) para las conversiones tributarias (convención SUNAT). Sin fila para fines de semana/feriados → si el `GET` del día no trae la fecha esperada, reusar el `ExchangeRate` más reciente ya guardado.
  - **EUR/PEN — BCRP** (Banco Central de Reserva del Perú, API pública oficial, sin token): `GET https://estadisticas.bcrp.gob.pe/estadisticas/series/api/PD04648PD/json/{fechaInicio}/{fechaFin}` (serie "TC Euro (S/ por Euro) - Venta", formato `YYYY-MM-DD`). Responde JSON `{ periods: [{ name: "DD.Mmm.YY", values: ["3.924"] }, ...] }` — nombres de mes abreviados en español (`Set`, `Oct`, etc.), y `"n.d."` en `values` los días sin cotización (fin de semana/feriado). El job debe pedir un rango de varios días atrás y quedarse con el último valor que no sea `"n.d."`.
- [x] **T7.1** — Migración EF Core: `ExchangeRate`, `TaxDocument`, `Expense`, `TaxSettings`, `PaymentTransaction.AmountPen`/`InternalCode`. Seed de `TaxSettings` con IGV=18%/Renta=10%. Backfill de `AmountPen`/`InternalCode` para las `PaymentTransaction` ya existentes (con el TC del día más cercano disponible). ✅ Migración `20260927110418_Fase7Accounting` aplicada contra SQL Server real. `InternalCode`/`AmountPen` ahora se generan también al crear cada `PaymentTransaction` nueva (webhook de PayPal), vía `ExchangeRateQueries.RateToPenAsync` (nuevo helper compartido); backfill de las filas antiguas en `DbSeeder`.
- [x] **T7.2** — Backend: `ExchangeRateSyncJob` (Hangfire, diario) + endpoint manual `POST /api/admin/exchange-rates/sync` para forzar una corrida (útil para pruebas y para el primer backfill). ✅ Probado contra SUNAT y BCRP reales: `POST /api/admin/exchange-rates/sync` devolvió `USD=3.425 (SUNAT, 2026-09-27)` y `EUR=3.883 (BCRP, 2026-09-24 — último día con cotización, 25/26/27 sin publicar)`; reintentar el sync no duplica filas (índice único `Date+CurrencyCode`). Bug real encontrado y corregido: el WAF del BCRP (Imperva) devolvía HTML pegado al JSON en algunas respuestas — `ExchangeRateClient.GetEurAsync` ahora extrae solo el objeto JSON balanceado antes de parsear, y se agregó un `User-Agent` explícito al `HttpClient`.
- [x] **T7.3** — Backend: `GET/PATCH /api/admin/tax-settings`.
- [x] **T7.4** — Backend: `GET/POST /api/admin/tax-documents`, con generación de `InternalCode` automática cuando se crea un `PaymentTransaction` sin documento vinculado. (El `InternalCode` se genera en T7.1, en el momento de crear la `PaymentTransaction` — siempre, tenga o no un `TaxDocument` vinculado después.)
- [x] **T7.5** — Backend: `GET/POST/PATCH /api/admin/expenses`.
- [x] **T7.6** — Backend: los 4 endpoints de `/admin/reports/*`, calculando siempre a partir de `AmountPen`/`Expense.AmountPen` (nunca reconvirtiendo con el TC actual) para que un mes cerrado no cambie de valor. Decisión de modelado: `net.impuestosEstimadosPen` solo incluye Renta, no IGV (el IGV se cobra aparte y se traslada a SUNAT, no es costo de la empresa) — el detalle de IGV vive en `tax-summary`.
- [x] **T7.7** — Frontend: `TaxSettingsComponent`.
- [x] **T7.8** — Frontend: `TaxDocumentsComponent`. Simplificación consciente: el campo "transacción de pago vinculada" es un input de texto (pega el ID), no un selector con búsqueda — no había un endpoint de listado de `PaymentTransaction` sin documento en el contrato original.
- [x] **T7.9** — Frontend: `ExpensesComponent`.
- [x] **T7.10** — Frontend: `ReportsComponent` + grupo "Finanzas" en sidebar/drawer móvil.
- [x] **T7.11** — Verificación end-to-end. ✅ Probado por API real (`curl`) contra SQL Server real: `POST /admin/exchange-rates/sync` insertó USD (SUNAT) y EUR (BCRP) del día; se registró un `TaxDocument` (Factura F001-1) y un `Expense` (Hosting VPS, USD 25 → PEN 85.63 con el TC del día); `PATCH /admin/tax-settings` (IGV 18%→20%→18%) se reflejó de inmediato en `GET /admin/reports/tax-summary`; los 4 endpoints de reportes devuelven 200 con los montos esperados. **Pendiente**: verificación visual en navegador de los 4 componentes nuevos — la extensión de Chrome no estaba conectada en esta sesión; `ng build portal` y `ng serve portal` compilan sin errores, pero falta confirmar visualmente el render/las interacciones (esto lo debe hacer el usuario o una sesión con la extensión conectada).

## Supuestos a confirmar durante implementación

- Proveedor de hosting/DNS para los 3 dominios y subdominios `cms.`/`portal.`.
- Facturación electrónica/IGV Perú: la **emisión** electrónica (timbrado ante SUNAT vía PSE/OSE) sigue fuera de alcance; el **registro** de documentos ya emitidos y el cálculo estimado de IGV/Renta sí están en alcance — ver "Fase 7 — detalle".
- Si se quiere reactivar el 4º eyebrow/columna huérfanos del footer, o dejarlos fuera definitivamente (ver sección de i18n).

## Estado de la Fase 1 (actualizado 2026-09-25)

Checklist T1.0–T1.15 completo y verificado de punta a punta:
- Backend (`Rtres.Api`) corriendo contra SQL Server local (`localhost\SQLEXPRESS`, ver `appsettings.json`), con seed del cliente "Cabalgatas Andinas". Probado con `curl`: login → JWT real → `dashboard/summary`, `client-products`, `projects`, `POST tickets` responden 200 con datos reales.
- Frontend `site`: build con i18n real (`/es /en /it`, 60 mensajes traducidos) + SSR (Angular Universal, `server.ts` + prerender de las 3 rutas). Verificado sirviendo HTML renderizado en servidor vía `node dist/site/server/es/server.mjs`.
- Frontend `portal`: conectado a la API real (`AuthService`, interceptor JWT, guard de rutas, `PortalApiService`) — login, dashboard, lista de tickets y creación de tickets ya no usan mocks.
- `dotnet build`, `ng build site` y `ng build portal` compilan sin errores.

Pendiente/fuera de esta verificación: pruebas visuales pixel-a-pixel contra los mockups en navegador, y las Fases 2–6 (WordPress, PayPal, GitHub, notificaciones).

## Estado de la Fase 2 (WordPress, actualizado 2026-09-25)

**WordPress real en uso**: `https://web.rtres.net` (no `cms.rtres.net` como decía el plan original — actualizar DNS/infra cuando se defina el dominio final). Instancia existente del usuario, hosting Webempresa. Plugins instalados vía REST API (`/wp/v2/plugins`): **Polylang** (ES default, EN, IT — asistente de idiomas completado manualmente por el usuario) y **Advanced Custom Fields** (instalado pero sin usar en el alcance actual, ver nota de alcance abajo).

**Decisión de alcance** (confirmada con el usuario, más acotada que el plan original): en vez de mover las ~60 strings de copy del sitio (títulos, features, precios, FAQ) a WordPress, **se quedan como i18n build-time en Angular** (ya traducidas, ver sección de i18n de Fase 1). Lo que sí vive en WordPress y se consume vía BFF:
- **Foto del hero** (Featured Image de una Page con slug `hero`).
- **6 proyectos** (nombre, categoría traducida, foto) — Posts regulares en las categorías `proyectos-{es|en|it}`, nombre en el título (igual en los 3 idiomas), categoría en el excerpt, foto como Featured Image.
- **3 reseñas** (autor, quote traducido) — Posts regulares en `resenas-{es|en|it}`, autor en el título, quote en el content.

**Nota técnica — filtrado por idioma**: Polylang (versión free) no filtra `wp/v2/posts` por el parámetro `?lang=` vía REST (confirmado empíricamente — el parámetro se acepta pero no filtra). Se usa en su lugar una categoría por idioma (`proyectos-es`, `proyectos-en`, `proyectos-it`, etc.) como mecanismo de filtrado, ya que es 100% nativo de `wp/v2` y no depende de extensiones REST de Polylang. Los posts también llevan `lang` seteado (vía el campo aceptado en la creación) para que el editor de WordPress los vea correctamente agrupados en su propia UI.

**Advertencia operativa — rate limiting**: el hosting (Webempresa/nginx) devuelve 503 bajo ráfagas de requests (confirmado durante las pruebas de esta sesión, tanto para la API REST como para las imágenes estáticas de `wp-content/uploads`). El BFF cachea las respuestas de WordPress en memoria (`IMemoryCache`, TTL 5 min) para minimizar el impacto, pero **las imágenes se sirven con hotlink directo desde Angular al dominio de WordPress** (no pasan por el BFF ni por su caché) — si el hosting está lento/rate-limiteado, las fotos pueden fallar a cargar aunque el JSON de la API responda bien. Antes de producción: evaluar un proxy de imágenes con caché en el BFF, o un CDN delante de `web.rtres.net`.

**Backend (`Rtres.Api`)**:
- `IWordPressContentClient` (Rtres.Domain/Contracts.cs) ampliado con `GetProjectsAsync`, `GetReviewsAsync`, `GetHeroPhotoUrlAsync` (antes solo tenía `GetPageAsync`, genérico y sin usar).
- `WordPressContentClient` (Rtres.Infrastructure/IntegrationClients.cs) implementa las 3 llamadas nuevas contra `wp-json/wp/v2/{categories,posts,pages}`, con `IMemoryCache` (5 min TTL) envolviendo cada una.
- `PublicContentController`: `GET /api/public/{locale}/projects`, `GET /api/public/{locale}/reviews`, `GET /api/public/hero-photo` — sin `[Authorize]` (contenido público). Verificados con `curl` para los 3 locales, con datos reales.
- Fix de infraestructura: el `HttpClient` de `IWordPressContentClient` no llevaba `User-Agent` — el hosting de WordPress devolvía **502** silenciosamente para requests sin ese header (bug real, no cosmético). Se agregó `client.DefaultRequestHeaders.UserAgent`.
- `appsettings.json`: `WordPress:BaseUrl` → `https://web.rtres.net/`.

**Frontend (`site`)**:
- `PublicApiService` (nuevo, `core/public-api.service.ts`) con `getProjects(locale)`, `getReviews(locale)`, `getHeroPhoto()` — cada llamada con `timeout(5s)` + `catchError` a un fallback seguro (evita que WordPress lento/caído bloquee el render SSR, que tiene su propio timeout duro de 30s en `ng serve`).
- `HeroComponent`: foto ahora viene de `getHeroPhoto()` (antes hardcodeada a `picsum.photos`), con fallback al mismo picsum si falla.
- `ProjectsComponent`: los 6 proyectos ahora vienen de `getProjects(locale)` usando `LOCALE_ID` inyectado (antes array hardcodeado con IDs de picsum).
- `ReviewsComponent`: reescrito de 3 `<blockquote>` fijos con i18n a un `*ngFor` sobre `getReviews(locale)`.
- `main.ts`/`main.server.ts`: agregado `provideHttpClient(withFetch())` (necesario para que `HttpClient` funcione en el contexto Node del SSR).
- Verificado: `ng build site` prerenderiza los 3 locales con contenido real de WordPress horneado en el HTML (`grep` sobre `dist/site/browser/es/index.html` confirma nombres de proyectos, categorías y quotes reales, no placeholders).

**Pendiente dentro de Fase 2** (no bloqueante, no implementado en esta sesión): redirects 301 desde `r3solucionesweb.com`/`soluzionipersitiweb.it`, hreflang tags, auditoría Lighthouse/SEO, y decidir si mover más contenido a WordPress más adelante (el alcance actual es deliberadamente acotado).
