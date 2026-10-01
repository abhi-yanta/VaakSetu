import { motion, useReducedMotion } from 'framer-motion'
import { FEATURES, finaleCaveat } from '../../constants'
import { fadeIn, textVariant } from '../../utils/motion'
import { SectionWrapper } from '../../hoc'

function FeaturesInner() {
  const reduce = useReducedMotion()

  return (
    <>
      <motion.div variants={reduce ? undefined : textVariant()}>
        <p className="section-eyebrow">Features</p>
        <h2 className="section-title">Built for listening first</h2>
        <p className="section-lead">
          Real capabilities from the Flutter app — not marketing inventions.
        </p>
      </motion.div>

      <div className="mt-12 grid gap-5 sm:grid-cols-2">
        {FEATURES.map((f, i) => (
          <motion.article
            key={f.title}
            variants={reduce ? undefined : fadeIn('up', 'spring', 0.12 + i * 0.08, 0.6)}
            className="feature-block"
          >
            <h3 className="text-lg font-semibold" style={{ color: 'var(--text)' }}>
              {f.title}
            </h3>
            <p className="mt-2 text-sm leading-relaxed" style={{ color: 'var(--text-soft)' }}>
              {f.body}
            </p>
          </motion.article>
        ))}
      </div>

      <motion.div
        variants={reduce ? undefined : fadeIn('up', 'tween', 0.35, 0.7)}
        className="mt-14 flex flex-col items-start gap-4 border-t pt-10"
        style={{ borderColor: 'var(--border-soft)' }}
      >
        <h3 className="font-display text-2xl font-bold" style={{ color: 'var(--text)' }}>
          Get VaakSetu
        </h3>
        <p className="max-w-xl text-sm" style={{ color: 'var(--text-muted)' }}>
          Android APK / Play listing coming soon. Clone the repo and run the Flutter app today.
        </p>
        <div className="flex flex-wrap gap-3">
          <a
            className="solid-btn"
            href="https://github.com/abhi-yanta/VaakSetu"
            target="_blank"
            rel="noreferrer"
          >
            View on GitHub
          </a>
          <a className="outline-btn" href="#hero">
            Back to top
          </a>
        </div>
        <p className="mt-4 max-w-2xl text-xs leading-relaxed" style={{ color: 'var(--text-muted)' }}>
          {finaleCaveat}
        </p>
      </motion.div>

      <footer
        className="mt-16 flex flex-col items-center gap-3 border-t pt-8 text-center"
        style={{ borderColor: 'var(--border-soft)' }}
      >
        <img
          src="/brand/lockup.png"
          alt="VaakSetu"
          className="h-10 w-auto object-contain opacity-90"
        />
        <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
          © {new Date().getFullYear()} VaakSetu — The Voice Bridge. Option 4 brand mark.
        </p>
      </footer>
    </>
  )
}

export default SectionWrapper(FeaturesInner, 'features')
