# Astro Components

These components render entirely at build time. They produce static HTML with no client-side JavaScript.

---

## Component List

| Component | File | Purpose |
|-----------|------|---------|
| **Hero** | `Hero.astro` | Split hero with headline, subtitle, CTA button |
| **CoffeeLoader** | `CoffeeLoader.astro` | Pure CSS coffee machine animation |
| **BrandStory** | `BrandStory.astro` | "Our Story" section with image + text |
| **FeaturedProducts** | `FeaturedProducts.astro` | Category list with item counts |
| **CoffeeProductGrid** | `CoffeeProductGrid.astro` | 12-product editorial grid |
| **QualityStory** | `QualityStory.astro` | Two alternating quality stories |
| **InstagramFeed** | `InstagramFeed.astro` | 6-image grid with Instagram CTA |
| **NewsSection** | `NewsSection.astro` | Featured news article layout |
| **Footer** | `Footer.astro` | Site footer with links, contact, social |
| **Logo** | `Logo.astro` | Inline logo image |
| **Layout** | `Layout.astro` | HTML shell with CDN fonts + meta tags |

---

## Why Static?

These components don't need interactivity — they display fixed content (text, images, links). Rendering them at build time:

- **Zero JavaScript** — no client-side overhead
- **Instant rendering** — HTML arrives fully formed
- **SEO-friendly** — all content is in the initial HTML
- **Easier to maintain** — no state management to debug

---

## Typical Astro Component Pattern

```astro
---
// Frontmatter — runs at build time
const items = [
  { name: 'COFFEE', count: 17 },
  { name: 'TEA', count: 4 },
];
---

<!-- Template — produces static HTML -->
<section class="featured-products">
  <div class="featured-products-container">
    <div class="featured-products-subtitle">Categories</div>
    <h2 class="featured-products-title">Our Collection</h2>
    <div class="categories-list">
      {items.map((item) => (
        <div class="category-item">
          <span class="category-name">{item.name}</span>
          <span class="category-count">({item.count})</span>
        </div>
      ))}
    </div>
  </div>
</section>
```

---

## When to Choose Astro vs. React

| Use Astro (static) when... | Use React when... |
|---------------------------|-------------------|
| Content is fixed or hardcoded | Content changes dynamically |
| No user interaction needed | User clicks, types, or toggles |
| Pure presentation | Real-time updates (clock) |
| Images and text only | Form inputs or dropdowns |
| SEO-critical content | Scroll handlers or animations |

---

## Content Data in Astro Components

Most static content lives directly in the component files:

| Component | Data Source |
|-----------|------------|
| Hero | Hardcoded text |
| BrandStory | Hardcoded paragraphs |
| FeaturedProducts | Array in frontmatter |
| CoffeeProductGrid | Typed array (12 products) |
| QualityStory | Hardcoded text per block |
| InstagramFeed | Image array |
| NewsSection | Hardcoded text |
| Footer | Hardcoded links + contact |
