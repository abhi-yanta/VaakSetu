import { audienceContent } from '../../content/audience'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Audience() {
  return (
    <section id="audience" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={audienceContent.eyebrow}
            before={audienceContent.headlineBefore}
            accent={audienceContent.headlineAccent}
            intro={audienceContent.intro}
          />
        </Reveal>
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {audienceContent.groups.map((g, i) => (
            <Reveal key={g.number} delay={i * 0.05}>
              <article className="card-surface p-6 h-full">
                <span className="font-display text-4xl text-[color:var(--accent)]">{g.number}</span>
                <h3 className="font-display text-2xl mt-3 mb-2">{g.title}</h3>
                <p className="text-sm text-[color:var(--text-muted)] m-0 mb-3">{g.body}</p>
                <p className="text-xs text-[color:var(--text-faint)] m-0">{g.note}</p>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
