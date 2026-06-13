# Contributing

Guidelines for contributing to the CyZerO project.

---

## Code of Conduct

This project follows a standard code of conduct. All contributors are expected to be respectful, constructive, and collaborative.

---

## How to Contribute

### 1. Report Issues

Open an issue with:

- A clear, descriptive title
- Steps to reproduce (if a bug)
- Expected vs. actual behavior
- Screenshots (if visual)
- Browser/device info

### 2. Suggest Changes

Open an issue with the "enhancement" label describing:

- What you want to change
- Why it improves the project
- Any design considerations

### 3. Submit Code

#### Branch Naming

```
feature/description     # New features
fix/description         # Bug fixes
style/description       # CSS/design changes
content/description     # Text or image updates
```

#### Commit Conventions

Use conventional commits:

```
feat: add new product grid hover animation
fix: correct menu close button z-index
style: update hero heading letter-spacing
content: replace brand story images
chore: update Astro to 5.6.0
```

#### Pull Request Process

1. Create a branch from `main`
2. Make your changes
3. Run `npm run lint` and fix any errors
4. Test locally with `npm run dev`
5. Create a pull request with a description of changes
6. Wait for review

---

## Development Setup

```bash
cd astro
npm install
npm run dev
```

See the [Installation guide](../getting-started/installation.md) for details.

---

## Code Style

- **Astro:** One component per file, frontmatter for data, template for markup
- **React:** Functional components with hooks, no class components
- **CSS:** Component-prefixed class names, no `!important`
- **TypeScript:** Strict mode, prefer interfaces over types for objects
- **Images:** Optimize before committing (under 200 KB)

---

## Review Criteria

A pull request will be evaluated on:

- **Functionality** — does it work without breaking existing features?
- **Consistency** — does it follow project conventions?
- **Performance** — does it add unnecessary JS or images?
- **Accessibility** — are interactive elements keyboard-accessible?
