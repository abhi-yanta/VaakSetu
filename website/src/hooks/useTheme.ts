import { useEffect, useState } from 'react'

export type ThemeId = 'a' | 'b'

function readThemeFromUrl(): ThemeId {
  const params = new URLSearchParams(window.location.search)
  const q = params.get('theme')
  if (q === 'b') return 'b'
  if (q === 'a') return 'a'
  const stored = localStorage.getItem('vaaksetu-theme')
  return stored === 'b' ? 'b' : 'a'
}

export function useTheme() {
  const [theme, setThemeState] = useState<ThemeId>(() =>
    typeof window === 'undefined' ? 'a' : readThemeFromUrl(),
  )

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem('vaaksetu-theme', theme)
    const url = new URL(window.location.href)
    url.searchParams.set('theme', theme)
    window.history.replaceState({}, '', url.toString())
  }, [theme])

  const setTheme = (next: ThemeId) => setThemeState(next)
  const toggle = () => setThemeState((t) => (t === 'a' ? 'b' : 'a'))

  return { theme, setTheme, toggle }
}
