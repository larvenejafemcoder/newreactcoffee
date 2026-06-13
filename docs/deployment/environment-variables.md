# Environment Variables

The CyZerO project currently has **no environment variables configured**.

---

## Current State

The site is fully static with no API keys, database URLs, or service credentials. All content is hardcoded in components and all assets are served from the `public/` directory.

---

## Future Use (When Needed)

If the project later integrates a service that requires environment variables, follow Astro's convention:

### Define Variables

Create `.env` files in the `astro/` directory:

```
astro/
├── .env                  # Used in all environments
├── .env.development      # Dev-only overrides
├── .env.production       # Prod-only overrides
└── .env.local            # Local overrides (gitignored)
```

### Naming Convention

```bash
# Prefix public variables with PUBLIC_
PUBLIC_API_URL=https://api.example.com
PUBLIC_GA_ID=G-XXXXXXXXXX

# Private variables (server-only during build)
CONTENTFUL_SPACE_ID=abc123
CONTENTFUL_ACCESS_TOKEN=xyz789
```

> **Important:** Only variables prefixed with `PUBLIC_` are available in client-side code. Private variables are only available in Astro frontmatter and server endpoints.

### Accessing Variables

```astro
---
// In frontmatter (build-time):
const apiUrl = import.meta.env.PUBLIC_API_URL
const spaceId = import.meta.env.CONTENTFUL_SPACE_ID
---
```

### Type Safety

For type-safe environment variables, define the schema in `astro.config.mjs`:

```js
export default defineConfig({
  env: {
    schema: {
      PUBLIC_API_URL: { type: 'string', default: 'https://api.example.com' },
      PUBLIC_GA_ID: { type: 'string', optional: true },
    },
  },
});
```

---

## Deployment Platform Configuration

### Netlify

Add variables in **Site settings → Environment variables**:

```bash
PUBLIC_API_URL=https://api.example.com
```

### Vercel

Add variables in **Project Settings → Environment Variables**:

```bash
PUBLIC_API_URL=https://api.example.com
```

### Cloudflare Pages

Add variables in **Project Settings → Environment Variables**:

```bash
PUBLIC_API_URL=https://api.example.com
```
