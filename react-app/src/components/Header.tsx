import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Logo from './Logo'

export default function Header(){
  const [open, setOpen] = useState(false)

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [open])

  return (
    <>
      <header className="container" role="banner">
        <div className="logo"><Link to="/"><Logo /></Link></div>
        <div className="box">
          <button
            aria-expanded={open}
            aria-controls="main-menu"
            aria-label={open ? 'Close menu' : 'Open menu'}
            onClick={() => setOpen((v) => !v)}
            style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer' }}
          >
            <img src="/media-assets/nav/menu.png" alt="menu" />
          </button>
        </div>
      </header>

      <div id="main-menu" className={`menu-box ${open ? 'open-menu' : ''}`} aria-hidden={!open}>
        <button className="menu-close" onClick={() => setOpen(false)} aria-label="Close menu">×</button>
        <ul>
          <li><Link to="/" onClick={() => setOpen(false)}>Home</Link></li>
          <li><Link to="/slider" onClick={() => setOpen(false)}>Showcase</Link></li>
          <li><a href="#" onClick={() => setOpen(false)}>smt</a></li>
          <li><a href="#" onClick={() => setOpen(false)}>smt</a></li>
        </ul>
      </div>
    </>
  )
}
