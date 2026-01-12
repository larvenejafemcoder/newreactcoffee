import React, { useState } from 'react'
import '../styles/components/storelocator.css'

export default function StoreLocator() {
  const [selectedCity, setSelectedCity] = useState('')
  const [selectedDistrict, setSelectedDistrict] = useState('')

  const cities = ['Hà Nội', 'Hồ Chí Minh', 'Đà Nẵng', 'Hải Phòng', 'Cần Thơ']
  const districts: { [key: string]: string[] } = {
    'Hà Nội': ['Ba Đình', 'Hoàn Kiếm', 'Hai Bà Trưng', 'Đống Đa', 'Cầu Giấy'],
    'Hồ Chí Minh': ['Quận 1', 'Quận 3', 'Quận 7', 'Quận Bình Thạnh', 'Quận Tân Bình'],
    'Đà Nẵng': ['Hải Châu', 'Thanh Khê', 'Sơn Trà', 'Ngũ Hành Sơn'],
    'Hải Phòng': ['Hồng Bàng', 'Ngô Quyền', 'Lê Chân', 'Hải An'],
    'Cần Thơ': ['Ninh Kiều', 'Ô Môn', 'Bình Thủy', 'Cái Răng'],
  }

  return (
    <section className="store-locator">
      <div className="store-locator-container">
        <h2 className="store-locator-title">Tìm nhà gần bạn</h2>
        <p className="store-locator-text">
          Với hệ thống cửa hàng rộng khắp trên toàn quốc, VietCoffee luôn sẵn sàng phục vụ bạn mọi lúc, mọi nơi. 
          Tìm cửa hàng gần nhất để thưởng thức những tách cà phê tuyệt vời nhất.
        </p>
        
        <div className="store-locator-form">
          <div className="form-group">
            <label htmlFor="city">Thành phố</label>
            <select
              id="city"
              value={selectedCity}
              onChange={(e) => {
                setSelectedCity(e.target.value)
                setSelectedDistrict('')
              }}
            >
              <option value="">Chọn thành phố</option>
              {cities.map((city) => (
                <option key={city} value={city}>
                  {city}
                </option>
              ))}
            </select>
          </div>

          <div className="form-group">
            <label htmlFor="district">Quận/Huyện</label>
            <select
              id="district"
              value={selectedDistrict}
              onChange={(e) => setSelectedDistrict(e.target.value)}
              disabled={!selectedCity}
            >
              <option value="">Chọn quận/huyện</option>
              {selectedCity &&
                districts[selectedCity]?.map((district) => (
                  <option key={district} value={district}>
                    {district}
                  </option>
                ))}
            </select>
          </div>

          <button className="store-locator-btn">XEM DANH SÁCH CỬA HÀNG</button>
        </div>

        <div className="locator-icons">
          <img src="/mediaasset/image27.png" alt="Locator 1" />
          <img src="/mediaasset/image28.png" alt="Locator 2" />
          <img src="/mediaasset/image34.png" alt="Locator 3" />
        </div>
      </div>
    </section>
  )
}
