import { techContent } from '../../content/tech'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { Reveal } from '../ui/Reveal'

export function Tech() {
  return (
    <section id="tech" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={techContent.eyebrow}
            before={techContent.headlineBefore}
            accent={techContent.headlineAccent}
            intro={techContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-2 gap-4 mb-8">
          {techContent.layers.map((layer, i) => (
            <Reveal key={layer.title} delay={i * 0.05}>
              <article className="card-surface p-6 h-full">
                <span className="category-tag">{layer.category}</span>
                <h3 className="font-display text-2xl mb-2">{layer.title}</h3>
                <p className="text-sm text-[color:var(--text-muted)] mb-4">{layer.description}</p>
                <FactsGrid facts={layer.facts} />
              </article>
            </Reveal>
          ))}
        </div>
        <Reveal>
          <div className="card-surface p-6">
            <h3 className="font-display text-2xl mb-4">Android permissions</h3>
            <div className="grid sm:grid-cols-2 gap-3 mb-4">
              {techContent.permissions.map((p) => (
                <div key={p.name} className="fact-item">
                  <span className="fact-label">{p.name}</span>
                  <span className="fact-value">{p.why}</span>
                </div>
              ))}
            </div>
            <p className="text-sm text-[color:var(--text-muted)] m-0">{techContent.privacyNote}</p>
          </div>
        </Reveal>
      </div>
    </section>
  )
}
