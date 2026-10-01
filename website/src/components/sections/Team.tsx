import { teamContent } from '../../content/team'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Team() {
  return (
    <section id="team" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={teamContent.eyebrow}
            before={teamContent.headlineBefore}
            accent={teamContent.headlineAccent}
            intro={teamContent.intro}
          />
        </Reveal>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {teamContent.members.map((m, i) => (
            <Reveal key={`${m.name}-${i}`} delay={i * 0.05}>
              <article className="card-surface p-5 h-full text-center">
                <img
                  src={m.photo}
                  alt={m.name}
                  className="mx-auto mb-4 h-36 w-36 rounded-full object-cover border border-[color:var(--border)]"
                />
                <h3 className="font-display text-2xl m-0 mb-1">{m.name}</h3>
                <p className="text-sm text-[color:var(--text-muted)] m-0 mb-3">{m.role}</p>
                <a className="text-sm text-[color:var(--accent)]" href="#">
                  {m.linkedin}
                </a>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
