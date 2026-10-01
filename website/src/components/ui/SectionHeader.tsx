import type { ReactNode } from 'react'

type Props = {
  eyebrow: string
  before: string
  accent: string
  intro: string
  children?: ReactNode
  id?: string
  className?: string
}

export function SectionHeader({
  eyebrow,
  before,
  accent,
  intro,
  children,
  id,
  className = '',
}: Props) {
  return (
    <header id={id} className={`mb-10 max-w-3xl ${className}`}>
      <p className="eyebrow">{eyebrow}</p>
      <h2 className="headline">
        {before}{' '}
        <em className="italic-accent not-italic italic">{accent}</em>
      </h2>
      <p className="intro">{intro}</p>
      {children}
    </header>
  )
}
