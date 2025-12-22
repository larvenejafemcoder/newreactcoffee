import React from 'react'

export default function Logo(){
  return (
    <svg viewBox="0 0 273 120" width="100%" height="auto" aria-hidden="true" role="img">
      {/* Simplified logo: keep original complex SVG paths in case we need them later */}
      <rect width="100%" height="100%" fill="none" />
      <g fill="#ffffff">
        <text x="0" y="60" fontSize={18} fontWeight={700}>CyZerO</text>
      </g>
    </svg>
  )
}
