import { useState } from 'react'

export default function StoreLocator() {
  const [selectedCity, setSelectedCity] = useState('')
  const [selectedDistrict, setSelectedDistrict] = useState('')

  const cities = ['Seoul', 'Busan', 'Daegu', 'Incheon', 'Gwangju']
  const districts: { [key: string]: string[] } = {
    'Seoul': ['Gangnam', 'Jongno', 'Mapo', 'Seongdong', 'Yongsan'],
    'Busan': ['Haeundae', 'Seomyeon', 'Nampo', 'Busanjin'],
    'Daegu': ['Jung-gu', 'Dong-gu', 'Suseong', 'Dalseo'],
    'Incheon': ['Songdo', 'Yeonsu', 'Namdong', 'Bupyeong'],
    'Gwangju': ['Dong-gu', 'Seo-gu', 'Nam-gu', 'Buk-gu'],
  }

  return (
    <section className="store-locator">
      <div className="store-locator-container">
        <div className="store-locator-subtitle">Find Us</div>
        <h2 className="store-locator-title">Locate Your Nearest Store</h2>
        <p className="store-locator-text">
          With locations across Korea, we're always ready to serve you. Find the store nearest to you
          and experience premium Korean coffee culture.
        </p>

        <div className="store-locator-form">
          <div className="form-group">
            <label htmlFor="city">City</label>
            <select
              id="city"
              value={selectedCity}
              onChange={(e) => {
                setSelectedCity(e.target.value)
                setSelectedDistrict('')
              }}
            >
              <option value="">Select a city</option>
              {cities.map((city) => (
                <option key={city} value={city}>
                  {city}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="district">District</label>
            <select
              id="district"
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              disabled={!selectedCity}
            >
              <option value="">Select a district</option>
              {selectedCity &&
                districts[selectedCity]?.map((district) => (
                  <option key={district} value={district}>
                    {district}
                  </option>
                ))}
            </select>
          </div>

          <button className="store-locator-btn">View Store List →</button>
        </div>

        <div className="locator-icons">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--latte)" stroke-width="1" opacity="0.5">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
            <circle cx="12" cy="10" r="3"/>
          </svg>
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--latte)" stroke-width="1" opacity="0.5">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
            <polyline points="9 22 9 12 15 12 15 22"/>
          </svg>
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--latte)" stroke-width="1" opacity="0.5">
            <circle cx="12" cy="12" r="2"/>
            <path d="M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7z"/>
          </svg>
        </div>
      </div>
    </section>
  )
}
