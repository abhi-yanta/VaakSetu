import { useScrollProgress } from '../../hooks/useScrollProgress'
import type { ThemeId } from '../../hooks/useTheme'
import { navLinks } from '../../content/hero'

type Props = {
  theme: ThemeId
  onToggleTheme: () => void
  onOpenAccess: () => void
}

export function Navbar({ theme, onToggleTheme, onOpenAccess }: Props) {
  const progress = useScrollProgress()

  return (
    <>
      <div className="progress-bar" style={{ transform: `scaleX(${progress})` }} />
      <header
        className="fixed inset-x-0 top-0 z-70 glass"
        style={{ background: 'var(--surface-glass)', borderBottom: '1px solid var(--border)' }}
      >
        <div className="section-shell flex h-16 items-center justify-between gap-4">
          <a href="#top" className="flex items-center gap-2 shrink-0">
            <img src="/brand/lockup.png" alt="VaakSetu" className="h-8 w-auto" />
          </a>
          <nav className="hidden lg:flex items-center gap-5 text-sm text-[color:var(--text-muted)]">
            {navLinks.map((l) => (
              <a key={l.href} href={l.href} className="hover:text-[color:var(--text)] transition-colors">
                {l.label}
              </a>
            ))}
          </nav>
          <div className="flex items-center gap-2">
            <button
              type="button"
              className="btn btn-ghost text-xs"
              onClick={onToggleTheme}
              aria-label="Toggle theme"
            >
              Theme {theme.toUpperCase()}
            </button>
            <button type="button" className="btn btn-secondary !py-2 !px-3 text-sm" onClick={onOpenAccess}>
              Early access
            </button>
            <a className="btn btn-primary !py-2 !px-3 text-sm" href="https://github.com/abhi-yanta/VaakSetu">
              Download
            </a>
          </div>
        </div>
      </header>
    </>
  )
}
