# Installation

This guide covers setting up the CyZerO project on your local machine.

---

## Prerequisites

- **Node.js** v18.0.0 or higher (recommended: v20 LTS)
- **npm** v9+ (ships with Node.js)
- A code editor (VS Code recommended with the [Astro extension](https://marketplace.visualstudio.com/items?itemName=astro-build.astro-vscode))

> **Note:** This project does not use a separate backend. All content is static and built at compile time.

---

## Steps

### 1. Clone the repository

```bash
git clone <repository-url>
cd newreactcoffee
```

### 2. Navigate to the Astro project directory

All source code lives under the `astro/` subdirectory:

```bash
cd astro
```

### 3. Install dependencies

```bash
npm install
```

This installs:

| Package | Version | Purpose |
|---------|---------|---------|
| `astro` | ^5.5.0 | Static site generator |
| `@astrojs/react` | ^4.2.0 | React integration for islands |
| `react` | ^18.2.0 | UI library |
| `react-dom` | ^18.2.0 | React DOM renderer |
| `@types/react` | ^18.2.0 | TypeScript types for React |
| `@types/react-dom` | ^18.2.0 | TypeScript types for ReactDOM |
| `typescript` | ^5.0.0 | TypeScript compiler |

### 4. Verify the installation

```bash
npm ls --depth=0
```

You should see all dependencies listed without errors.

### 5. Start the dev server

```bash
npm run dev
```

Open **`http://localhost:4321`** in your browser. You should see the CyZerO home page.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `node: command not found` | Install Node.js from [nodejs.org](https://nodejs.org) |
| `npm install` fails with permissions | Try `npm install --legacy-peer-deps` |
| Port 4321 already in use | Astro will automatically suggest the next available port |
| Fonts not loading | Check your internet connection — fonts are loaded via CDN |

---

## Next Steps

- [Development guide](development.md) — learn about hot reload, browser tools, and workflow
- [Project structure](project-structure.md) — understand the folder layout
