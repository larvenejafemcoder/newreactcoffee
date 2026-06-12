import { useState, useEffect } from 'react'

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

  const hourAngle = (hours % 12) * 30 + minutes * 0.5
  const minuteAngle = minutes * 6 + seconds * 0.1
  const secondAngle = seconds * 6

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
        <div className="analog-clock">
          <div className="clock-face">
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

            <div
              className="hand hour-hand"
              style={{
                transform: `rotate(${hourAngle}deg)`,
              }}
            />

            <div
              className="hand minute-hand"
              style={{
                transform: `rotate(${minuteAngle}deg)`,
              }}
            />

            <div
              className="hand second-hand"
              style={{
                transform: `rotate(${secondAngle}deg)`,
              }}
            />

            <div className="center-dot" />
          </div>
        </div>

        <div className="digital-clock">
          <div className="digital-time">{digitalTime}</div>
          <div className="digital-date">{dateString}</div>
        </div>
      </div>
    </div>
  )
}
