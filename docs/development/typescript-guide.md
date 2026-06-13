# TypeScript Guide

TypeScript is used for type safety across the project. Strict mode is enabled.

---

## Configuration

`astro/tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "ESNext"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "strict": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src"]
}
```

---

## Key Compiler Options

| Option | Value | Effect |
|--------|-------|--------|
| `strict` | `true` | All strict checks enabled (`noImplicitAny`, `strictNullChecks`, etc.) |
| `jsx` | `react-jsx` | Modern JSX transform (no need to import React) |
| `moduleResolution` | `Bundler` | Compatible with Astro/Vite module resolution |
| `target` | `ESNext` | Modern JavaScript output |

---

## TypeScript in React Components

### Component with State

```tsx
import { useState, useEffect } from 'react'

export default function Header() {
  const [open, setOpen] = useState<boolean>(false)          // Explicit type
  const [iconSrc, setIconSrc] = useState<string>('/menu.png') // Inferred as string
  const [isMobile, setIsMobile] = useState<boolean>(false)
  // ...
}
```

> **Tip:** TypeScript infers the type from the initial value. Explicit annotations are optional but improve readability.

### Component with Props (future use)

```tsx
interface ButtonProps {
  label: string
  onClick: () => void
  variant?: 'primary' | 'secondary'  // Optional with union type
}

export default function Button({ label, onClick, variant = 'primary' }: ButtonProps) {
  return <button className={`btn-${variant}`} onClick={onClick}>{label}</button>
}
```

---

## TypeScript in Astro Frontmatter

The CoffeeProductGrid component defines a typed interface in its frontmatter:

```astro
---
interface Product {
  number: string
  name: string
  subtitle: string
  image: string
  price: string
  origin: string
  roast: string
  notes: string[]
  description: string
  featured: boolean
  gridArea: string
  link: string
}
```

This gives full type checking and autocompletion for the `products` array and any functions that process it:

```astro
---
function getRoastColor(roast: string): string {
  const colors: Record<string, string> = { ... }
  return colors[roast] || '#8B6914'
}

const products: Product[] = [ ... ]
---
```

---

## TypeScript in Event Handlers

```tsx
// Inferred types from the event objects
onChange={(e: React.ChangeEvent<HTMLSelectElement>) => {
  setSelectedCity(e.target.value)
}}
```

---

## Adding Types for New Features

1. Define an interface in the component file or in a shared `types/` directory
2. Use the interface for props, state, and data arrays
3. Consider extracting shared types to `src/types/` if multiple components use them

```tsx
// src/types/menu.ts
export interface MenuItem {
  label: string
  href: string
}
```
