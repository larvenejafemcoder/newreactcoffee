import React, { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import Logo from './Logo'

export default function Header(){
  const [open, setOpen] = useState(false)
  const [iconSrc, setIconSrc] = useState("/media-assets/nav/menu.png")

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
            onClick={() => {
              const newOpen = !open;
              setOpen(newOpen);
              setIconSrc(newOpen ? "/media-assets/nav/close.png" : "/media-assets/nav/menu.png");
            }}
            style={{ background: 'none', border: 'none', padding: 0, cursor: 'pointer' }}
          >
            <img src={iconSrc} alt={open ? "close" : "menu"} />
          </button>
        </div>
      </header>

      <div id="main-menu" className={`menu-box ${open ? 'open-menu' : ''}`} aria-hidden={!open}>
        <button className="menu-close" onClick={() => setOpen(false)} aria-label="Close menu">×</button>
        <ul>
          <li><Link to="/" onClick={() => setOpen(false)}>Home</Link></li>
          <li><Link to="/slider" onClick={() => setOpen(false)}>Showcase</Link></li>
          <li><Link to="/clock" onClick={() => setOpen(false)}>Clock</Link></li>
          <li><a href="#" onClick={() => setOpen(false)}>smt</a></li>
        </ul>
      </div>
    </>
  )
}
