import React from 'react'
import CoffeeLoader from './CoffeeLoader'

export default function Hero(){
  return (
    <section className="main">
      <div className="left-content">
        <div className="text"><h1>A Pleasure<br/>In<br/>Life.</h1></div>
        <button>More</button>
      </div>

        <div className="right-content">
          <CoffeeLoader />
        </div>

    </section>
  )
}
