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
- **DB portal**: PostgreSQL + EF Core.
- **Jobs**: Hangfire (recordatorios de vencimiento, sync GitHub, emails).
- **Auth portal**: ASP.NET Identity + JWT, roles `Admin` / `Cliente`.

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
    public Guid Id; public Guid ClientId; public string Email; public string PasswordHash;
    public UserRole Role; // Admin, Cliente
    public bool IsActive;
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

- [ ] **T1.0** — `.gitignore`, primer `git add`/commit del estado actual (mockups + docs) antes de empezar a generar código nuevo.
- [ ] **T1.1** — Workspace Angular con las 2 apps (`site`, `portal`) + Tailwind en cada una. *Criterio: `ng serve site` y `ng serve portal` levantan una página en blanco sin errores.*
- [ ] **T1.2** — Portar tokens/CSS globales según la tabla de migración (`styles.css`→`site`, `portal.css`→`portal`, configs de Tailwind, fuentes, logo). *Criterio: abrir `ng serve site` y `ng serve portal` muestra el fondo/tipografía correctos aunque la página esté vacía.*
- [ ] **T1.3** — `.NET` solution con las 4 proyectos + referencias. *Criterio: `dotnet build` sin errores.*
- [ ] **T1.4** — Entidades de `Rtres.Domain` (modelo de arriba) + `RtresDbContext` en `Rtres.Infrastructure` + primera migración EF Core contra Postgres local. *Criterio: `dotnet ef database update` crea el schema.*
- [ ] **T1.5** — `site`: `TopBarComponent`, `SiteHeaderComponent`, `MobileMenuComponent`, `LangSwitcherComponent`, `FooterComponent` + shell de rutas `/es /en /it`. *Criterio: header/footer se ven igual que el mockup en las 3 rutas.*
- [ ] **T1.6** — `site`: `HeroComponent`, `MarqueeComponent`, `FeaturesComponent`/`NumRowComponent`, `ProjectsComponent`/`ProjectCardComponent` con datos mock calcados de `i18n.js`. *Criterio: comparación visual 1:1 contra `mockups/index.html` hasta la sección Proyectos.*
- [ ] **T1.7** — `site`: `PricingComponent`, `OnDarkSectionComponent` + `CtaBandComponent`, `FaqComponent`/`AccordionItemComponent`, `ReviewsComponent`. *Criterio: página completa visualmente idéntica al mockup, incluyendo las dos islas oscuras.*
- [ ] **T1.8** — i18n build-time: resolver las 5 keys huérfanas (decidir restaurar o borrar), agregar la key faltante del link "Preview del portal", corregir el `alt` de las fotos de proyecto para que sí se traduzca; generar builds `/es /en /it` con `ng build --localize`. *Criterio: `ng build site --localize` genera 3 carpetas de salida sin warnings de i18n.*
- [ ] **T1.9** — `portal`: `PortalShellComponent`, `SidebarComponent`, `TopbarComponent`, `ThemeToggleComponent` + `ThemeService` (con el script anti-FOUC en `index.html`). *Criterio: toggle de modo oscuro persiste entre recargas, igual que el mockup.*
- [ ] **T1.10** — `portal`: `LoginComponent` con formulario reactivo real (sin backend todavía — puede simular con un servicio mock que resuelve tras 500ms). *Criterio: validaciones de email/password funcionan, error visible si se deja vacío.*
- [ ] **T1.11** — `portal`: `DashboardComponent`, `StatCardComponent`, `ProductCardComponent` con datos mock calcados de los 5 cards del mockup. *Criterio: visualmente idéntico a `dashboard.html`.*
- [ ] **T1.12** — `portal`: `TicketsListComponent`, `TicketTableComponent`, `StatusPillComponent` con los 4 tickets mock del catálogo. *Criterio: visualmente idéntico a `tickets.html`, incluyendo los 4 valores de estado distintos.*
- [ ] **T1.13** — `portal`: `TicketFormComponent` (reactive form completo, los 11 campos listados), `TicketPreviewCardComponent`, `FileDropzoneComponent` (input real). *Criterio: alternar Soporte/Cambio muestra/oculta "Impacto" y el preview se actualiza en vivo, igual que `syncPreview()` en el mockup.*
- [ ] **T1.14** — `Rtres.Api`: controllers + DTOs para los 8 endpoints del contrato de Fase 1, con datos desde Postgres (seed manual del cliente/proyecto "Cabalgatas Andinas" para probar). Auth con ASP.NET Identity + JWT. CORS habilitado para los dos orígenes de Angular en dev. *Criterio: Swagger muestra los 8 endpoints y responden 200 con el seed de datos.*
- [ ] **T1.15** — Conectar `portal` a la API real: reemplazar todos los mocks de T1.10-T1.13 por `HttpClient` + interceptor de JWT + guard de ruta. *Criterio: login real, dashboard y tickets muestran datos que vienen de Postgres, no hardcodeados.*

Las tareas T1.5–T1.8 (sitio) y T1.9–T1.13 (portal) son independientes entre sí y pueden delegarse/paralelizarse a dos personas o dos sesiones distintas una vez completadas T1.1–T1.4.

## Fases siguientes (sin detallar todavía, se profundizan cuando toquen)

2. **Sitio público conectado a WordPress**: BFF consume `cms.rtres.net`, reemplaza los mocks de contenido de T1.6-T1.7; redirects 301 desde los otros 2 dominios; hreflang; Lighthouse SEO.
3. **Portal — roles y alta de clientes**: pantallas de `Facturación`/`Perfil` (hoy stubs), gestión de usuarios por Admin.
4. **Suscripciones PayPal**: Orders API (pagos únicos) + Subscriptions API (recurrentes), webhooks, botón "Renovar ahora"/"Gestionar suscripción" con acción real.
5. **Tickets ↔ GitHub**: Octokit crea el Issue al enviar `TicketFormComponent`, labels, webhook de vuelta actualiza `TicketStatus` y dispara notificación.
6. **Notificaciones**: Hangfire job diario de vencimientos, emails de cambio de estado, plantillas ES/EN/IT.

## Supuestos a confirmar durante implementación

- Proveedor de hosting/DNS para los 3 dominios y subdominios `cms.`/`portal.`.
- Facturación electrónica/IGV Perú: fuera de alcance de este plan.
- Si se quiere reactivar el 4º eyebrow/columna huérfanos del footer, o dejarlos fuera definitivamente (ver sección de i18n).

## Nota sobre esta ejecución (Codex rescue en curso)

Se delegó la implementación a un Codex Task en segundo plano (`task-mufm58e8-q9389h`) **antes** de que este archivo tuviera la versión detallada — Codex arrancó leyendo la versión anterior, más corta (sin el detalle de las 2 apps Angular, el modelo de datos exacto, el inventario de componentes ni el checklist T1.x). Al momento de escribir esta nota, Codex ya generó la solución .NET (`src/api/Rtres.slnx` + los 4 proyectos) y aún no había tocado Angular. Revisar el resultado de Codex contra este PLAN.md detallado al terminar, en particular: (a) si generó una o dos apps Angular, (b) si los nombres de campos de las entidades coinciden con el modelo de arriba, (c) si el checklist T1.x quedó cubierto.
