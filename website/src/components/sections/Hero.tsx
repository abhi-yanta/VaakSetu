import { motion, useReducedMotion } from 'framer-motion'
import { heroContent } from '../../content/hero'
import { Reveal } from '../ui/Reveal'

type Props = {
  onOpenAccess: () => void
}

export function Hero({ onOpenAccess }: Props) {
  const reduce = useReducedMotion()

  return (
    <section id="top" className="relative min-h-[100svh] overflow-hidden pt-24 pb-16">
      <div className="hero-mesh" />
      {!reduce && (
        <svg className="absolute inset-0 w-full h-full opacity-30 pointer-events-none" aria-hidden>
          <defs>
            <pattern id="mesh" width="48" height="48" patternUnits="userSpaceOnUse">
              <path d="M48 0H0V48" fill="none" stroke="var(--accent)" strokeOpacity="0.25" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#mesh)" />
        </svg>
      )}
      <div className="section-shell relative grid lg:grid-cols-[1.1fr_0.9fr] gap-12 items-center">
        <Reveal>
          <p className="eyebrow">{heroContent.eyebrow}</p>
          <h1 className="headline !text-[clamp(2.4rem,5vw,4rem)]">
            {heroContent.headlineBefore}{' '}
            <em className="italic-accent not-italic italic">{heroContent.headlineAccent}</em>
          </h1>
          <p className="intro !text-lg">{heroContent.description}</p>
          <div className="flex flex-wrap gap-3 mb-6">
            <a className="btn btn-primary" href="https://github.com/abhi-yanta/VaakSetu">
              {heroContent.primaryCta}
            </a>
            <a className="btn btn-secondary" href="#workflow">
              {heroContent.secondaryCta}
            </a>
            <button type="button" className="btn btn-ghost" onClick={onOpenAccess}>
              Early access
            </button>
          </div>
          <div className="inline-flex items-center gap-2 rounded-full border border-[color:var(--border)] px-3 py-1.5 text-xs text-[color:var(--text-muted)]">
            <span className="h-1.5 w-1.5 rounded-full bg-[color:var(--warning)]" />
            {heroContent.statusChip}
          </div>
          <p className="mt-4 text-xs text-[color:var(--text-faint)]">{heroContent.versionNote}</p>
        </Reveal>

        <Reveal delay={0.12}>
          <div className="relative mx-auto w-full max-w-[320px]">
            <motion.div
              className="rounded-[28px] border border-[color:var(--border)] bg-[color:var(--surface)] p-3 shadow-[var(--shadow)]"
              animate={reduce ? undefined : { y: [0, -10, 0] }}
              transition={{ duration: 5.5, repeat: Infinity, ease: 'easeInOut' }}
            >
              <div className="overflow-hidden rounded-[20px] bg-[color:var(--bg-elevated)] aspect-[9/19]">
                <img
                  src="/assets/steps/step-06-results.png"
                  alt="VaakSetu results screen"
                  className="h-full w-full object-cover object-top"
                />
              </div>
            </motion.div>
            <p className="mt-3 text-center text-xs text-[color:var(--text-faint)]">
              {heroContent.phoneCaption}
            </p>
          </div>
        </Reveal>
      </div>
    </section>
  )
}
