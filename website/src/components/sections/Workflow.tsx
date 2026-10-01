import { workflowContent } from '../../content/workflow'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { StatusPill } from '../ui/StatusPill'
import { Reveal } from '../ui/Reveal'

export function Workflow() {
  return (
    <section id="workflow" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={workflowContent.eyebrow}
            before={workflowContent.headlineBefore}
            accent={workflowContent.headlineAccent}
            intro={workflowContent.intro}
          >
            <p className="text-sm border border-[color:var(--warning)]/40 bg-[color:var(--warning)]/10 px-4 py-3 rounded-[var(--radius)] text-[color:var(--text)]">
              {workflowContent.flagNote}
            </p>
          </SectionHeader>
        </Reveal>
        <div className="space-y-8">
          {workflowContent.steps.map((step, i) => (
            <Reveal key={step.id} delay={Math.min(i * 0.04, 0.2)}>
              <article className="card-surface overflow-hidden grid lg:grid-cols-[0.9fr_1.1fr]">
                <div className="bg-[color:var(--bg-elevated)] p-4 sm:p-6 border-b lg:border-b-0 lg:border-r border-[color:var(--border)]">
                  <img
                    src={step.screenshot}
                    alt={step.title}
                    className="w-full aspect-[9/16] max-h-[420px] object-cover object-top rounded-[var(--radius)] mx-auto"
                  />
                  <p className="mt-3 text-xs text-center text-[color:var(--text-faint)]">
                    {step.screenshotNote}
                  </p>
                </div>
                <div className="p-6 sm:p-8 flex flex-col gap-4">
                  <div className="flex flex-wrap items-center justify-between gap-3">
                    <span className="font-display text-4xl text-[color:var(--accent)]">{step.number}</span>
                    <StatusPill status={step.status} />
                  </div>
                  <div>
                    <span className="category-tag">{step.category}</span>
                    <h3 className="font-display text-3xl mb-2">{step.title}</h3>
                    <p className="text-[color:var(--text-muted)] m-0">{step.description}</p>
                  </div>
                  <dl className="grid sm:grid-cols-3 gap-3 text-sm">
                    <div>
                      <dt className="fact-label">User does</dt>
                      <dd className="m-0 text-[color:var(--text)]">{step.userDoes}</dd>
                    </div>
                    <div>
                      <dt className="fact-label">App does</dt>
                      <dd className="m-0 text-[color:var(--text)]">{step.appDoes}</dd>
                    </div>
                    <div>
                      <dt className="fact-label">Tech</dt>
                      <dd className="m-0 text-[color:var(--text)]">{step.tech}</dd>
                    </div>
                  </dl>
                  <FactsGrid facts={step.facts} />
                </div>
              </article>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  )
}
