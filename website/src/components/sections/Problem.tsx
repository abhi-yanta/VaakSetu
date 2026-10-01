import { problemContent } from '../../content/problem'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Problem() {
  return (
    <section id="problem" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={problemContent.eyebrow}
            before={problemContent.headlineBefore}
            accent={problemContent.headlineAccent}
            intro={problemContent.intro}
          />
        </Reveal>
        <div className="grid md:grid-cols-2 gap-4">
          {problemContent.points.map((p, i) => (
            <Reveal key={p.title} delay={i * 0.06}>
              <article className="card-surface p-6 h-full">
                <span className="category-tag">Risk pattern 0{i + 1}</span>
                <h3 className="font-display text-2xl mb-2">{p.title}</h3>
                <p className="text-[color:var(--text-muted)] text-sm m-0">{p.body}</p>
              </article>
            </Reveal>
          ))}
        </div>
        <p className="mt-6 text-xs text-[color:var(--text-faint)]">{problemContent.note}</p>
      </div>
    </section>
  )
}
