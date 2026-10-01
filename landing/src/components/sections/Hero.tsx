import { lazy, Suspense, useEffect, useState } from 'react'
import { motion, useReducedMotion } from 'framer-motion'
import { hero } from '../../constants'
import type { ThemeId } from '../../hooks/useTheme'
import { fadeIn, slideIn, textVariant } from '../../utils/motion'

const PhoneCanvas = lazy(() => import('../canvas/Phone'))
const StarsCanvas = lazy(() => import('../canvas/StarsCanvas'))

type Props = {
  theme: ThemeId
}

function useIsDesktop() {
  const [desktop, setDesktop] = useState(false)
  useEffect(() => {
    const mq = window.matchMedia('(min-width: 900px)')
    const update = () => setDesktop(mq.matches)
    update()
    mq.addEventListener('change', update)
    return () => mq.removeEventListener('change', update)
  }, [])
  return desktop
}

export default function Hero({ theme }: Props) {
  const reduce = useReducedMotion()
  const desktop = useIsDesktop()
  const show3d = desktop && !reduce

  return (
    <section
      id="hero"
      className="snap-section relative flex items-center overflow-hidden px-4"
      style={{ paddingTop: 'var(--section-pad-top)' }}
    >
      {theme === 'a' && show3d && (
        <Suspense fallback={null}>
          <StarsCanvas enabled color="#e2e8f0" />
        </Suspense>
      )}
      {theme === 'b' && <div className="atmosphere-b" aria-hidden />}

      <div className="relative z-10 mx-auto grid w-full max-w-7xl items-center gap-10 lg:grid-cols-[1.05fr_0.95fr] lg:gap-6">
        <motion.div
          variants={reduce ? undefined : slideIn('left', 'tween', 0.1, 0.8)}
          initial={reduce ? false : 'hidden'}
          animate="show"
          className="flex flex-col items-start text-left"
        >
          <motion.div variants={reduce ? undefined : textVariant(0.15)}>
            <img
              src="/brand/mark.png"
              alt=""
              className={`mb-5 h-14 w-14 object-contain md:h-16 md:w-16 ${
                theme === 'a' ? 'logo-glow' : ''
              }`}
              width={64}
              height={64}
            />
            <p
              className="mb-2 text-sm uppercase tracking-[0.35em]"
              style={{ color: 'var(--accent)' }}
            >
              {hero.nameHi}
            </p>
            <h1
              className="font-display text-5xl font-bold tracking-tight md:text-7xl"
              style={{
                color: 'var(--text)',
                textShadow: theme === 'a' ? 'var(--hero-glow)' : undefined,
              }}
            >
              {hero.name}
            </h1>
          </motion.div>

          <motion.p
            variants={reduce ? undefined : fadeIn('up', 'tween', 0.35, 0.7)}
            className="mt-5 max-w-md text-lg leading-relaxed md:text-xl"
            style={{ color: 'var(--text-soft)' }}
          >
            {hero.tagline}
          </motion.p>
          <motion.p
            variants={reduce ? undefined : fadeIn('up', 'tween', 0.45, 0.7)}
            className="mt-3 max-w-md text-sm leading-relaxed md:text-base"
            style={{ color: 'var(--text-muted)' }}
          >
            {hero.subtitle}
          </motion.p>

          <motion.div
            variants={reduce ? undefined : fadeIn('up', 'tween', 0.55, 0.7)}
            className="mt-10"
          >
            <a href="#welcome" className="outline-btn">
              Learn more
            </a>
          </motion.div>
        </motion.div>

        <motion.div
          variants={reduce ? undefined : slideIn('right', 'tween', 0.2, 0.9)}
          initial={reduce ? false : 'hidden'}
          animate="show"
          className="relative mx-auto flex h-[min(70vh,560px)] w-full max-w-md items-center justify-center"
        >
          {show3d ? (
            <Suspense
              fallback={
                <img
                  src="/assets/steps/step-01-welcome.png"
                  alt="VaakSetu on phone"
                  className="max-h-full w-auto rounded-[2rem] object-contain shadow-2xl"
                />
              }
            >
              <PhoneCanvas
                textureUrl="/assets/steps/step-01-welcome.png"
                autoRotate
                parallax
                className="h-full w-full"
              />
            </Suspense>
          ) : (
            <img
              src="/assets/steps/step-01-welcome.png"
              alt="VaakSetu welcome on phone"
              className="max-h-full w-auto max-w-[280px] rounded-[2rem] object-contain shadow-2xl"
            />
          )}
        </motion.div>
      </div>

      <a
        href="#welcome"
        className="scroll-indicator absolute bottom-6 left-1/2 z-10 -translate-x-1/2"
        aria-label="Scroll to workflow"
      >
        <span className="scroll-indicator__mouse">
          <span className="scroll-indicator__wheel" />
        </span>
      </a>
    </section>
  )
}
