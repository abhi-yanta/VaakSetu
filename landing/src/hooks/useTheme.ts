import { useCallback, useEffect, useState } from 'react'

export type ThemeId = 'a' | 'b'

function readThemeFromUrl(): ThemeId {
  const params = new URLSearchParams(window.location.search)
  const q = params.get('theme')
  if (q === 'a' || q === 'b') return q
  return 'a'
}

function applyTheme(theme: ThemeId) {
  document.documentElement.setAttribute('data-theme', theme)
  const url = new URL(window.location.href)
  url.searchParams.set('theme', theme)
  window.history.replaceState({}, '', url)
}

export function useTheme() {
  const [theme, setThemeState] = useState<ThemeId>(() => {
    if (typeof window === 'undefined') return 'a'
    return readThemeFromUrl()
  })

  useEffect(() => {
    applyTheme(theme)
  }, [theme])

  const setTheme = useCallback((next: ThemeId) => {
    setThemeState(next)
  }, [])

  const toggle = useCallback(() => {
    setThemeState((t) => (t === 'a' ? 'b' : 'a'))
  }, [])

  return { theme, setTheme, toggle }
}
