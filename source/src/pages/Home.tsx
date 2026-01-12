import React from 'react'
import Header from '../components/Header'
import Hero from '../components/Hero'
import BrandStory from '../components/BrandStory'
import FeaturedProducts from '../components/FeaturedProducts'
import CoffeeProductGrid from '../components/CoffeeProductGrid'
import QualityStory from '../components/QualityStory'
import StoreLocator from '../components/StoreLocator'
import InstagramFeed from '../components/InstagramFeed'
import NewsSection from '../components/NewsSection'
import Footer from '../components/Footer'
import '../styles/pages/home.css'

export default function Home(){
  return (
    <div className="home-page">
      <Header />
      <main className="main-content">
        <Hero />
        <BrandStory />
        <FeaturedProducts />
        <CoffeeProductGrid />
        <QualityStory />
        <StoreLocator />
        <InstagramFeed />
        <NewsSection />
      </main>
      <Footer />
    </div>
  )
}
