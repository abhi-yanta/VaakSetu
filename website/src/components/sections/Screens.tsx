import { useState } from 'react'
import { AnimatePresence, motion, useReducedMotion } from 'framer-motion'
import { screensContent } from '../../content/screens'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Screens() {
  const [index, setIndex] = useState(0)
  const reduce = useReducedMotion()
  const total = screensContent.slides.length
  const slide = screensContent.slides[index]

  const prev = () => setIndex((i) => (i - 1 + total) % total)
  const next = () => setIndex((i) => (i + 1) % total)

  return (
    <section id="screens" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={screensContent.eyebrow}
            before={screensContent.headlineBefore}
            accent={screensContent.headlineAccent}
            intro={screensContent.intro}
          />
        </Reveal>
        <div className="card-surface p-4 sm:p-8">
          <div className="flex items-center justify-between mb-4">
            <p className="text-sm text-[color:var(--text-muted)] m-0">
              <span className="font-display text-2xl text-[color:var(--text)]">
                {String(index + 1).padStart(2, '0')}
              </span>
              /{String(total).padStart(2, '0')} · {slide.title}
            </p>
            <div className="flex gap-2">
              <button type="button" className="btn btn-secondary !py-2 !px-3" onClick={prev} aria-label="Previous">
                ←
              </button>
              <button type="button" className="btn btn-secondary !py-2 !px-3" onClick={next} aria-label="Next">
                →
              </button>
            </div>
          </div>
          <div className="relative mx-auto max-w-md overflow-hidden rounded-[var(--radius)] bg-[color:var(--bg-elevated)]">
            <AnimatePresence mode="wait">
              <motion.img
                key={slide.id}
                src={slide.src}
                alt={slide.title}
                className="w-full aspect-[9/16] object-cover object-top"
                initial={reduce ? false : { opacity: 0, x: 24 }}
                animate={{ opacity: 1, x: 0 }}
                exit={reduce ? undefined : { opacity: 0, x: -24 }}
                transition={{ duration: 0.35 }}
              />
            </AnimatePresence>
          </div>
          <p className="mt-4 text-center text-xs text-[color:var(--text-faint)]">{slide.caption}</p>
        </div>
      </div>
    </section>
  )
}
