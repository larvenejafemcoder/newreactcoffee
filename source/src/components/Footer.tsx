import React from 'react'
import '../styles/components/footer.css'

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer-container">
        <div className="footer-content">
          <div className="footer-section">
            <h4 className="footer-title">GIỚI THIỆU</h4>
            <ul className="footer-links">
              <li><a href="/about">Về chúng tôi</a></li>
              <li><a href="/story">Câu chuyện thương hiệu</a></li>
              <li><a href="/careers">Tuyển dụng</a></li>
              <li><a href="/news">Tin tức</a></li>
            </ul>
          </div>

          <div className="footer-section">
            <h4 className="footer-title">ĐIỀU KHOẢN</h4>
            <ul className="footer-links">
              <li><a href="/terms">Điều khoản sử dụng</a></li>
              <li><a href="/privacy">Chính sách bảo mật</a></li>
              <li><a href="/shipping">Chính sách vận chuyển</a></li>
              <li><a href="/returns">Chính sách đổi trả</a></li>
            </ul>
          </div>

          <div className="footer-section">
            <h4 className="footer-title">LIÊN HỆ</h4>
            <div className="footer-contact">
              <p><strong>VPGG:</strong> Tầng 6, Toà nhà Toyota, 315 Trường Chinh, Thanh Xuân, Hà Nội</p>
              <p><strong>Đặt hàng:</strong> <a href="tel:18006936">1800 6936</a></p>
              <p><strong>Email:</strong> <a href="mailto:support.hn@ggg.com.vn">support.hn@ggg.com.vn</a></p>
            </div>
          </div>

          <div className="footer-section">
            <h4 className="footer-title">TẢI ỨNG DỤNG</h4>
            <div className="footer-app">
              <img src="/mediaasset/image2.jpg" alt="Download App" />
            </div>
            <div className="footer-social">
              <a href="https://facebook.com" target="_blank" rel="noopener noreferrer">
                <img src="/mediaasset/image36.png" alt="Facebook" />
              </a>
              <a href="https://youtube.com" target="_blank" rel="noopener noreferrer">
                <img src="/mediaasset/image24.png" alt="YouTube" />
              </a>
              <a href="https://instagram.com" target="_blank" rel="noopener noreferrer">
                <img src="/mediaasset/image17.png" alt="Instagram" />
              </a>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p className="footer-copyright">© 2025 THE COFFEE HOUSE</p>
          <div className="footer-company">
            <p>Công ty TNHH The Coffee House</p>
            <p>Giấy chứng nhận ĐKDN số: 0312867172 do Sở Kế hoạch và Đầu tư TP.HCM cấp ngày 23/07/2014</p>
            <p>Địa chỉ: 86-88 Cao Thắng, Phường 04, Quận 3, TP.HCM</p>
          </div>
        </div>
      </div>
    </footer>
  )
}
