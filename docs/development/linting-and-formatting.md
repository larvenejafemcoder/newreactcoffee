# Linting & Formatting

The project uses **ESLint** to maintain code quality across Astro, TypeScript, and TypeScript React files.

---

## Commands

```bash
npm run lint        # Check for lint errors
npm run lint:fix    # Auto-fix fixable issues
```

Both commands target all files with extensions `.astro`, `.ts`, and `.tsx`:

```json
{
  "scripts": {
    "lint": "eslint . --ext .astro,.ts,.tsx",
    "lint:fix": "eslint . --ext .astro,.ts,.tsx --fix"
  }
}
```

---

## What Gets Linted

| Extension | File Type | Examples |
|-----------|-----------|----------|
| `.astro` | Astro components | Hero.astro, Layout.astro |
| `.ts` | TypeScript (unused currently) | — |
| `.tsx` | React components | Header.tsx, Clock.tsx, StoreLocator.tsx |

> **Note:** CSS files are not linted. There is no Stylelint or Prettier configured.

---

## Configuration

ESLint configuration is in the project root. The exact rules depend on the installed plugins.

### Recommended Setup

Create `astro/.eslintrc.cjs`:

```js
module.exports = {
  root: true,
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
  },
  overrides: [
    {
      files: ['*.astro'],
      parser: 'astro-eslint-parser',
      parserOptions: {
        parser: '@typescript-eslint/parser',
        extraFileExtensions: ['.astro'],
      },
    },
  ],
};
```

---

## Before Committing

Always run:

```bash
npm run lint
```

Fix any errors before pushing. For auto-fixable issues:

```bash
npm run lint:fix
```

---

## Common Lint Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| `'X' is defined but never used` | Unused import/variable | Remove the import/variable |
| `Missing return type on function` | TypeScript strict check | Add return type or disable rule |
| `Unexpected console statement` | `console.log` left in code | Remove it |
| `Parsing error: Unexpected token` | ESLint doesn't understand `.astro` | Ensure `astro-eslint-parser` is installed |
