import { languagesContent } from '../../content/languages'
import { SectionHeader } from '../ui/SectionHeader'
import { FactsGrid } from '../ui/FactsGrid'
import { Reveal } from '../ui/Reveal'

export function Languages() {
  return (
    <section id="languages" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={languagesContent.eyebrow}
            before={languagesContent.headlineBefore}
            accent={languagesContent.headlineAccent}
            intro={languagesContent.intro}
          />
        </Reveal>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-3 mb-8">
          {languagesContent.languages.map((lang, i) => (
            <Reveal key={lang.code} delay={i * 0.03}>
              <article className="card-surface p-4 h-full">
                <span className="category-tag">{lang.code}</span>
                <div className="flex items-baseline justify-between gap-2 mb-2">
                  <h3 className="font-display text-2xl m-0">{lang.native}</h3>
                  <span className="text-2xl text-[color:var(--accent)]" aria-hidden>
                    {lang.script}
                  </span>
                </div>
                <p className="text-sm text-[color:var(--text-muted)] m-0 mb-3">{lang.english}</p>
                <FactsGrid
                  facts={[
                    { label: 'Text', value: 'UI localized' },
                    { label: 'Voice', value: `TTS ${lang.tts}` },
                    { label: 'Script', value: lang.script },
                    { label: 'STT', value: 'Not built' },
                  ]}
                />
              </article>
            </Reveal>
          ))}
        </div>
        <FactsGrid facts={languagesContent.facts} />
      </div>
    </section>
  )
}
