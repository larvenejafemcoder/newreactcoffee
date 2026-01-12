import React from 'react'
import '../styles/components/qualitystory.css'

export default function QualityStory() {
  return (
    <section className="quality-story">
      <div className="quality-story-container">
        <div className="quality-story-item">
          <div className="quality-story-image">
            <img src="/mediaasset/image5.jpg" alt="Coffee Quality" />
          </div>
          <div className="quality-story-content">
            <h3 className="quality-story-heading">☕ Nguyên bản từ giá trị hạt cà phê chất lượng</h3>
            <p className="quality-story-text">
              Chúng tôi chọn lọc những hạt cà phê tốt nhất từ các vùng trồng nổi tiếng của Việt Nam. 
              Mỗi hạt cà phê được chăm sóc cẩn thận, thu hoạch đúng thời điểm và chế biến theo phương pháp 
              truyền thống kết hợp với công nghệ hiện đại để mang đến hương vị đậm đà, nguyên bản nhất.
            </p>
            <a href="/coffee-quality" className="quality-story-btn">XEM THÊM</a>
          </div>
        </div>

        <div className="quality-story-item reverse">
          <div className="quality-story-image">
            <img src="/mediaasset/image25.jpg" alt="Tea Quality" />
          </div>
          <div className="quality-story-content">
            <h3 className="quality-story-heading">🍃 Chất lượng khởi nguồn từ những đồi trà tuyển chọn</h3>
            <p className="quality-story-text">
              Từ những đồi trà xanh mướt ở vùng cao nguyên, chúng tôi mang đến những lá trà tươi ngon nhất. 
              Mỗi lá trà được hái thủ công, chế biến theo quy trình đặc biệt để giữ nguyên hương vị tự nhiên 
              và những dưỡng chất quý giá. Trà của chúng tôi không chỉ là thức uống mà còn là trải nghiệm 
              về thiên nhiên và văn hóa Việt Nam.
            </p>
            <a href="/tea-quality" className="quality-story-btn">XEM THÊM</a>
          </div>
        </div>
      </div>
    </section>
  )
}
