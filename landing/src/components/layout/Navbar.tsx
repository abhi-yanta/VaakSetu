import { STEPS } from '../../constants'
import type { ThemeId } from '../../hooks/useTheme'

type Props = {
  theme: ThemeId
  onToggleTheme: () => void
  activeId: string
}

export default function Navbar({ theme, onToggleTheme, activeId }: Props) {
  return (
    <header
      className="fixed inset-x-0 top-0 z-50 border-b backdrop-blur-md"
      style={{
        background: 'color-mix(in srgb, var(--nav-bg) 92%, transparent)',
        borderColor: 'var(--nav-border)',
      }}
    >
      <div className="mx-auto flex max-w-7xl items-center gap-3 px-4 py-3 md:px-6">
        <a href="#hero" className="flex shrink-0 items-center gap-2 no-underline">
          <img
            src="/brand/mark.png"
            alt=""
            className={`h-8 w-8 rounded-lg object-contain ${theme === 'a' ? 'logo-glow' : ''}`}
            width={32}
            height={32}
          />
          <span className="font-display text-base font-bold" style={{ color: 'var(--text)' }}>
            VaakSetu
          </span>
        </a>

        <nav className="ml-2 hidden min-w-0 flex-1 items-center justify-center gap-3 overflow-x-auto lg:flex xl:gap-4">
          {STEPS.map((step) => (
            <a
              key={step.id}
              href={`#${step.id}`}
              className={`nav-link ${activeId === step.id ? 'is-active' : ''}`}
            >
              {step.navLabel}
            </a>
          ))}
          <a
            href="#languages"
            className={`nav-link ${activeId === 'languages' ? 'is-active' : ''}`}
          >
            Languages
          </a>
          <a
            href="#features"
            className={`nav-link ${activeId === 'features' ? 'is-active' : ''}`}
          >
            Features
          </a>
        </nav>

        <div className="ml-auto flex items-center gap-2">
          <button
            type="button"
            onClick={onToggleTheme}
            className="outline-btn !px-3 !py-2 text-xs"
            aria-label={`Switch to theme ${theme === 'a' ? 'B' : 'A'}`}
            title="Toggle theme (?theme=a | ?theme=b)"
          >
            Theme {theme === 'a' ? 'A' : 'B'}
          </button>
        </div>
      </div>
    </header>
  )
}
