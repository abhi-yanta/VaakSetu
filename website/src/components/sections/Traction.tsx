import { tractionContent } from '../../content/traction'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { Reveal } from '../ui/Reveal'

export function Traction() {
  return (
    <section id="traction" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={tractionContent.eyebrow}
            before={tractionContent.headlineBefore}
            accent={tractionContent.headlineAccent}
            intro={tractionContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-2 gap-4">
          {tractionContent.cards.map((card, i) => (
            <Reveal key={card.title} delay={i * 0.06}>
              <article className="card-surface overflow-hidden h-full">
                <img src={card.photo} alt={card.caption} className="w-full aspect-[4/3] object-cover" />
                <div className="p-6">
                  <span className="category-tag">{card.category}</span>
                  <h3 className="font-display text-2xl mb-1">{card.title}</h3>
                  <p className="text-xs text-[color:var(--text-faint)] mb-4">{card.caption}</p>
                  <FactsGrid facts={card.facts} />
                </div>
              </article>
            </Reveal>
          ))}
        </div>
        {tractionContent.counters.length === 0 && (
          <p className="mt-6 text-sm text-[color:var(--text-faint)]">
            No Team-reported counters yet — animated stats stay empty until real numbers exist in the repo.
          </p>
        )}
      </div>
    </section>
  )
}
