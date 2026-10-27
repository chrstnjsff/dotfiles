---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.css"
  - "**/*.scss"
  - "**/*.html"
  - "**/components/**"
  - "**/pages/**"
  - "**/views/**"
  - "**/layouts/**"
  - "**/styles/**"
---

# Frontend Rules

## Stack Identification

**Read the codebase before writing any frontend code.**
Identify the frontend framework, bundler, and language each app uses.
Never introduce another framework or a second bundler into an app, and never mix component code between apps.

## Design Tokens (mandatory first step)

Before writing any frontend code, locate the existing tokens file (`tokens.css`, `variables.css`, `theme.ts`, `tailwind.config.*`, `_variables.scss`, `:root` in a global stylesheet). If none exists, create one.

Required token categories: colors (semantic names with dark mode variants), spacing scale, border radius, shadows (elevation system), typography (display + body + mono fonts, type scale, weights), breakpoints, transitions (durations + easing), z-index scale.

**Never hardcode raw hex, rgb, px, or rem values in components.** All values must reference tokens.

## Design Direction - Premium UI Required

The UI must feel modern, trustworthy, and premium.
Generic AI-generated aesthetics are not acceptable.

**For dashboards and data-heavy views:** Glassmorphism or Bento Grid with Material Elevation.
**For marketing and content pages:** Aurora / Mesh Gradients or Editorial with strong typographic hierarchy.
**For modals, drawers, settings panels:** Glassmorphism with subtle blur and layered transparencies.

Pick one primary principle per screen.
Do not mix randomly.

### Typography: AI Slop Blacklist

NEVER use these as display fonts: Inter, Roboto, Open Sans, Lato, Arial, Helvetica, system-ui. That is the default AI-generated look.

| Use case | Reach for |
|---|---|
| Dashboards, data | Space Grotesk, IBM Plex Sans, Plus Jakarta Sans |
| Marketing, editorial | Bricolage Grotesque, Fraunces, Clash Display |
| Mono / code | JetBrains Mono, Fira Code, Space Mono |

Weight extremes: pair 200 with 800, not 400 with 600. Size jumps of 3x minimum (16px body → 48px heading).

### Color: Anti-Slop Rules

- All colors through tokens. Zero raw hex or rgb in components.
- Dominant color with sharp accents beats evenly-distributed palettes.
- Dark themes: never pure `#000`, use `#0a0a0a`, `#111`, `#1a1a2e`.
- Light themes: never pure `#fff`, use `#fafafa`, `#f8f7f4`, `#fef9ef`.
- **NEVER purple gradient on white.** That is the single highest-signal AI slop indicator.

### Backgrounds and Motion

- Never flat solid color backgrounds. Use gradient meshes, noise textures, or layered transparencies.
- Animate only `transform` and `opacity`. Never animate `width`, `height`, or `top/left`.
- Respect `prefers-reduced-motion`. One orchestrated page-load reveal beats scattered micro-interactions.

## Component Framework

Use what the project already has.
Do not introduce a competing library.

| Category | Typical choices |
|---|---|
| CSS | Tailwind or CSS Modules |
| Primitives | shadcn/ui or Radix |
| Animation | Framer Motion or CSS transitions |
| Charts | Recharts or Visx |
| Icons | Lucide |

## Layout

- CSS Grid for 2D layouts, Flexbox for 1D. Use `gap`, never margin hacks.
- Semantic HTML: `<header>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`.
- Mobile-first at 320px. Touch targets: minimum 44x44px.
- Whitespace is a design element, use 2x more than feels "enough."

## Accessibility (non-negotiable)

- All interactive elements keyboard-accessible.
- Images: meaningful `alt` text. Decorative: `alt=""`.
- Form inputs: associated `<label>` or `aria-label`.
- Contrast: 4.5:1 normal text, 3:1 large text.
- Visible focus indicators, never `outline: none` without a replacement.
- Color never the sole indicator.
- `aria-live` for dynamic content. Respect `prefers-reduced-motion` and `prefers-color-scheme`.

## Performance

- Images: `loading="lazy"` below fold, explicit `width`/`height`.
- Fonts: `font-display: swap`.
- Large lists: virtualize at 100+ items.
- Bundle size: never import a whole library for one function.
- Use the bundler's dynamic `import()` for route-level code splitting.
- In Next.js, use `next/image`, `next/font`, and `next/dynamic` appropriately.

## Anti-Patterns (NEVER)

- Raw colors or spacing hardcoded in components.
- Inter, Roboto, Arial as display fonts.
- Purple gradient on white.
- Centered-everything layouts with uniform rounded corners.
- Gray text on colored backgrounds (fails contrast).
- Cards inside cards inside cards.
- `!important` unless overriding third-party CSS.
- Introducing a new library when the project already has one in that category.
- Cookie-cutter layouts: hero → three feature cards → testimonials → CTA.
