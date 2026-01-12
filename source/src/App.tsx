import React from 'react'
import { Routes, Route } from 'react-router-dom'
import Home from './pages/Home'
import Showcase from './pages/Showcase'
import ClockPage from './pages/Clock'

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/slider" element={<Showcase />} />
      <Route path="/clock" element={<ClockPage />} />
    </Routes>
  )
}
