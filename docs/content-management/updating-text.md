# Updating Text

All visible text on the CyZerO site is hardcoded directly in the component files. There is no CMS, database, or external content source.

---

## Text Locations by Component

| Section | Component File | What to Edit |
|---------|---------------|--------------|
| **Hero headline** | `src/components/Hero.astro` | H1 text, subtitle paragraph, button text |
| **Our Story** | `src/components/BrandStory.astro` | Subtitle, title, two paragraphs, button text |
| **Categories** | `src/components/FeaturedProducts.astro` | Category name/count array in frontmatter |
| **Product Grid** | `src/components/CoffeeProductGrid.astro` | Full product array (12 items) |
| **Quality Story** | `src/components/QualityStory.astro` | Both blocks: number, heading, paragraph, button |
| **Store Locator** | `src/components/StoreLocator.tsx` | Subtitle, title, description, button text |
| **Instagram Feed** | `src/components/InstagramFeed.astro` | Title, handle, button text |
| **News Section** | `src/components/NewsSection.astro` | Label, title, meta, heading, excerpt, button |
| **Footer** | `src/components/Footer.astro` | All link labels, contact info, copyright text |
| **Header links** | `src/components/Header.tsx` | Navigation link labels |
| **Page titles** | `src/layouts/Layout.astro` | `<title>` meta tag |
| **Clock page** | `src/pages/clock.astro` | Minimal — just page structure |

---

## Editing Text in an Astro Component

```astro
<!-- Example: src/components/Hero.astro -->
---
import CoffeeLoader from './CoffeeLoader.astro';
---

<section class="main">
  <div class="left-content">
    <div class="label">Premium Coffee Culture</div>                        <!-- Edit this -->
    <h1>Seoul<br/>Coffee<br/><span class="highlight">Archive</span></h1>   <!-- Edit this -->
    <p class="subtitle">Curating the finest beans...</p>                    <!-- Edit this -->
    <button>Explore Collection</button>                                     <!-- Edit this -->
  </div>
  ...
</section>
```

Simply edit the text inside the HTML tags. No build step needed — the dev server hot-reloads.

---

## Editing Text in a React Component

```tsx
// Example: src/components/StoreLocator.tsx
<section className="store-locator">
  ...
  <h2 className="store-locator-title">Locate Your Nearest Store</h2>  {/* Edit this */}
  <p className="store-locator-text">                                   {/* Edit this */}
    With locations across Korea...
  </p>
  ...
</section>
```

---

## Best Practices

- **Keep translations consistent** — the site uses Korean and English. Maintain the same tone.
- **Preserve HTML structure** — don't remove or reorder elements unless you know the CSS.
- **Check character limits** — the layout assumes certain text lengths. Very long text may overflow.
- **Test on mobile** — shorter viewports may clip longer text.

---

## Cross-References

- [Adding Products](adding-products.md) — for the product grid array
- [Managing Images](managing-images.md) — for updating image paths
