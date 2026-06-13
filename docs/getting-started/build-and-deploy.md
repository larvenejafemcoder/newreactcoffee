# Build & Deploy

This guide explains how to produce a production build and deploy the CyZerO site to a static hosting provider.

---

## Production Build

```bash
cd astro
npm run build
```

The build command:

1. Scans all `.astro` and `.tsx` files
2. Generates static HTML for every page
3. Bundles React JavaScript (only for hydrated components)
4. Compiles and minifies CSS
5. Copies assets from `public/` to the output
6. Writes everything to the `dist/` folder

### Output Structure

```
astro/dist/
├── index.html                 # Home page
├── clock.html                 # Clock page (or clock/index.html)
├── slider.html                # Slider page (or slider/index.html)
├── _astro/                    # Bundled JS & CSS assets
│   ├── index.*.js
│   ├── Clock.*.js
│   ├── StoreLocator.*.js
│   ├── Header.*.js
│   └── *.css
├── media-assets/              # Copied from public/media-assets/
└── styles/                    # Copied from public/styles/
```

All filenames in `_astro/` include content hashes for cache busting.

---

## Preview the Build

```bash
npm run preview
```

This starts a local static file server serving the `dist/` folder. Test your build locally before deploying.

---

## Deployment Targets

This is a fully static site. The entire `dist/` folder can be uploaded to any static host.

### Netlify

1. Push your repository to GitHub/GitLab/Bitbucket
2. Connect the repo in Netlify
3. Set:
   - **Base directory:** `astro`
   - **Build command:** `npm run build`
   - **Publish directory:** `astro/dist`
4. Deploy

### Vercel

1. Import your repository in Vercel
2. Set:
   - **Framework:** Astro
   - **Root directory:** `astro`
   - **Build command:** `npm run build`
   - **Output directory:** `dist`
3. Deploy

### Cloudflare Pages

1. Connect your Git repository
2. Set:
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
   - **Root directory:** `astro`
3. Deploy

### Manual (any static host / CDN)

```bash
cd astro
npm run build
# Upload astro/dist/ to your web server or CDN
```

---

## Post-Deployment Checklist

- [ ] All pages load without 404 errors
- [ ] Fonts render correctly (check for FOUT/FOIT)
- [ ] React components hydrate (Header menu, Clock, StoreLocator)
- [ ] Images load and are properly sized
- [ ] Meta tags are present (title, description, viewport)
- [ ] Links navigate to the correct pages
- [ ] The slider scroll-snap works in Chrome, Firefox, Safari
- [ ] The clock updates every second

---

## Next Steps

- [Static Hosting details](../deployment/static-hosting.md)
- [Troubleshooting common issues](../deployment/troubleshooting.md)
