# Editing Sections

The home page is a linear composition of sections. This guide explains how to add, remove, or reorder them.

---

## Section Order

The current order is defined in `src/pages/index.astro`:

```astro
<main class="main-content">
  <Hero />
  <BrandStory />
  <FeaturedProducts />
  <CoffeeProductGrid />
  <QualityStory />
  <StoreLocator client:load />
  <InstagramFeed />
  <NewsSection />
</main>
```

---

## Reordering Sections

Simply move the component tag to change the order on the page:

```astro
<main class="main-content">
  <InstagramFeed />            <!-- Moved to top -->
  <Hero />
  <BrandStory />
  <FeaturedProducts />
  <CoffeeProductGrid />
  <QualityStory />
  <StoreLocator client:load />
  <NewsSection />
</main>
```

---

## Adding a New Section

1. Create the component file in `src/components/`:

```astro
---
---

<section class="new-section">
  <div class="new-section-container">
    <h2>New Section Title</h2>
    <p>Content goes here.</p>
  </div>
</section>
```

2. Add its styles in `src/styles/components/` and import in `core.css`:

```css
@import './components/newsection.css';
```

3. Import and use it in `index.astro`:

```astro
---
import NewSection from '../components/NewSection.astro';
---

<main class="main-content">
  <Hero />
  <NewSection />    <!-- Inserted here -->
  <BrandStory />
  ...
</main>
```

---

## Removing a Section

1. Delete the component tag from `index.astro`

2. Optionally delete the component file and its CSS file

3. Remove the `@import` line from `core.css`

---

## Making a Section Interactive

To convert a static Astro section to a React interactive island:

1. Rename the file from `.astro` to `.tsx`
2. Add React state/effects as needed
3. Add `client:load` to the component usage in `index.astro`

---

## Common Section Layout Patterns

Most sections follow this structure:

```astro
<section class="section-name">           <!-- Outer wrapper -->
  <div class="section-name-container">   <!-- Max-width container -->
    <div class="section-name-subtitle">Label</div>
    <h2 class="section-name-title">Heading</h2>
    <!-- Content (grid, list, text, image) -->
    <a href="/link" class="section-name-btn">CTA →</a>
  </div>
</section>
```

The CSS typically includes a `::before` pseudo-element for the top gradient separator line.
