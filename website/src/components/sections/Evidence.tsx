import { evidenceContent } from '../../content/evidence'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Evidence() {
  return (
    <section id="evidence" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={evidenceContent.eyebrow}
            before={evidenceContent.headlineBefore}
            accent={evidenceContent.headlineAccent}
            intro={evidenceContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-2 gap-4 mb-10">
          <Reveal>
            <article className="card-surface p-6 h-full">
              <span className="category-tag">What it can do</span>
              <ul className="m-0 pl-5 space-y-2 text-sm text-[color:var(--text-muted)]">
                {evidenceContent.canDo.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </article>
          </Reveal>
          <Reveal delay={0.08}>
            <article className="card-surface p-6 h-full">
              <span className="category-tag">What it cannot claim</span>
              <ul className="m-0 pl-5 space-y-2 text-sm text-[color:var(--text-muted)]">
                {evidenceContent.cannotDo.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </article>
          </Reveal>
        </div>
        <Reveal>
          <h3 className="font-display text-3xl mb-6">Open validation questions</h3>
        </Reveal>
        <ol className="space-y-4 m-0 p-0 list-none">
          {evidenceContent.questions.map((q, i) => (
            <Reveal key={q.number} delay={i * 0.04}>
              <li className="card-surface p-5 grid sm:grid-cols-[4rem_1fr] gap-4 items-start">
                <span className="font-display text-3xl text-[color:var(--accent)]">{q.number}</span>
                <div>
                  <h4 className="m-0 mb-1 text-lg">{q.title}</h4>
                  <p className="m-0 text-sm text-[color:var(--text-muted)]">{q.body}</p>
                </div>
              </li>
            </Reveal>
          ))}
        </ol>
      </div>
    </section>
  )
}
