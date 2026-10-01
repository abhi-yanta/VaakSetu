import { useEffect, useState } from 'react'

export function BackToTop() {
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    const onScroll = () => setVisible(window.scrollY > 700)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  if (!visible) return null

  return (
    <a
      href="#top"
      className="fixed bottom-6 right-6 z-60 btn btn-secondary !rounded-full !px-4 !py-3 shadow-lg"
      aria-label="Back to top"
    >
      ↑
    </a>
  )
}
