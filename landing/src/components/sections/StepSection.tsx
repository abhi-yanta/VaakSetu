import { lazy, Suspense, useEffect, useRef, useState } from 'react'
import { motion, useReducedMotion, useScroll, useTransform } from 'framer-motion'
import type { WorkflowStep } from '../../constants'
import { fadeIn, textVariant } from '../../utils/motion'
import { SectionWrapper } from '../../hoc'

const PhoneCanvas = lazy(() => import('../canvas/Phone'))

type Props = {
  step: WorkflowStep
  reverse?: boolean
  index: number
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

function StepSectionInner({ step, reverse, index }: Props) {
  const reduce = useReducedMotion()
  const desktop = useIsDesktop()
  const show3d = desktop && !reduce
  const ref = useRef<HTMLDivElement>(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ['start end', 'end start'],
  })
  const rotate = useTransform(scrollYProgress, [0, 1], reverse ? [0.25, -0.25] : [-0.25, 0.25])
  const [scrollRotate, setScrollRotate] = useState(0)

  useEffect(() => {
    if (reduce) return
    return rotate.on('change', (v) => setScrollRotate(v))
  }, [reduce, rotate])

  const textDir = reverse ? 'left' : 'right'
  const phoneDir = reverse ? 'right' : 'left'

  return (
    <div
      ref={ref}
      className={`grid w-full items-center gap-10 md:gap-14 ${
        reverse ? 'lg:grid-cols-[1fr_1.05fr]' : 'lg:grid-cols-[1.05fr_1fr]'
      }`}
    >
      <motion.div
        variants={reduce ? undefined : fadeIn(textDir, 'spring', 0.15, 0.7)}
        className={reverse ? 'lg:order-2' : ''}
      >
        <motion.p
          variants={reduce ? undefined : textVariant(0.1)}
          className="font-display text-6xl font-bold leading-none opacity-20 md:text-8xl"
          style={{ color: 'var(--accent)' }}
        >
          {step.number}
        </motion.p>
        <p
          className="mt-2 font-display text-sm font-semibold tracking-[0.2em]"
          style={{ color: 'var(--accent)' }}
        >
          STEP {step.number}
        </p>
        <h2
          className="mt-3 font-display text-3xl font-bold tracking-tight md:text-4xl"
          style={{ color: 'var(--text)' }}
        >
          {step.title}
        </h2>
        <p
          className="mt-4 max-w-lg text-base leading-relaxed md:text-lg"
          style={{ color: 'var(--text-soft)' }}
        >
          {step.body}
        </p>

        <div className="mt-8 grid gap-3 sm:grid-cols-3">
          {step.bullets.map((b, i) => (
            <motion.div
              key={b.title}
              variants={reduce ? undefined : fadeIn('up', 'spring', 0.2 + i * 0.1, 0.55)}
              className="tilt-card"
              style={{
                transform: reduce
                  ? undefined
                  : `perspective(800px) rotateY(${(i - 1) * 4}deg)`,
              }}
            >
              <h3 className="text-sm font-semibold" style={{ color: 'var(--text)' }}>
                {b.title}
              </h3>
              <p className="mt-1.5 text-xs leading-relaxed" style={{ color: 'var(--text-muted)' }}>
                {b.body}
              </p>
            </motion.div>
          ))}
        </div>
      </motion.div>

      <motion.div
        variants={reduce ? undefined : fadeIn(phoneDir, 'spring', 0.25, 0.8)}
        className={`relative mx-auto h-[min(62vh,520px)] w-full max-w-sm ${
          reverse ? 'lg:order-1' : ''
        }`}
      >
        {show3d ? (
          <Suspense
            fallback={
              <img
                src={step.texture}
                alt={step.textureAlt}
                className="mx-auto max-h-full rounded-[2rem] object-contain shadow-2xl"
              />
            }
          >
            <PhoneCanvas
              textureUrl={step.texture}
              scrollRotate={scrollRotate}
              autoRotate={false}
              parallax={index === 0}
              className="h-full w-full"
            />
          </Suspense>
        ) : (
          <img
            src={step.texture}
            alt={step.textureAlt}
            className="mx-auto max-h-full max-w-[260px] rounded-[2rem] object-contain shadow-2xl"
          />
        )}
      </motion.div>
    </div>
  )
}

/** One component per step — driven by STEPS array entry. */
export default function createStepSection(step: WorkflowStep, index: number) {
  const reverse = index % 2 === 1
  const Wrapped = SectionWrapper(
    () => <StepSectionInner step={step} reverse={reverse} index={index} />,
    step.id,
  )
  return Wrapped
}
