# Project Structure

```
newreactcoffee/
├── astro/                              # Astro project root
│   ├── astro.config.mjs                # Astro configuration (integrations, site URL)
│   ├── package.json                    # Dependencies, scripts, metadata
│   ├── tsconfig.json                   # TypeScript configuration (strict, ESNext)
│   ├── public/                         # Static assets (served as-is, no processing)
│   │   ├── media-assets/               # Images, SVGs, icons
│   │   │   ├── nav/                    # Header icons (menu, close, logo)
│   │   │   ├── imgs/                   # Slider images (1.jpg – 6.jpg)
│   │   │   └── *.png / *.jpg / *.gif   # Product & section images
│   │   └── styles/                     # Extra static styles (unused copy)
│   ├── src/
│   │   ├── components/                 # UI components
│   │   │   ├── Header.tsx              # React — fixed nav + mobile menu
│   │   │   ├── Clock.tsx               # React — analog + digital clock
│   │   │   ├── StoreLocator.tsx        # React — city/district locator
│   │   │   ├── CoffeeLoader.astro      # Pure CSS coffee machine animation
│   │   │   ├── Hero.astro              # Hero split section
│   │   │   ├── BrandStory.astro        # Brand storytelling
│   │   │   ├── FeaturedProducts.astro  # Category list
│   │   │   ├── CoffeeProductGrid.astro # 12-product editorial grid
│   │   │   ├── QualityStory.astro      # Quality sourcing stories
│   │   │   ├── InstagramFeed.astro     # Instagram-style image grid
│   │   │   ├── NewsSection.astro       # Featured news article
│   │   │   ├── Footer.astro            # Site footer
│   │   │   └── Logo.astro              # Inline logo image
│   │   ├── layouts/
│   │   │   └── Layout.astro            # HTML shell, fonts, meta tags
│   │   ├── pages/
│   │   │   ├── index.astro             # Home page (/)
│   │   │   ├── clock.astro             # Clock page (/clock)
│   │   │   └── slider.astro            # Slider page (/slider)
│   │   └── styles/
│   │       ├── global.css              # Entry point — imports core.css
│   │       ├── core.css                # Hub — imports all other CSS
│   │       ├── fonts.css               # Font usage documentation
│   │       ├── base.css                # Element resets & defaults
│   │       ├── themes/
│   │       │   └── colors.css          # CSS custom properties (palette)
│   │       ├── layout/
│   │       │   ├── container.css       # Fixed header bar
│   │       │   └── media.css           # Responsive breakpoints
│   │       ├── sections/
│   │       │   └── hero.css            # Hero section (split layout)
│   │       ├── components/             # Per-component CSS files
│   │       │   ├── brandstory.css
│   │       │   ├── clock.css
│   │       │   ├── coffeemachine.css   # CoffeeLoader animation
│   │       │   ├── coffeeproductgrid.css
│   │       │   ├── featuredproducts.css
│   │       │   ├── footer.css
│   │       │   ├── instagramfeed.css
│   │       │   ├── newssection.css
│   │       │   ├── qualitystory.css
│   │       │   ├── slider.css
│   │       │   └── storelocator.css
│   │       └── pages/
│   │           └── home.css            # Page-level wrappers
│   └── dist/                           # Build output (gitignored)
│
├── docs/                               # Documentation
│   ├── README.md
│   ├── getting-started/
│   ├── architecture/
│   ├── components/
│   ├── styling/
│   ├── content-management/
│   ├── development/
│   └── deployment/
│
└── details.md                          # Quick codebase overview (generated)
```

---

## Key Conventions

| Convention | Description |
|------------|-------------|
| **File-based routing** | Each `.astro` file in `src/pages/` becomes a route |
| **Component co-location** | All components in `src/components/`, regardless of framework |
| **CSS modularity** | One CSS file per component in `src/styles/components/` |
| **Static assets** | All images go in `public/media-assets/` |
| **React hydration** | Only 3 components use `client:load` (Header, Clock, StoreLocator) |
| **No client-side routing** | This is a multi-page static site, not an SPA |
