import { useState } from 'react'
import { useTheme } from './hooks/useTheme'
import { Navbar } from './components/layout/Navbar'
import { BackToTop } from './components/layout/BackToTop'
import { AccessModal } from './components/layout/AccessModal'
import { Hero } from './components/sections/Hero'
import { Recognition } from './components/sections/Recognition'
import { Problem } from './components/sections/Problem'
import { Fit } from './components/sections/Fit'
import { Workflow } from './components/sections/Workflow'
import { Screens } from './components/sections/Screens'
import { Languages } from './components/sections/Languages'
import { Documents } from './components/sections/Documents'
import { Audience } from './components/sections/Audience'
import { Tech } from './components/sections/Tech'
import { Evidence } from './components/sections/Evidence'
import { Traction } from './components/sections/Traction'
import { Roadmap } from './components/sections/Roadmap'
import { Team } from './components/sections/Team'
import { Faq } from './components/sections/Faq'
import { CtaBanner } from './components/sections/CtaBanner'
import { Footer } from './components/sections/Footer'

export default function App() {
  const { theme, toggle } = useTheme()
  const [modalOpen, setModalOpen] = useState(false)

  return (
    <>
      <Navbar theme={theme} onToggleTheme={toggle} onOpenAccess={() => setModalOpen(true)} />
      <main>
        <Hero onOpenAccess={() => setModalOpen(true)} />
        <Recognition />
        <Problem />
        <Fit />
        <Workflow />
        <Screens />
        <Languages />
        <Documents />
        <Audience />
        <Tech />
        <Evidence />
        <Traction />
        <Roadmap />
        <Team />
        <Faq />
        <CtaBanner onOpenAccess={() => setModalOpen(true)} />
      </main>
      <Footer />
      <BackToTop />
      <AccessModal open={modalOpen} onClose={() => setModalOpen(false)} />
    </>
  )
}
