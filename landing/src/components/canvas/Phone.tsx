import { Suspense, useEffect, useMemo, useRef, useState, type MutableRefObject } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Float, RoundedBox, useTexture } from '@react-three/drei'
import * as THREE from 'three'
import CanvasLoader from './Loader'

type PhoneMeshProps = {
  textureUrl: string
  mouse: MutableRefObject<{ x: number; y: number }>
  scrollRotate?: number
  autoRotate?: boolean
}

function PhoneMesh({
  textureUrl,
  mouse,
  scrollRotate = 0,
  autoRotate = true,
}: PhoneMeshProps) {
  const group = useRef<THREE.Group>(null)
  const texture = useTexture(textureUrl)
  texture.colorSpace = THREE.SRGBColorSpace
  texture.anisotropy = 8

  useFrame((_, delta) => {
    if (!group.current) return
    const targetX = mouse.current.y * 0.25 + scrollRotate * 0.35
    const targetY = mouse.current.x * 0.35
    group.current.rotation.x = THREE.MathUtils.damp(
      group.current.rotation.x,
      targetX,
      4,
      delta,
    )
    group.current.rotation.y = THREE.MathUtils.damp(
      group.current.rotation.y,
      targetY + (autoRotate ? Math.sin(performance.now() * 0.00035) * 0.35 : 0),
      4,
      delta,
    )
  })

  return (
    <Float speed={1.1} rotationIntensity={0.15} floatIntensity={0.45}>
      <group ref={group} scale={1.15}>
        <RoundedBox args={[1.35, 2.75, 0.14]} radius={0.12} smoothness={6}>
          <meshStandardMaterial color="#111418" metalness={0.55} roughness={0.35} />
        </RoundedBox>
        <RoundedBox
          args={[1.28, 2.68, 0.02]}
          radius={0.1}
          smoothness={6}
          position={[0, 0, 0.075]}
        >
          <meshStandardMaterial color="#1c2228" metalness={0.4} roughness={0.45} />
        </RoundedBox>
        <mesh position={[0, 0, 0.095]}>
          <planeGeometry args={[1.12, 2.42]} />
          <meshBasicMaterial map={texture} toneMapped={false} />
        </mesh>
        <mesh position={[0, 1.12, 0.1]}>
          <boxGeometry args={[0.38, 0.06, 0.02]} />
          <meshStandardMaterial color="#0a0c0e" />
        </mesh>
      </group>
    </Float>
  )
}

type PhoneCanvasProps = {
  textureUrl: string
  className?: string
  scrollRotate?: number
  autoRotate?: boolean
  parallax?: boolean
}

export default function PhoneCanvas({
  textureUrl,
  className,
  scrollRotate = 0,
  autoRotate = true,
  parallax = true,
}: PhoneCanvasProps) {
  const mouse = useRef({ x: 0, y: 0 })
  const [ready, setReady] = useState(false)

  useEffect(() => {
    if (!parallax) return
    const onMove = (e: MouseEvent) => {
      mouse.current.x = (e.clientX / window.innerWidth) * 2 - 1
      mouse.current.y = -(e.clientY / window.innerHeight) * 2 + 1
    }
    window.addEventListener('mousemove', onMove, { passive: true })
    return () => window.removeEventListener('mousemove', onMove)
  }, [parallax])

  const key = useMemo(() => textureUrl, [textureUrl])

  return (
    <div className={className ?? 'h-full w-full min-h-[420px]'}>
      <Canvas
        dpr={[1, 1.75]}
        gl={{ antialias: true, alpha: true, powerPreference: 'high-performance' }}
        camera={{ position: [0, 0, 4.6], fov: 38 }}
        onCreated={() => setReady(true)}
        aria-hidden
      >
        <Suspense fallback={<CanvasLoader />}>
          <ambientLight intensity={0.65} />
          <directionalLight position={[3, 4, 5]} intensity={1.25} />
          <directionalLight position={[-3, -2, 2]} intensity={0.35} color="#2dd4bf" />
          <PhoneMesh
            key={key}
            textureUrl={textureUrl}
            mouse={mouse}
            scrollRotate={scrollRotate}
            autoRotate={autoRotate}
          />
        </Suspense>
      </Canvas>
      {!ready && <span className="sr-only">Loading 3D phone</span>}
    </div>
  )
}
