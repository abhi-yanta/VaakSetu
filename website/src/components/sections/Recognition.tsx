import { recognitionContent, recognitionLogos } from '../../content/recognition'
import { SectionHeader } from '../ui/SectionHeader'
import { Reveal } from '../ui/Reveal'

export function Recognition() {
  const loop = [...recognitionLogos, ...recognitionLogos]

  return (
    <section id="recognition" className="py-20 border-t border-[color:var(--border)]">
      <div className="section-shell">
        <Reveal>
          <SectionHeader
            eyebrow={recognitionContent.eyebrow}
            before={recognitionContent.headlineBefore}
            accent={recognitionContent.headlineAccent}
            intro={recognitionContent.intro}
          />
        </Reveal>
        <div className="marquee">
          <div className="marquee-track">
            {loop.map((logo, i) => (
              <div
                key={`${logo.id}-${i}`}
                className="flex flex-col items-center gap-2 min-w-[140px] opacity-80"
              >
                <img src={logo.src} alt={logo.label} className="h-12 w-auto" />
                <span className="text-[10px] uppercase tracking-wider text-[color:var(--text-faint)]">
                  {logo.category}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
