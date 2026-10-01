import { ctaContent } from '../../content/cta'
import { Reveal } from '../ui/Reveal'

type Props = {
  onOpenAccess: () => void
}

export function CtaBanner({ onOpenAccess }: Props) {
  return (
    <section id="cta" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <div
            className="card-surface p-8 sm:p-12 relative overflow-hidden"
            style={{
              background:
                'linear-gradient(135deg, var(--accent-soft), transparent 55%), var(--surface)',
            }}
          >
            <p className="eyebrow">{ctaContent.eyebrow}</p>
            <h2 className="headline">
              {ctaContent.headlineBefore}{' '}
              <em className="italic-accent not-italic italic">{ctaContent.headlineAccent}</em>
            </h2>
            <p className="intro">{ctaContent.intro}</p>
            <div className="flex flex-wrap gap-3">
              <a className="btn btn-primary" href={ctaContent.downloadHref}>
                {ctaContent.primary}
              </a>
              <button type="button" className="btn btn-secondary" onClick={onOpenAccess}>
                {ctaContent.secondary}
              </button>
            </div>
          </div>
        </Reveal>
      </div>
    </section>
  )
}
