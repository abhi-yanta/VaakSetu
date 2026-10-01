import { footerContent } from '../../content/cta'

export function Footer() {
  return (
    <footer className="border-t border-[color:var(--border)] py-14">
      <div className="section-shell grid md:grid-cols-[1.2fr_1fr_1fr_1fr] gap-10">
        <div>
          <img src="/brand/lockup.png" alt="VaakSetu" className="h-9 w-auto mb-4" />
          <p className="text-sm text-[color:var(--text-muted)] m-0 mb-3">{footerContent.tagline}</p>
          <p className="text-xs text-[color:var(--text-faint)] m-0">{footerContent.location}</p>
          <p className="text-xs text-[color:var(--text-faint)] mt-3 m-0">{footerContent.note}</p>
        </div>
        <div>
          <h3 className="text-xs uppercase tracking-[0.14em] text-[color:var(--accent)] mb-3">Explore</h3>
          <ul className="m-0 p-0 list-none space-y-2 text-sm text-[color:var(--text-muted)]">
            {footerContent.explore.map((l) => (
              <li key={l.href}>
                <a href={l.href}>{l.label}</a>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <h3 className="text-xs uppercase tracking-[0.14em] text-[color:var(--accent)] mb-3">Company</h3>
          <ul className="m-0 p-0 list-none space-y-2 text-sm text-[color:var(--text-muted)]">
            {footerContent.company.map((l) => (
              <li key={l.href}>
                <a href={l.href}>{l.label}</a>
              </li>
            ))}
          </ul>
        </div>
        <div>
          <h3 className="text-xs uppercase tracking-[0.14em] text-[color:var(--accent)] mb-3">Connect</h3>
          <ul className="m-0 p-0 list-none space-y-2 text-sm text-[color:var(--text-muted)]">
            {footerContent.connect.map((l) => (
              <li key={l.label}>
                <a href={l.href}>{l.label}</a>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </footer>
  )
}
