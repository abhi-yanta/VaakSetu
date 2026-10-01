import { motion, useReducedMotion } from 'framer-motion'
import type { ComponentType } from 'react'
import { staggerContainer } from '../utils/motion'

type SectionProps = Record<string, unknown>

export default function SectionWrapper<P extends SectionProps>(
  Component: ComponentType<P>,
  idName: string,
) {
  return function HOC(props: P) {
    const reduce = useReducedMotion()

    return (
      <motion.section
        variants={reduce ? undefined : staggerContainer()}
        initial={reduce ? false : 'hidden'}
        whileInView="show"
        viewport={{ once: true, amount: 0.2 }}
        id={idName}
        className="snap-section relative mx-auto max-w-7xl px-4 py-16 sm:px-6 md:px-8"
        style={{ paddingTop: 'var(--section-pad-top)' }}
      >
        <span className="hash-span" id={`hash-${idName}`}>
          &nbsp;
        </span>
        <Component {...props} />
      </motion.section>
    )
  }
}
