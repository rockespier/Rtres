---
name: Rtres Web Solutions
description: White, black and green editorial design system for the public site, with a light SaaS-admin portal
colors:
  bg: "#ffffff"
  bg-alt: "#f6f7f3"
  panel-1: "#f6f7f3"
  panel-2: "#eef2e6"
  ink: "#12140f"
  muted: "#5c6355"
  green: "#4a6b1f"
  primary: "#6f9a35"
  primary-strong: "#c6f269"
  primary-dim: "#587c29"
  accent-teal: "#1f9c86"
  accent-violet: "#6b5fd1"
  warning: "#b6720a"
  bg-dark: "#0e1209"
  ink-on-dark: "#f5f7f1"
  muted-on-dark: "#a9b39c"
typography:
  display:
    fontFamily: "Space Grotesk, Inter, sans-serif"
    fontSize: "clamp(2rem, 3.5vw, 3.125rem)"
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Space Grotesk, Inter, sans-serif"
    fontSize: "clamp(2.25rem, 3.5vw, 3rem)"
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: "-0.015em"
  title:
    fontFamily: "Space Grotesk, Inter, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 600
    lineHeight: 1.25
  body:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "0.78rem"
    fontWeight: 600
    letterSpacing: "0.02em"
  accent-serif:
    fontFamily: "Instrument Serif, Georgia, serif"
    fontStyle: "italic"
    fontWeight: 400
  oversized:
    fontFamily: "Space Grotesk, sans-serif"
    fontSize: "clamp(5rem, 19vw, 15rem)"
    fontWeight: 700
    lineHeight: 0.82
    letterSpacing: "-0.03em"
rounded:
  sm: "12px"
  md: "18px"
  lg: "28px"
  pill: "999px"
spacing:
  xs: "8px"
  sm: "16px"
  md: "24px"
  lg: "40px"
  xl: "64px"
  2xl: "112px"
components:
  button-primary:
    backgroundColor: "{colors.primary-strong}"
    textColor: "{colors.ink}"
    rounded: "{rounded.pill}"
    padding: "13px 24px"
  button-ghost:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.bg}"
    rounded: "{rounded.pill}"
    padding: "13px 24px"
  card:
    backgroundColor: "{colors.panel-1}"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "36px"
  card-featured:
    backgroundColor: "{colors.panel-2}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "32px"
---

# Design System: Rtres Web Solutions

## 1. Overview

**Creative North Star: "The White Room"**

A bright, confident editorial studio — white surfaces, black type, one deliberate signal color (green) — built on the same structural devices as before (oversized outlined/filled wordmarks, duotone photography, numbered index rows, a serif-italic accent voice), now on a light canvas instead of a dark one. The system flipped from dark to light on direct client instruction, referencing an agency template (`inspiracion/2026-09-24_12-49-16.png`) that pairs white/black/green exactly this way — oversized bleeding lime wordmarks, black-and-white photography, thin black nav, solid black secondary buttons, and a black contrast band for the testimonial section.

**The one deliberate inversion:** the closing CTA band and the Reviews section stay near-black (`.on-dark`) inside an otherwise white page — a contrast "island" echoing the reference's own black testimonial band. Every other section is white. This is not a light/dark toggle; the public site has one fixed identity (white-first with two black bands), no user-facing theme switch.

The client portal (product register) is a **separate system** (`assets/portal.css` + `assets/portal.js`) — its own light SaaS-admin language (white cards, soft shadows, pastel status pills) that additionally ships an *optional* dark-mode toggle for the logged-in app. The portal's light/dark toggle and the public site's black CTA/Reviews bands are unrelated mechanisms — don't conflate them.

**Key Characteristics:**
- White background, near-black ink text, one green accent used sparingly for real emphasis (links, numerals, the giant wordmark fill) — never as body-text-sized pale green, which washes out on white (see the Contrast Rule).
- Two near-black "island" sections (closing CTA, Reviews) break the white rhythm exactly twice, matching the reference's own testimonial band — not a pattern to repeat elsewhere.
- An oversized Space Grotesk wordmark, solid-filled in Field Green (`.huge-fill`) everywhere it appears — hero, Projects, and the closing CTA — as a recurring structural device. The plain outlined `.huge` (no fill) remains available in the CSS but isn't currently used on the page.
- Ghost/secondary buttons are **solid black with white text** (not a bordered outline) — the reference's own secondary-CTA treatment, and it reinforces the white/black/green palette everywhere a button appears.
- Duotone photography (pure grayscale + a faint green-toward-ink wash) — real imagery for the hero and the Projects grid, never decorative gradient blobs.
- Numbered editorial index-rows (services, FAQ) over icon-card grids; a divided pricing "spec sheet" over three identical rounded cards; one bold rating+quote band over a 3-up testimonial grid; a Projects grid (duotone thumbnails, hover overlay) to show finished work.
- Flat, opaque panels only for the few things that need a boxed surface (pricing addons, portal). Blur/glass stays reserved for chrome that floats over scrolling content (sticky header, mobile nav).

## 2. Colors

White-first, near-monochrome (white / near-black ink / mid-gray muted), with green doing all of the accent work — used deliberately, never as decoration.

### Primary
- **Field Green** (`#6f9a35`): the fill color for buttons, the numeral/link green's large-text cousin, the giant wordmark's solid-fill state (`.huge-fill`). Large or bold contexts only — see the Contrast Rule for why.
- **Signal Lime** (`#c6f269`): brighter accent — primary button fill (dark text on top always has strong contrast against it), hover states, the "Más elegido" pricing badge.

### Text-safe green
- **Ink Green** (`#4a6b1f`): the *only* green approved for small/normal-size text (nav links, numerals, the hero's serif accent phrase, pricing eyebrow). It's darker than Field Green specifically so it clears 4.5:1 on white — Field Green and Signal Lime do not, at body-text sizes.

### Neutral
- **Paper** (`#ffffff`): page background.
- **Paper Alt** (`#f6f7f3`): top bar background, default flat panel surface.
- **Panel Tint** (`#eef2e6`): featured/elevated panel surface (featured pricing plan).
- **Ink** (`#12140f`): primary text, headings, ghost-button fill.
- **Field Gray** (`#5c6355`): secondary/muted text. Never rendered below full opacity — same Contrast Rule as before, just flipped for a light background.

### Dark island
- **Night** (`#0e1209`): the CTA band and Reviews section background — the page's one deliberate dark contrast note.
- On-dark text uses `#f5f7f1` (ink) / `#a9b39c` (muted) via the `.on-dark` scope; small/normal text there is safe because those tones were chosen against `#0e1209`, not against white.

### Named Rules
**The Contrast Rule.** Field Green (`#6f9a35`) and Signal Lime (`#c6f269`) read fine on white at large/bold sizes (≥18px, or the giant wordmark) but fail AA at body-text size — that's exactly why Ink Green (`#4a6b1f`) exists. Never use Field Green or Signal Lime for a small link, label or numeral on a white background; always use Ink Green there.

**The Two Islands Rule.** Exactly two sections invert to near-black: the closing CTA band and Reviews. Don't add a third dark section "for variety" — the contrast only works because it's rare.

## 3. Typography

**Display Font:** Space Grotesk (with Inter, system-ui fallback)
**Body Font:** Inter (with system-ui fallback)

**Character:** A geometric, slightly technical display face paired with a neutral, highly-legible workhorse body face — confident and current without being decorative. The pairing carries the "modern, trustworthy, technical" brand personality on its own, before color ever gets involved.

### Hierarchy
- **Display** (600, `clamp(2rem, 3.5vw, 3.125rem)` / 32–50px, line-height 1.1): hero headline only.
- **Headline** (600, `clamp(2.25rem, 3.5vw, 3rem)` / 36–48px, line-height 1.1): section titles (Features, Projects, Pricing, FAQ, Reviews, CTA band).
- **Title** (600, 24px, line-height 1.25): card/component titles (plan names, feature-row titles, portal page titles).
- **Body** (400–500, 15–18px, line-height 1.6, max ~70ch): paragraph copy, FAQ answers, review quotes.
- **Label** (600, 12.5px, letter-spacing 0.02em): form field labels, small status text. Used sparingly — see Do's and Don'ts on eyebrow tags.

### Named Rules
**The One Eyebrow Rule.** A small uppercase kicker above a heading is earned, not automatic. Only the hero's stat badge ("18+ years · 300+ projects") and the Pricing section's plain-text label use it; Features, Projects, FAQ and Reviews headings stand on their own.

## 4. Elevation

Flat by default. Cards, tiles, form containers and list rows are opaque panels (`panel-1`/`panel-2`) with a 1px hairline (dark-on-light) border — no blur, no translucency. Depth comes from panel-to-background contrast and soft drop shadows on floating elements (the hero's `.float-card`, project-hover states), not from glow.

Glass (translucent background + backdrop-blur) is reserved for chrome that must stay legible while content scrolls underneath it: the sticky site header and the mobile nav drawer. That is the only context where it appears — it is functional, not decorative. The light-theme glass is a translucent **white** blur (`rgba(255,255,255,.72–.92)`), not the dark theme's translucent-dark version.

### Shadow Vocabulary
- **Float-card lift** (`box-shadow: 0 30px 60px -24px rgba(18,20,15,.28)`): the hero's stat card, floating over the duotone photo.
- **Button lift** (`box-shadow: 0 8px 24px -8px rgba(111,154,53,.45)`, hover `0 14px 30px -8px rgba(111,154,53,.6)`): primary button only.

### Named Rules
**The Functional Glass Rule.** Glass/blur is applied only to elements that float over other content while scrolling. If it's resting on the page at a fixed position in the layout, it's a flat panel, not glass.

## 5. Components

### Buttons
- **Shape:** fully pill (`border-radius: 999px`).
- **Primary:** solid Signal Lime fill, near-black text, button-lift shadow, lifts 2px and deepens to Field Green on hover.
- **Ghost/secondary:** **solid black fill, white text** (not an outline) — matches the reference's black secondary-CTA pattern; inverts to black-text-on-white on hover.
- **Hover / Focus:** all interactive elements (buttons, links, form controls) get a 2px green `outline` on `:focus-visible` — never removed, never replaced with a subtler ring.

### Chips / Badges
- **Style:** pill, `panel-1` background, hairline border, muted text.
- **Plan badge:** solid Signal Lime fill with ink text (no gradient — a gradient risks the dark end of the ramp failing text contrast; see the Contrast Rule).

### Cards / Containers
- **Corner Style:** 18–28px radius depending on size.
- **Background:** `panel-1` at rest, `panel-2` for the one featured/elevated instance per section (featured pricing plan).
- **Shadow Strategy:** none at rest; see Elevation.
- **Border:** 1px hairline (`border`, dark-on-light), stepping to `border-strong` on the elevated variant.

### Photography / Project tiles
- **Duotone:** pure grayscale + a faint green-toward-ink multiply wash (`.photo-duotone`) — never full color, never the old dark gradient overlay (that was tuned for a near-black background and no longer applies).
- **Project card:** duotone thumbnail, hover reveals a dark scrim + a Signal Lime "Ver proyecto" pill (`.proj-card`/`.proj-overlay`/`.proj-pill`); caption (client name + category) sits below the tile, not on it.

### Inputs / Fields
- **Style:** subtle tinted background, hairline border, 12px radius, ink text, full-opacity muted placeholder.
- **Focus:** border shifts to primary, plus the standard 2px focus outline.

### Navigation
- **Top bar:** slim utility strip above the header — contact info (email/phone) left, language switcher + "Iniciar sesión" right. Hidden below `sm`; scrolls away normally, it is not sticky.
- **Header:** sticky, white-glass (functional exception), 3-column row — logo (80px) left, centered text nav, primary CTA right. Collapses to a white-glass mobile drawer under `lg` that carries the login link + language switcher the top bar hid.
- **Portal (separate system — see `assets/portal.css`):** white sidebar with a search field, grouped nav, user profile chip pinned at the bottom; solid white sticky topbar with a breadcrumb (no blur needed on a flat light bar). Ships its own light/dark toggle, unrelated to the public site's fixed identity.

## 6. Do's and Don'ts

### Do:
- **Do** use Ink Green (`#4a6b1f`) for any small/normal-size green text (links, numerals, nav, eyebrow labels) — Field Green and Signal Lime are for large/bold or fill contexts only.
- **Do** keep the dark "island" to exactly two sections (closing CTA, Reviews) — that's what makes the inversion read as a deliberate beat, not a mistake.
- **Do** use solid black for ghost/secondary buttons, not an outline — it's part of the white/black/green palette, not a generic secondary-button pattern.
- **Do** use an oversized, solid-filled Space Grotesk wordmark (`.huge.huge-fill`) as the public site's signature structural device — hero, Projects, and the closing CTA.
- **Do** treat photography as duotone (`.photo-duotone`) so it reads as part of the system, not a stock-photo intrusion.
- **Do** use numbered index-rows (`.num-row`) for lists of comparable items (services, FAQ) instead of a grid of icon cards.
- **Do** pair Space Grotesk (display/headline/title) with Inter (body/label) and Instrument Serif italic (one accent phrase per section, max) — never a fourth typeface.
- **Do** provide a `prefers-reduced-motion` alternative for every reveal/marquee animation (already in `assets/styles.css`).

### Don't:
- **Don't** put Field Green or Signal Lime text directly on white at body-text size — it fails contrast. Use Ink Green.
- **Don't** default to a grid of identical icon+heading+text cards for a list of features/services — use `.num-row` instead.
- **Don't** default to three identical rounded pricing cards — use the divided spec-sheet pattern (hairline columns, one plan gets a top accent bar).
- **Don't** use `background-clip: text` gradient text, or a two-stop button gradient, for emphasis — the dark end of a green gradient risks failing text contrast; use a solid fill instead.
- **Don't** put a bordered, dotted "eyebrow" pill above every section heading — reserve it for the hero's real stat badge and the Pricing label only.
- **Don't** add a third dark/inverted section beyond the CTA band and Reviews.
- **Don't** introduce a cream/beige/warm-neutral background — the base is true white (`#ffffff`), not an off-white, by direct decision.
