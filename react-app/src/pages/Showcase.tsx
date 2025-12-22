import React from 'react'
import Header from '../components/Header'

export default function Showcase(){
  return (
    <>
      <Header />
      <div className="coffee-container">
        <section>
          <img src="/media-assets/imgs/1.jpg" alt="num1" />
        </section>
        <section>
          <img src="/media-assets/imgs/2.jpg" alt="num2" />
        </section>
        <section>
          <img src="/media-assets/imgs/3.jpg" alt="num3" />
        </section>
        <section>
          <img src="/media-assets/imgs/4.jpg" alt="num4" />
        </section>
        <section>
          <h1><a href="/">Go Back</a></h1>
        </section>
      </div>
    </>
  )
}
