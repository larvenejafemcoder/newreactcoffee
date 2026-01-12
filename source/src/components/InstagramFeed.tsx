import React from 'react'
import '../styles/components/instagramfeed.css'

export default function InstagramFeed() {
  const instagramImages = [
    'image12.png',
    'image23.png',
    'image13.png',
    'image31.png',
    'image29.png',
    'image21.png',
  ]

  return (
    <section className="instagram-feed">
      <div className="instagram-feed-container">
        <div className="instagram-header">
          <h2 className="instagram-title">
            KẾT NỐI VỚI <span className="highlight">NHÀ</span>
          </h2>
          <h3 className="instagram-subtitle">INSTAGRAM</h3>
          <a href="https://instagram.com" className="instagram-btn" target="_blank" rel="noopener noreferrer">
            FOLLOW NGAY
          </a>
        </div>
        <div className="instagram-grid">
          {instagramImages.map((image, index) => (
            <div key={index} className="instagram-item">
              <img src={`/mediaasset/${image}`} alt={`Instagram post ${index + 1}`} />
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
