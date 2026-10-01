import type { Variants } from 'framer-motion'

export const textVariant = (delay = 0): Variants => ({
  hidden: { y: -40, opacity: 0 },
  show: {
    y: 0,
    opacity: 1,
    transition: { type: 'spring', duration: 1.1, delay },
  },
})

export const fadeIn = (
  direction: 'left' | 'right' | 'up' | 'down' | '' = '',
  type: 'spring' | 'tween' = 'spring',
  delay = 0,
  duration = 0.75,
): Variants => ({
  hidden: {
    x: direction === 'left' ? 80 : direction === 'right' ? -80 : 0,
    y: direction === 'up' ? 60 : direction === 'down' ? -60 : 0,
    opacity: 0,
  },
  show: {
    x: 0,
    y: 0,
    opacity: 1,
    transition: { type, delay, duration, ease: 'easeOut' },
  },
})

export const slideIn = (
  direction: 'left' | 'right' | 'up' | 'down',
  type: 'spring' | 'tween' = 'tween',
  delay = 0,
  duration = 0.7,
): Variants => ({
  hidden: {
    x: direction === 'left' ? '-100%' : direction === 'right' ? '100%' : 0,
    y: direction === 'up' ? '100%' : direction === 'down' ? '-100%' : 0,
    opacity: 0,
  },
  show: {
    x: 0,
    y: 0,
    opacity: 1,
    transition: { type, delay, duration, ease: 'easeOut' },
  },
})

export const staggerContainer = (
  staggerChildren = 0.12,
  delayChildren = 0,
): Variants => ({
  hidden: {},
  show: {
    transition: { staggerChildren, delayChildren },
  },
})

export const zoomIn = (delay = 0, duration = 0.6): Variants => ({
  hidden: { scale: 0.85, opacity: 0 },
  show: {
    scale: 1,
    opacity: 1,
    transition: { type: 'tween', delay, duration, ease: 'easeOut' },
  },
})
