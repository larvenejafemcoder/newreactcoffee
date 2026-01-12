import React, { useState, useEffect } from 'react'
import '../styles/components/clock.css'

export default function Clock() {
  const [time, setTime] = useState(new Date())

  useEffect(() => {
    const timer = setInterval(() => {
      setTime(new Date())
    }, 1000)

    return () => clearInterval(timer)
  }, [])

  const hours = time.getHours()
  const minutes = time.getMinutes()
  const seconds = time.getSeconds()

  // Calculate angles for analog clock hands
  const hourAngle = (hours % 12) * 30 + minutes * 0.5
  const minuteAngle = minutes * 6 + seconds * 0.1
  const secondAngle = seconds * 6

  // Format time for digital display
  const formatTime = (value: number) => value.toString().padStart(2, '0')
  const digitalTime = `${formatTime(hours)}:${formatTime(minutes)}:${formatTime(seconds)}`
  const dateString = time.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })

  return (
    <div className="clock-container">
      <div className="clock-wrapper">
        {/* Analog Clock */}
        <div className="analog-clock">
          <div className="clock-face">
            {/* Hour markers */}
            {[...Array(12)].map((_, i) => {
              const angle = i * 30 - 90
              return (
                <div
                  key={i}
                  className={`hour-marker ${i % 3 === 0 ? 'major' : 'minor'}`}
                  style={{
                    transform: `rotate(${angle}deg) translateY(-45%)`,
                  }}
                />
              )
            })}
            
            {/* Hour hand */}
            <div
              className="hand hour-hand"
              style={{
                transform: `rotate(${hourAngle}deg)`,
              }}
            />
            
            {/* Minute hand */}
            <div
              className="hand minute-hand"
              style={{
                transform: `rotate(${minuteAngle}deg)`,
              }}
            />
            
            {/* Second hand */}
            <div
              className="hand second-hand"
              style={{
                transform: `rotate(${secondAngle}deg)`,
              }}
            />
            
            {/* Center dot */}
            <div className="center-dot" />
          </div>
        </div>

        {/* Digital Clock */}
        <div className="digital-clock">
          <div className="digital-time">{digitalTime}</div>
          <div className="digital-date">{dateString}</div>
        </div>
      </div>
    </div>
  )
}
