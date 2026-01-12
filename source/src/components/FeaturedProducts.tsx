import React from 'react'
import '../styles/components/featuredproducts.css'

export default function FeaturedProducts() {
  const categories = [
    { name: 'CÀ PHÊ', count: 17 },
    { name: 'TRÀ', count: 4 },
    { name: 'LATTE & FRAPPE', count: 14 },
    { name: 'SIGNATURE FOOD', count: 7 },
    { name: 'PASTRY & MORE', count: 17 },
  ]

  return (
    <section className="featured-products">
      <div className="featured-products-container">
        <h2 className="featured-products-title">
          "Our" <span className="highlight">COLLECTION</span>
        </h2>
        <div className="featured-products-content">
          <div className="categories-list">
            {categories.map((category, index) => (
              <div key={index} className="category-item">
                <span className="category-name">{category.name}</span>
                <span className="category-count">({category.count})</span>
              </div>
            ))}
          </div>
          <div className="featured-products-image">
            <img src="/mediaasset/image8.png" alt="Coffee Collection" />
          </div>
        </div>
      </div>
    </section>
  )
}
