import { roadmapContent } from '../../content/roadmap'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Roadmap() {
  return (
    <section id="roadmap" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={roadmapContent.eyebrow}
            before={roadmapContent.headlineBefore}
            accent={roadmapContent.headlineAccent}
            intro={roadmapContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-3 gap-4">
          {roadmapContent.columns.map((col, i) => (
            <Reveal key={col.title} delay={i * 0.06}>
              <article className="card-surface p-6 h-full">
                <span className="category-tag">{col.title}</span>
                <h3 className="font-display text-2xl mb-4">{col.title}</h3>
                <ol className="m-0 pl-5 space-y-3 text-sm text-[color:var(--text-muted)]">
                  {col.items.map((item, idx) => (
                    <li key={item}>
                      <span className="text-[color:var(--accent)] font-semibold mr-1">
                        {String(idx + 1).padStart(2, '0')}
                      </span>
                      {item}
                    </li>
                  ))}
                </ol>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
