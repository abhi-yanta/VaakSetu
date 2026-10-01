import { Suspense, useEffect, useState } from 'react'
import { Canvas } from '@react-three/fiber'
import { Preload } from '@react-three/drei'
import Stars from './Stars'
import CanvasLoader from './Loader'

type Props = {
  enabled?: boolean
  color?: string
}

export default function StarsCanvas({ enabled = true, color = '#ffffff' }: Props) {
  const [mount, setMount] = useState(false)
  const [reduce, setReduce] = useState(false)

  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
    setReduce(mq.matches)
    const onChange = () => setReduce(mq.matches)
    mq.addEventListener('change', onChange)

    let cancelled = false
    let idleId: number | undefined
    let timeoutId: ReturnType<typeof setTimeout> | undefined

    const mount = () => {
      if (!cancelled) setMount(true)
    }

    if ('requestIdleCallback' in window) {
      idleId = (
        window as Window & { requestIdleCallback: (cb: () => void) => number }
      ).requestIdleCallback(mount)
    } else {
      timeoutId = setTimeout(mount, 200)
    }

    return () => {
      cancelled = true
      mq.removeEventListener('change', onChange)
      if (idleId !== undefined && 'cancelIdleCallback' in window) {
        ;(
          window as Window & { cancelIdleCallback: (id: number) => void }
        ).cancelIdleCallback(idleId)
      }
      if (timeoutId !== undefined) clearTimeout(timeoutId)
    }
  }, [])

  if (!enabled || reduce || !mount) return null

  return (
    <div className="pointer-events-none absolute inset-0 z-0 h-auto w-full">
      <Canvas
        camera={{ position: [0, 0, 1] }}
        dpr={[1, 1.25]}
        gl={{ antialias: false, alpha: true, powerPreference: 'low-power' }}
        style={{ width: '100%', height: '100%' }}
        aria-hidden
      >
        <Suspense fallback={<CanvasLoader />}>
          <Stars color={color} />
          <Preload all />
        </Suspense>
      </Canvas>
    </div>
  )
}
