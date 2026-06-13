# Development

This guide covers the day-to-day development workflow for the CyZerO project.

---

## Dev Server

Start the development server with hot module replacement (HMR):

```bash
cd astro
npm run dev
```

Astro will output:

```
  🚀  astro  v5.5.0 started in 300ms
  ┃ Local    http://localhost:4321
  ┃ Network  http://192.168.x.x:4321
```

### Hot Module Replacement

- **Astro components (`.astro`)** — full page refresh on save
- **React components (`.tsx`)** — fast HMR without losing state
- **CSS files** — instant style injection without page reload
- **Images in `public/`** — refresh the browser to see new assets

---

## Browser DevTools

### Astro DevToolbar

Astro's built-in DevToolbar is **disabled** in this project (`astro.config.mjs`):

```js
devToolbar: { enabled: false }
```

### Standard Browser Tools

| Tool | Use |
|------|-----|
| **Elements Panel** | Inspect the generated HTML and applied CSS |
| **Console** | Check for hydration errors or missing assets |
| **Network Tab** | Verify font CDN loading and image delivery |
| **React DevTools** | Inspect React component state and props |

> **Tip:** Install [React Developer Tools](https://react.dev/learn/react-developer-tools) to debug Header, Clock, and StoreLocator components.

---

## Common Development Tasks

### Edit a section's text content

Open the corresponding Astro component in `src/components/`:

```bash
code src/components/Hero.astro       # Hero section text
code src/components/BrandStory.astro  # Brand storytelling
code src/components/Footer.astro      # Footer links and contact
```

### Modify styles

All CSS is in `src/styles/`. The most common files:

```bash
code src/styles/themes/colors.css          # Color variables
code src/styles/components/brandstory.css  # BrandStory section
code src/styles/components/clock.css       # Clock styles
code src/styles/layout/container.css       # Header bar
```

### Add a new page

1. Create a new `.astro` file in `src/pages/`
2. Import and use `Layout.astro` as a wrapper
3. Add your components inside the `<Layout>` tags
4. The page is automatically available at the corresponding route

---

## Linting

```bash
npm run lint        # Check for lint errors
npm run lint:fix    # Auto-fix fixable issues
```

See the [Linting & Formatting guide](../development/linting-and-formatting.md) for details.

---

## Next Steps

- [Build & Deploy](build-and-deploy.md) — how to create a production build
- [Project Structure](project-structure.md) — understand every folder and file
