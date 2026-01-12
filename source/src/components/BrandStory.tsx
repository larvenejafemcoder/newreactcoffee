import React from 'react'
import '../styles/components/brandstory.css'

export default function BrandStory() {
  return (
    <section className="brand-story">
      <div className="brand-story-container">
        <h2 className="brand-story-title">CHUYỆN "VietCoffee"</h2>
        <div className="brand-story-content">
          <div className="brand-story-image">
            <img src="/mediaasset/image19.png" alt="VietCoffee Story" />
          </div>
          <div className="brand-story-text">
            <p>
              The VietCoffee tin rằng mỗi tách cà phê không chỉ là một thức uống, mà còn là một câu chuyện về văn hóa, 
              về con người, và về những giá trị truyền thống được gìn giữ qua nhiều thế hệ. Chúng tôi bắt đầu hành trình 
              của mình với niềm đam mê mang đến những hương vị cà phê Việt Nam đích thực, được chọn lọc từ những vùng đất 
              trồng cà phê nổi tiếng nhất cả nước.
            </p>
            <p>
              Từ những hạt cà phê được chăm sóc cẩn thận đến từng giọt cà phê được pha chế tinh tế, VietCoffee cam kết 
              mang đến trải nghiệm cà phê hoàn hảo nhất cho khách hàng. Chúng tôi không chỉ phục vụ cà phê, mà còn chia sẻ 
              những câu chuyện, những giá trị văn hóa đặc trưng của Việt Nam qua từng tách cà phê.
            </p>
          </div>
        </div>
      </div>
    </section>
  )
}
