import React from 'react'
import Header from '../components/Header'
import Clock from '../components/Clock'

export default function ClockPage() {
  return (
    <>
      <Header />
      <main className="clock-page">
        <Clock />
      </main>
    </>
  )
}
