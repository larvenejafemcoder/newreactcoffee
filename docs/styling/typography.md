# Typography

This project uses four font families loaded via CDN. No font files are stored in the repository.

---

## Font Families

| Family | Role | CSS Variable | Weight Range |
|--------|------|-------------|-------------|
| **Pretendard Variable** | Body text, navbar, buttons, descriptions | `--font-body` | 300–700 |
| **SUIT Variable** | Headings, product names, display text | `--font-display` | 800–900 |
| **JetBrains Mono** | Labels, annotations, editorial tags | `--font-label` | 400–700 |
| **Noto Sans KR** | Korean character fallback for all families | — | 300–900 |

> **Note:** Noto Sans KR is the designated Korean script fallback. It is declared last in each `font-family` stack to ensure Korean characters render correctly.

---

## Font Loading

Fonts are loaded in `src/layouts/Layout.astro`:

```html
<!-- Pretendard & SUIT Variable via jsDelivr -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/variable/pretendardvariable-dynamic-subset.css" />
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/gh/sunn-us/SUIT/fonts/variable/SUIT-Variable.css" />

<!-- JetBrains Mono & Noto Sans KR via Google Fonts -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;600;700;900&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet" />
```

### Resource Hints

```html
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
<link rel="preconnect" href="https://cdn.jsdelivr.net" />
```

These `preconnect` hints speed up font loading by establishing early connections to the font CDNs.

---

## CSS Variable Definitions

```css
:root {
  --font-display: 'SUIT Variable', 'Noto Sans KR', sans-serif;
  --font-body: 'Pretendard Variable', 'Pretendard', 'Noto Sans KR', sans-serif;
  --font-label: 'JetBrains Mono', 'Noto Sans KR', monospace;
}
```

---

## Typography Scale

| Element | Font Family | Weight | Size | Letter Spacing |
|---------|-------------|--------|------|----------------|
| H1 (Hero) | `--font-display` | 900 | `clamp(4rem, 8vw, 7rem)` | `-0.03em` |
| H2 (Section titles) | `--font-display` | 800–900 | `clamp(2rem, 4vw, 4rem)` | `-0.02em` |
| H3 (Card names) | `--font-display` | 700–900 | `clamp(0.85rem, 2.5vw, 2rem)` | `-0.02em` |
| Body text | `--font-body` | 400 | `0.95rem – 1.2rem` | — |
| Labels (muted) | `--font-label` | 600–700 | `0.6rem – 0.85rem` | `2px – 6px` |
| Button text | `--font-label` | 700 | `0.75rem – 0.85rem` | `3px – 4px` |
| Product prices | `--font-body` | 700 | `0.85rem – 1.1rem` | — |

---

## Label & Button Convention

Labels and buttons consistently use:

- **UPPERCASE** (via `text-transform: uppercase` in CSS)
- **JetBrains Mono** font family
- **Tight letter-spacing** (2–6px)
- **Small font size** (0.6rem–0.85rem)

```css
.section-label {
  font-family: var(--font-label);
  font-size: 0.75rem;
  letter-spacing: 4px;
  text-transform: uppercase;
}
```

---

## Performance Notes

- Variable fonts (`Pretendard Variable`, `SUIT Variable`) provide multiple weights in a single file, reducing download size
- The `display=swap` parameter tells the browser to render fallback text immediately, then swap to the web font once loaded (FOUT strategy)
- CDN fonts are cached by the browser on repeat visits
