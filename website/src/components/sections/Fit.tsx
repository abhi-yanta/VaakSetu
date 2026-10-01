import { fitContent } from '../../content/fit'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { StatusPill } from '../ui/StatusPill'
import { Reveal } from '../ui/Reveal'

export function Fit() {
  return (
    <section id="fit" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={fitContent.eyebrow}
            before={fitContent.headlineBefore}
            accent={fitContent.headlineAccent}
            intro={fitContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-3 gap-4">
          {fitContent.cards.map((card, i) => (
            <Reveal key={card.number} delay={i * 0.08}>
              <article className="card-surface p-6 h-full flex flex-col gap-4">
                <div className="flex items-start justify-between gap-3">
                  <span className="font-display text-4xl text-[color:var(--accent)]">{card.number}</span>
                  <StatusPill status={card.status} />
                </div>
                <div>
                  <span className="category-tag">{card.category}</span>
                  <h3 className="font-display text-2xl mb-2">{card.title}</h3>
                  <p className="text-sm text-[color:var(--text-muted)] m-0">{card.description}</p>
                </div>
                <FactsGrid facts={card.facts} />
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
