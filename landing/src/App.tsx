import { useEffect, useMemo, useState } from 'react'
import { Navbar, DotNavigator, BackToTop } from './components/layout'
import { Hero, Languages, Features, createStepSection } from './components/sections'
import { STEPS } from './constants'
import { useTheme } from './hooks/useTheme'

const StepSections = STEPS.map((step, i) => createStepSection(step, i))

export default function App() {
  const { theme, toggle } = useTheme()
  const sectionIds = useMemo(
    () => ['hero', ...STEPS.map((s) => s.id), 'languages', 'features'],
    [],
  )
  const [activeId, setActiveId] = useState('hero')

  useEffect(() => {
    const elements = sectionIds
      .map((id) => document.getElementById(id))
      .filter((el): el is HTMLElement => Boolean(el))

    const observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((e) => e.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio)
        if (visible[0]?.target.id) {
          setActiveId(visible[0].target.id)
        }
      },
      { threshold: [0.25, 0.45, 0.65], rootMargin: '-10% 0px -35% 0px' },
    )

    for (const el of elements) observer.observe(el)
    return () => observer.disconnect()
  }, [sectionIds])

  return (
    <>
      <Navbar theme={theme} onToggleTheme={toggle} activeId={activeId} />
      <DotNavigator activeId={activeId} ids={sectionIds} />
      <BackToTop />
      <main>
        <Hero theme={theme} />
        {StepSections.map((Step, i) => (
          <Step key={STEPS[i].id} />
        ))}
        <Languages />
        <Features />
      </main>
    </>
  )
}
