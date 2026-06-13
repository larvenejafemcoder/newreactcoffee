# Store Locator

The Store Locator is a React component with cascading dropdowns for selecting a city and district.

---

## Component Location

**File:** `src/components/StoreLocator.tsx` — hydrated with `client:load` on the home page

---

## Data Model

```tsx
const cities = ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju']

const districts: { [key: string]: string[] } = {
  'Seoul': ['Gangnam', 'Jongno', 'Mapo', 'Seongdong', 'Yongsan'],
  'Busan': ['Haeundae', 'Seomyeon', 'Nampo', 'Busanjin'],
  'Daegu': ['Jung-gu', 'Dong-gu', 'Suseong', 'Dalseo'],
  'Incheon': ['Songdo', 'Yeonsu', 'Namdong', 'Bupyeong'],
  'Gwangju': ['Dong-gu', 'Seo-gu', 'Nam-gu', 'Buk-gu'],
}
```

> **Note:** This data is hardcoded. To add or modify locations, edit the arrays directly in `StoreLocator.tsx`.

---

## Selection Flow

```mermaid
flowchart TD
    Start["User views Store Locator"] --> PickCity["Select a City"]
    PickCity --> ResetDistrict["Reset district dropdown<br/>setSelectedDistrict('')"]
    ResetDistrict --> EnableDist["Enable district dropdown<br/>disabled = false"]
    EnableDist --> PickDistrict["Select a District"]
    PickDistrict --> ShowBtn["'View Store List →' button enabled"]
    ShowBtn --> Click["User clicks button"]
    Click --> Action["(Currently no-op — reserved for future)")
```

---

## State

| State | Type | Initial | Description |
|-------|------|---------|-------------|
| `selectedCity` | `string` | `''` | Currently selected city |
| `selectedDistrict` | `string` | `''` | Currently selected district |

---

## Events

### City Selection

```tsx
onChange={(e) => {
  setSelectedCity(e.target.value)
  setSelectedDistrict('')  // Reset district when city changes
}}
```

### District Selection

```tsx
onChange={(e) => setSelectedDistrict(e.target.value)}
```

The district dropdown is **disabled** when no city is selected:

```tsx
<select disabled={!selectedCity}>
  <option value="">Select a district</option>
  {selectedCity && districts[selectedCity]?.map((district) => (
    <option key={district} value={district}>{district}</option>
  ))}
</select>
```

---

## Render Structure

```
<section class="store-locator">
  <div class="store-locator-container">
    <div class="store-locator-subtitle">Find Us</div>
    <h2 class="store-locator-title">Locate Your Nearest Store</h2>
    <p class="store-locator-text">...</p>

    <div class="store-locator-form">
      <div class="form-group">
        <label>City</label>
        <select />           ← City dropdown
      </div>
      <div class="form-group">
        <label>District</label>
        <select />           ← District dropdown (cascading)
      </div>
      <button>View Store List →</button>
    </div>

    <div class="locator-icons">
      <!-- 3 SVG map/compass icons -->
    </div>
  </div>
</section>
```

---

## Styling Reference

| File | Key Selectors |
|------|---------------|
| `components/storelocator.css` (146 lines) | `.store-locator`, `.form-group`, `.form-group select`, `.store-locator-btn`, `.locator-icons` |

The select inputs feature a custom dropdown arrow SVG:

```css
.form-group select {
  appearance: none;
  background-image: url("data:image/svg+xml,...chevron...");
  background-repeat: no-repeat;
  background-position: right 1rem center;
}
```

---

## Extending the Store Locator

### Add a new city

```tsx
const cities = ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju', 'Daejeon']

const districts = {
  // ...existing cities
  'Daejeon': ['Yuseong', 'Seo-gu', 'Jung-gu', 'Daedeok'],
}
```

### Change button behavior

The button is currently static. To add functionality (e.g., show a list of stores), attach an `onClick` handler.
