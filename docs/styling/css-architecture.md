# CSS Architecture

This document describes how the CSS is organized, how files relate to each other, and the conventions used.

---

## File Organization

```
src/styles/
├── global.css              # Entry point — imported by Layout.astro
├── core.css                # Central hub — imports every other CSS file
├── fonts.css               # Font usage documentation (comments only)
├── base.css                # Element resets, default typography
├── themes/
│   └── colors.css          # CSS custom properties (color tokens, font variables)
├── layout/
│   ├── container.css       # Fixed header bar (position, sizing, logo, menu button)
│   └── media.css           # Global responsive breakpoints
├── sections/
│   └── hero.css            # Hero split-section layout (left text, right image)
├── components/             # One CSS file per UI component
│   ├── brandstory.css
│   ├── clock.css
│   ├── coffeemachine.css   # CoffeeLoader CSS animation + keyframes
│   ├── coffeeproductgrid.css
│   ├── featuredproducts.css
│   ├── footer.css
│   ├── instagramfeed.css
│   ├── newssection.css
│   ├── qualitystory.css
│   ├── slider.css          # Minimal: just .slider { width: 100%; }
│   └── storelocator.css
└── pages/
    └── home.css            # Page-level wrappers (.home-page, .main-content, .clock-page)
```

---

## Import Order (Why This Order Matters)

`global.css` imports `core.css`. `core.css` imports everything in this specific order:

1. **Layout first** — structural styles define the page skeleton
2. **Theme variables** — colors and fonts must be available before any component styles
3. **Base resets** — normalize element defaults
4. **Sections** — hero (the most prominent section)
5. **Components** — alphabetically ordered
6. **Page styles** — override anything for specific pages
7. **Inline styles** — menu overlay, menu box, and slider page styles

This order ensures that:

- **Variables are always defined** before they are used
- **Layout overrides** are not clobbered by component styles
- **Page-level overrides** come last for specificity wins

---

## Naming Convention

Classes follow a **component-prefixed descriptive** convention:

```
. component-name __ element -- modifier
```

| Pattern | Example | Location |
|---------|---------|----------|
| Component | `.brand-story` | Top-level section wrapper |
| Element | `.brand-story-title`, `.brand-story-text` | Child elements |
| Modifier | `.product-card.featured` | Variant state |
| Size variant | `.note-tag-sm`, `.origin-badge-sm` | Smaller version of an element |

---

## Specificity Strategy

- All selectors use **class names** (no ID selectors)
- No `!important` anywhere in the codebase
- Specificity is managed by **import order** and **selector depth**

```css
/* Low specificity — preferred */
.card-name { color: var(--cream); }

/* Medium specificity — for variants */
.product-card.featured .card-name { color: var(--latte); }
```

---

## CSS Variables vs. Hardcoded Values

| Use CSS Variables | Use Hardcoded Values |
|-------------------|---------------------|
| Colors (`--cream`, `--latte`) | Animation colors (e.g., `#74372b` for coffee liquid) |
| Font stacks (`--font-display`) | Opacity values (e.g., `0.15`, `0.6`) |
| Section backgrounds | Border radii (rarely changed) |
| Hover states | Z-index values |

The CoffeeLoader animation (`coffeemachine.css`) is the main exception — it uses hardcoded colors throughout since it's a self-contained decorative element.

---

## Inline Styles in core.css

The `core.css` file also contains inline style blocks (not `@import`) for:

1. **Menu overlay** — `.menu-overlay` backdrop with blur
2. **Menu box** — `.menu-box` slide-in panel with link animations
3. **Slider page** — `.coffee-container` scroll-snap sections

These are in `core.css` rather than separate files because they span multiple components (the menu interacts with both Header and the page layout).

---

## Key Differences from Common Patterns

| Pattern | This Project |
|---------|-------------|
| CSS Modules | Not used — global class names |
| BEM | Not strictly followed — descriptive names instead |
| CSS-in-JS | Not used |
| Preprocessor | None — plain CSS with `@import` |
| Scoped styles | Not used — Astro scoping is disabled for these styles |
