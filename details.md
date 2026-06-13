# CyZerO — Seoul Coffee Archive: Codebase Overview

## Project Structure

```
newreactcoffee/
├── astro/                          # Main Astro project
│   ├── astro.config.mjs            # Astro configuration
│   ├── package.json                # Dependencies & scripts
│   ├── tsconfig.json               # TypeScript configuration
│   ├── public/                     # Static assets (images, etc.)
│   ├── src/
│   │   ├── components/             # UI components (Astro + React)
│   │   ├── layouts/                # Layout wrapper
│   │   ├── pages/                  # Route pages
│   │   └── styles/                 # CSS stylesheets
│   └── dist/                       # Build output
├── docs/                           # Unrelated EventFlow docs
└── details.md                      # This file
```

**Framework:** [Astro](https://astro.build) v5.5.0 with the `@astrojs/react` integration for interactive React islands.  
**Dependencies:** React 18, TypeScript 5.  
**Fonts:** Pretendard Variable (body), SUIT Variable (headings), JetBrains Mono (labels), Noto Sans KR (Korean fallback) — all loaded via CDN in `Layout.astro`.

---

## Configuration Files

### `astro/package.json`
- Project name: `cyzero-astro`, private.
- Scripts: `dev` (astro dev), `build` (astro build), `preview` (astro preview), `lint`/`lint:fix` (ESLint on `.astro, .ts, .tsx` files).
- Dependencies: `astro`, `@astrojs/react`, `react`, `react-dom`.
- DevDependencies: `@types/react`, `@types/react-dom`, `typescript`.

### `astro/astro.config.mjs`
- Integrates `@astrojs/react` for React component support.
- Site URL: `http://localhost:4321`.
- DevToolbar disabled.

### `astro/tsconfig.json`
- Targets ESNext, uses `react-jsx` JSX transform, `Bundler` module resolution.
- Strict mode enabled. Includes only the `src/` directory.

---

## Entry Point & Layout

### `src/layouts/Layout.astro`
The root HTML wrapper. Sets `<html lang="ko">`, includes meta tags, viewport, and CDN font links for Pretendard, SUIT, JetBrains Mono, and Noto Sans KR. The page content is injected via Astro's `<slot />` into the `<body>`.

### `src/styles/global.css`
Entry CSS that imports `core.css`. Sets `html, body` to `height: auto; min-height: 100%` and `main` to `min-height: calc(100vh - 90px)`.

### `src/styles/core.css`
The CSS hub that imports all other stylesheets in order:
1. **`layout/container.css`** — Fixed top header bar styling (`.container`): 72px tall, translucent dark background with blur, border-bottom accent, logo and menu button positioning. Responsive breakpoint at 768px.
2. **`layout/media.css`** — Responsive adjustments for 1280×720, 1024px, 768px, and 1921px+ widths. Adjusts header height, hero font sizes, menu link sizes, and slider section heights.
3. **`themes/colors.css`** — CSS custom properties (variables) defining the entire color palette: `--espresso`, `--dark-roast`, `--cream`, `--latte`, `--caramel`, `--mocha`, `--matcha`, `--gold`, `--warm-brown`, `--cinnamon`, `--toast`, etc. Also defines font family variables (`--font-display`, `--font-body`, `--font-label`) and some HSL color tokens.
4. **`fonts.css`** — Comment-only file documenting which fonts are used where.
5. **`base.css`** — Global element resets: `body` margin/padding, background `--dark-roast`, text `--cream`, font `--font-body`. Headings use `--font-display` with weight 800. Links inherit cream with hover-to-caramel transition. Custom `::selection` style.
6. Component CSS files (slider, hero, coffeemachine, clock, brandstory, featuredproducts, coffeeproductgrid, qualitystory, storelocator, instagramfeed, newssection, footer).
7. **`pages/home.css`** — `.home-page` full-width container, `.main-content` wrapper, `.clock-page` centered flex layout.
8. Inline in `core.css`: **menu overlay** (fixed backdrop with blur + opacity transition) and **menu box** (slide-in from right, 35% width on desktop, 100% on mobile, with staggered link animations). Also **slider page styles** — full-height vertical scroll-snap sections with alternating purple backgrounds.

---

## Pages

### `src/pages/index.astro` — Home Page
Imports and arranges every section component in order:
1. `Header` (client:load — hydrates on page load)
2. `Hero`, `BrandStory`, `FeaturedProducts`, `CoffeeProductGrid`, `QualityStory`
3. `StoreLocator` (client:load)
4. `InstagramFeed`, `NewsSection`, `Footer`

All wrapped in `<Layout>` and a `.home-page` div.

### `src/pages/clock.astro` — Clock Page
A full-page analog + digital clock. Uses `Header` and `Clock` components, both with `client:load`.

### `src/pages/slider.astro` — Showcase Slider
A scroll-snap vertical slider displaying 6 images from `/media-assets/imgs/` (1.jpg through 6.jpg), plus a final "Go Back" link section. Uses `Header` with `client:load`.

---

## Components

### `src/components/Header.tsx` (React)
A fixed top navigation bar with:
- **State:** `open` (menu toggle), `iconSrc` (menu/close icon swap), `isMobile` (responsive detection).
- **Effects:** Resize listener to track mobile (<768px). Body scroll lock when menu is open.
- **Renders:** A header bar with logo (links to `/`) and a toggle button. The slide-in menu (`#main-menu`) contains links to Home, Showcase, Clock, Journal. A backdrop overlay covers the page when open. Links call `close()` to dismiss the menu on navigation.

### `src/components/Hero.astro`
The hero section split into two halves:
- **Left:** "Premium Coffee Culture" label, large heading "Seoul Coffee Archive" (with gradient-highlighted "Archive"), subtitle, and "Explore Collection" button.
- **Right:** Background image (`home.jpg`) with gradient overlays, containing the `CoffeeLoader` animation component.

### `src/components/CoffeeLoader.astro`
A pure CSS coffee machine animation built from nested divs:
- **Coffee header** — buttons, display screen, details.
- **Coffee medium** — exit chute, arm, liquid stream (animated via `@keyframes liquid`), cup with handle.
- **Smoke wisps** — 4 elements animated with `@keyframes smoke` (rising and fading).
- All styles in `coffeemachine.css` with vendor-prefixed keyframes.

### `src/components/BrandStory.astro`
Two-column "Our Story" section:
- Left: image (`home.jpg`) with scale-on-hover and a subtle border overlay.
- Right: two paragraphs of brand storytelling and a "Discover More →" outlined button.

### `src/components/FeaturedProducts.astro`
Displays 5 product categories (Coffee, Tea, Latte & Frappe, Signature Food, Pastry & More) with item counts. Left column is an interactive list with hover effects (gold left-border + background). Right column shows a coffee image with a radial glow overlay.

### `src/components/CoffeeProductGrid.astro`
A 12-product editorial grid using CSS Grid Template Areas. Products are typed as a `Product` interface with fields: number, name, subtitle, image, price, origin, roast, notes, description, featured, gridArea, link.

**Featured cards** (3 items) take 2×2 grid cells — they show a large image with roast badge, product details, origin badge, description, and flavor-note tags.

**Standard cards** (9 items) take 1×1 cells — they show a smaller image with number overlay and roast dot. On hover, an overlay slides in with origin, description, and notes.

A helper function `getRoastColor()` maps roast levels to hex colors for the roast dot.

### `src/components/QualityStory.astro`
Two alternating story blocks about coffee and tea quality sourcing. Each has an image, number (01, 02), heading, paragraph, and "Learn More →" button. The second block uses `.reverse` class for RTL layout (image on left, text on right).

### `src/components/StoreLocator.tsx` (React)
An interactive store locator form:
- **State:** `selectedCity`, `selectedDistrict`.
- Two dropdowns — City (Seoul, Busan, Daegu, Incheon, Gwangju) and District (cascading based on selected city).
- A "View Store List →" button.
- Decorative SVG map pin icons at the bottom.

### `src/components/Clock.tsx` (React)
A combination analog + digital clock:
- **State:** `time` (updated every second via `setInterval`).
- **Analog face:** 12 hour markers (3 major at 0°/90°/180°/270°), three rotating hands (hour, minute, second) with angles calculated from current time. Center dot with glow.
- **Digital display:** Formatted `HH:MM:SS` time and full date string (e.g., "Saturday, June 13, 2026").

### `src/components/InstagramFeed.astro`
A 3-column grid (2-column on mobile) of 6 coffee images. Header has "Follow Us" title, `@cyzero_coffee` handle, and "Follow on Instagram →" button. Images scale on hover.

### `src/components/NewsSection.astro`
A featured news article layout:
- Left: full-height image with scale-on-hover.
- Right: category + date meta, article title, excerpt paragraph, "Read More →" button.

### `src/components/Footer.astro`
Four-column footer grid (2-col on tablet, 1-col on mobile):
1. **About:** Our Story, Brand Heritage, Careers, News links.
2. **Policy:** Terms, Privacy, Shipping, Returns links.
3. **Contact:** HQ address (Hanoi), phone (1800 6936), email (support@cyzero.com).
4. **Get the App:** App image + social media icons (Facebook, YouTube, Instagram) as inline SVGs.

Bottom bar: copyright, company registration info, and address.

### `src/components/Logo.astro`
Simple inline image component for the logo (`logo1.png`).

---

## Styling Architecture

The CSS is modular, organized by type:

| Directory | Purpose |
|-----------|---------|
| `themes/` | Color tokens and font variables |
| `layout/` | Structural components (header container, responsive media queries) |
| `sections/` | Full-page sections (hero) |
| `components/` | Individual component styles |
| `pages/` | Page-level wrappers |

All CSS uses the project's custom properties (e.g., `var(--latte)`, `var(--cream)`, `var(--dark-roast)`) for a consistent coffee-themed palette: deep brown backgrounds, cream/white text, gold/latte accents, and caramel highlights.

---

## Build & Development

- `npm run dev` — Start dev server at `http://localhost:4321`
- `npm run build` — Static build to `dist/`
- `npm run preview` — Preview the build
- `npm run lint` / `npm run lint:fix` — ESLint on source files

The site is configured as a static site (`output: 'static'` in Astro). React components are hydrated selectively using `client:load` directive (for Header, StoreLocator, Clock) to keep the initial HTML lightweight.
