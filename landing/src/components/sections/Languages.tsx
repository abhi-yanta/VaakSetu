import { lazy, Suspense, useEffect, useState } from 'react'
import { motion, useReducedMotion } from 'framer-motion'
import { LANGUAGES } from '../../constants'
import { fadeIn, textVariant } from '../../utils/motion'
import { SectionWrapper } from '../../hoc'

const BallCanvas = lazy(() => import('../canvas/Ball'))

const BALL_COLORS = [
  ['#00695C', '#E65100'],
  ['#0f766e', '#ea580c'],
  ['#115e59', '#c2410c'],
  ['#134e4a', '#E65100'],
]

function useCan3d() {
  const [ok, setOk] = useState(false)
  const reduce = useReducedMotion()
  useEffect(() => {
    const mq = window.matchMedia('(min-width: 640px)')
    const update = () => setOk(mq.matches && !reduce)
    update()
    mq.addEventListener('change', update)
    return () => mq.removeEventListener('change', update)
  }, [reduce])
  return ok
}

function LanguagesInner() {
  const reduce = useReducedMotion()
  const can3d = useCan3d()

  return (
    <>
      <motion.div variants={reduce ? undefined : textVariant()}>
        <p className="section-eyebrow">Languages</p>
        <h2 className="section-title">12 Indian languages</h2>
        <p className="section-lead">
          From <code className="inline-code">Language.supportedLanguages</code> — names in their
          own scripts. Spoken UI and TTS follow the language you pick.
        </p>
      </motion.div>

      <div className="mt-12 grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 md:gap-6">
        {LANGUAGES.map((lang, i) => {
          const [color, accent] = BALL_COLORS[i % BALL_COLORS.length]
          return (
            <motion.div
              key={lang.code}
              variants={reduce ? undefined : fadeIn('up', 'spring', i * 0.06, 0.55)}
              className="lang-card flex flex-col items-center"
            >
              <div className="h-28 w-28 sm:h-32 sm:w-32">
                {can3d ? (
                  <Suspense
                    fallback={
                      <div className="lang-fallback" style={{ background: color }}>
                        <span>{lang.script}</span>
                      </div>
                    }
                  >
                    <BallCanvas
                      native={lang.native}
                      script={lang.script}
                      color={color}
                      accent={accent}
                    />
                  </Suspense>
                ) : (
                  <div className="lang-fallback" style={{ background: color }}>
                    <span className="text-3xl font-bold text-white">{lang.script}</span>
                    <span className="mt-1 text-xs text-white/90">{lang.native}</span>
                  </div>
                )}
              </div>
              <p className="mt-2 text-center text-sm font-semibold" style={{ color: 'var(--text)' }}>
                {lang.native}
              </p>
              <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
                {lang.english}
              </p>
            </motion.div>
          )
        })}
      </div>
    </>
  )
}

export default SectionWrapper(LanguagesInner, 'languages')
