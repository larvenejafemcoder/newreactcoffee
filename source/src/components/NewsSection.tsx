import React from 'react'
import '../styles/components/newssection.css'

export default function NewsSection() {
  return (
    <section className="news-section">
      <div className="news-section-container">
        <h2 className="news-section-title">NEWS</h2>
        <div className="news-featured">
          <div className="news-image">
            <img src="/mediaasset/image3.jpg" alt="News Featured" />
          </div>
          <div className="news-content">
            <div className="news-meta">
              <span className="news-category">Coffeeholic</span>
              <span className="news-date">01.11.2023</span>
            </div>
            <h3 className="news-title">
              BẮT GẶP SÀI GÒN XƯA TRONG MÓN UỐNG HIỆN ĐẠI CỦA GIỚI TRẺ
            </h3>
            <p className="news-excerpt">
              Khám phá cách VietCoffee kết hợp hương vị truyền thống của Sài Gòn xưa với xu hướng hiện đại 
              của giới trẻ. Từ những quán cà phê vỉa hè đến không gian hiện đại, chúng tôi mang đến trải nghiệm 
              độc đáo cho mọi thế hệ. Hãy cùng chúng tôi tìm hiểu về hành trình của cà phê Việt Nam...
            </p>
            <a href="/blog" className="news-btn">XEM THÊM</a>
          </div>
        </div>
      </div>
    </section>
  )
}
