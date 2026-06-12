import { useEffect, useState } from 'react'

export default function Header() {
  const [open, setOpen] = useState(false)
  const [iconSrc, setIconSrc] = useState("/media-assets/nav/menu.png")
  const [isMobile, setIsMobile] = useState(false)

  useEffect(() => {
    const check = () => setIsMobile(window.innerWidth < 768)
    check()
    window.addEventListener('resize', check)
    return () => window.removeEventListener('resize', check)
  }, [])

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [open])

  const close = () => {
    setOpen(false)
    setIconSrc("/media-assets/nav/menu.png")
  }

  const toggle = () => {
    const newOpen = !open
    setOpen(newOpen)
    setIconSrc(newOpen ? "/media-assets/nav/close.png" : "/media-assets/nav/menu.png")
  }

  const menuClass = `menu-box ${open ? 'open-menu' : ''}${open && isMobile ? ' mobile-full' : ''}`

  return (
    <>
      <header className="container" role="banner">
        <div className="logo">
          <a href="/">
            <img
              src="/media-assets/nav/logo1.png"
              alt="CyZerO"
              style={{ height: '36px', width: 'auto' }}
            />
          </a>
        </div>
        <div className="box">
          <button
            aria-expanded={open}
            aria-controls="main-menu"
            aria-label={open ? 'Close menu' : 'Open menu'}
            onClick={toggle}
          >
            <img src={iconSrc} alt={open ? "close" : "menu"} />
          </button>
        </div>
      </header>

      <div className={`menu-overlay ${open ? 'open' : ''}`} onClick={close} aria-hidden={!open} />

      <div id="main-menu" className={menuClass} aria-hidden={!open}>
        <button className="menu-close" onClick={close} aria-label="Close menu">×</button>
        <ul>
          <li><a href="/" onClick={close}>Home</a></li>
          <li><a href="/slider" onClick={close}>Showcase</a></li>
          <li><a href="/clock" onClick={close}>Clock</a></li>
          <li><a href="#" onClick={close}>Journal</a></li>
        </ul>
      </div>
    </>
  )
}
