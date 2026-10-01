import { documentsContent } from '../../content/documents'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { StatusPill } from '../ui/StatusPill'
import { Reveal } from '../ui/Reveal'

export function Documents() {
  return (
    <section id="documents" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={documentsContent.eyebrow}
            before={documentsContent.headlineBefore}
            accent={documentsContent.headlineAccent}
            intro={documentsContent.intro}
          />
        </Reveal>
        <div className="grid lg:grid-cols-2 gap-4">
          {documentsContent.types.map((doc, i) => (
            <Reveal key={doc.category} delay={i * 0.05}>
              <article className="card-surface p-6 h-full flex flex-col gap-4">
                <div className="flex items-start justify-between gap-3">
                  <span className="category-tag">{doc.category}</span>
                  <StatusPill status={doc.status} />
                </div>
                <h3 className="font-display text-2xl m-0">{doc.title}</h3>
                <p className="text-sm text-[color:var(--text-muted)] m-0">
                  <strong className="text-[color:var(--text)]">Example:</strong> {doc.example}
                </p>
                <p className="text-sm text-[color:var(--text-muted)] m-0">
                  <strong className="text-[color:var(--text)]">Read aloud:</strong> {doc.readAloud}
                </p>
                <p className="text-sm text-[color:var(--text-muted)] m-0">
                  <strong className="text-[color:var(--text)]">Limits:</strong> {doc.limitations}
                </p>
                <FactsGrid facts={doc.facts} />
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
