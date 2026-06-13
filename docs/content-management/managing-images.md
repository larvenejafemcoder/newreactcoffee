# Managing Images

All static images are stored in `public/media-assets/`. During the build, Astro copies this directory verbatim to `dist/`.

---

## Image Location

```
astro/public/media-assets/
├── coldbrew.png / originalcoldbew.png   # Cold brew products
├── cappuccino.png                       # Cappuccino product
├── coldcappucino.png                    # Ired cappuccino
├── hotcappuccino.png                    # Hot cappuccino
├── coffee.png / coffee1.jpg             # Coffee beans / hero
├── macchiato.png                        # Macchiato product
├── yuzuamericano.png                    # Yuzu americano
├── peachamericano.png                   # Peach americano
├── specialty1.png / specialty2.png / specialty3.png  # Specialty items
├── home.jpg                             # Hero background + brand story
├── logo.svg                             # SVG logo
├── menu.svg / close.svg                 # SVG menu icons (unused)
├── loadcoffee.gif                       # Loading animation
├── nav/
│   ├── logo.jpg / logo1.png             # Header logo variants
│   ├── menu.png                         # Menu toggle icon
│   └── close.png                        # Close icon
└── imgs/
    ├── 1.jpg through 6.jpg              # Slider images
```

---

## Referencing Images

Images are referenced with an absolute path from the site root:

```astro
<!-- Astro component -->
<img src="/media-assets/coffee.png" alt="Coffee" />

<!-- React component -->
<img src="/media-assets/nav/menu.png" alt="menu" />
```

---

## Adding a New Image

1. Add your image file to `public/media-assets/`

2. Reference it in the component:

```astro
<img src="/media-assets/your-image.png" alt="Description" loading="lazy" />
```

3. The `loading="lazy"` attribute is used on images below the fold for performance.

---

## Image Guidelines

| Aspect | Recommendation |
|--------|---------------|
| **Format** | PNG for products (transparent bg), JPG for photos |
| **Max size** | 200 KB per image |
| **Dimensions** | At least 800×800px for products, 1920×1080 for hero |
| **Alt text** | Always provide descriptive `alt` attributes |

---

## Slider Images

The six slider images (`1.jpg` – `6.jpg`) are used on the `/slider` page:

```astro
<section>
  <img src="/media-assets/imgs/1.jpg" alt="num1" />
</section>
```

To add or replace slider images, update both the files in `public/media-assets/imgs/` and the corresponding `<section>` in `src/pages/slider.astro`.

---

## Product Grid Images

Each product in the 12-item grid references an image by filename:

```tsx
{
  name: 'Ethiopian',
  image: 'coffee.png',  // resolves to /media-assets/coffee.png
}
```

To change a product image:

1. Add the new image to `public/media-assets/`
2. Update the `image` field in the product object (not the path — just the filename)
3. The grid renders: `<img src="/media-assets/coffee.png" />`
