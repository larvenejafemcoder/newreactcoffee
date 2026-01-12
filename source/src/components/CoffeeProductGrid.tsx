import React from 'react'
import '../styles/components/coffeeproductgrid.css'

interface Product {
  name: string
  image: string
  price: string
  link: string
}

export default function CoffeeProductGrid() {
  const products: Product[] = [
    { name: 'A-Mê Classic', image: 'image10.png', price: '45.000đ', link: '#' },
    { name: 'A-Mê Đào', image: 'image6.png', price: '55.000đ', link: '#' },
    { name: 'A-Mê Mơ', image: 'image11.png', price: '55.000đ', link: '#' },
    { name: 'A-Mê Tuyết Quất', image: 'image4.png', price: '55.000đ', link: '#' },
    { name: 'A-Mê Yuzu', image: 'image14.png', price: '55.000đ', link: '#' },
    { name: 'Americano Nóng', image: 'image15.png', price: '45.000đ', link: '#' },
    { name: 'Cappuccino Đá', image: 'image9.png', price: '55.000đ', link: '#' },
    { name: 'Cappuccino Nóng', image: 'image18.png', price: '55.000đ', link: '#' },
    { name: 'Caramel Macchiato Đá', image: 'image22.png', price: '65.000đ', link: '#' },
    { name: 'Caramel Macchiato Nóng', image: 'image16.png', price: '65.000đ', link: '#' },
    { name: 'Cold Brew Kim Quất', image: 'image7.png', price: '55.000đ', link: '#' },
    { name: 'Cold Brew Truyền Thống', image: 'image32.png', price: '45.000đ', link: '#' },
  ]

  return (
    <section className="coffee-product-grid">
      <div className="coffee-product-grid-container">
        <div className="products-grid">
          {products.map((product, index) => (
            <div key={index} className="product-card">
              <a href={product.link} className="product-link">
                <div className="product-image">
                  <img src={`/mediaasset/${product.image}`} alt={product.name} />
                </div>
                <div className="product-info">
                  <h3 className="product-name">{product.name}</h3>
                  <p className="product-price">{product.price}</p>
                </div>
              </a>
            </div>
          ))}
        </div>
        <div className="view-more-container">
          <a href="/collection" className="view-more-btn">XEM THÊM</a>
        </div>
      </div>
    </section>
  )
}
