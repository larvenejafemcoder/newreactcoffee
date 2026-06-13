# Routing

CyZerO uses Astro's **file-based routing**. Every `.astro` file in `src/pages/` automatically becomes a route at the corresponding URL path.

---

## Route Map

| File | Route | Page |
|------|-------|------|
| `src/pages/index.astro` | `/` | Home page — the full brand showcase |
| `src/pages/clock.astro` | `/clock` | Analog + digital clock |
| `src/pages/slider.astro` | `/slider` | Full-screen image slider |

---

## How It Works

Astro scans `src/pages/` at build time and generates one HTML file per page:

```
src/pages/index.astro   →   dist/index.html
src/pages/clock.astro   →   dist/clock.html
src/pages/slider.astro  →   dist/slider.html
```

With Astro's default `trailingSlash: 'ignore'` setting, visitors can access `/clock` or `/clock/` — both resolve to the same page.

---

## Internal Navigation

Links between pages use standard `<a>` tags:

```astro
<!-- Header.tsx -->
<a href="/">Home</a>
<a href="/slider">Showcase</a>
<a href="/clock">Clock</a>
```

Since this is a **multi-page application** (not an SPA), each navigation triggers a full page load. There is no client-side router.

---

## Adding a New Page

1. Create a new file in `src/pages/` (e.g., `about.astro`)

2. Use the `Layout` component:

```astro
---
import Layout from '../layouts/Layout.astro';
import Header from '../components/Header';
---

<Layout>
  <Header client:load />
  <main>
    <h1>About Us</h1>
    <!-- your content -->
  </main>
</Layout>
```

3. The page is automatically available at `/about`

4. Add a link to it in `Header.tsx`:

```tsx
<li><a href="/about" onClick={close}>About</a></li>
```

---

## 404 Handling

Astro automatically generates a 404 page at `dist/404.html`. To customize it, create `src/pages/404.astro`. The project currently does not have a custom 404 page — it falls back to Astro's default.

---

## Redirects

The project currently has no redirects configured. To add them, use Astro's `redirects` config in `astro.config.mjs`:

```js
export default defineConfig({
  redirects: {
    '/old-path': '/new-path',
  },
});
```

---

## Next Steps

- [Layout.astro](../getting-started/project-structure.md) — the HTML shell used by every page
- [Header & Menu](../components/header-and-menu.md) — navigation component
