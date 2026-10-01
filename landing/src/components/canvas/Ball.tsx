import { Suspense, useMemo, useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { Float, OrbitControls } from '@react-three/drei'
import * as THREE from 'three'
import CanvasLoader from './Loader'

type BallProps = {
  native: string
  script: string
  color: string
  accent: string
}

function LanguageBall({ native, script, color, accent }: BallProps) {
  const mesh = useRef<THREE.Mesh>(null)

  const texture = useMemo(() => {
    const size = 256
    const canvas = document.createElement('canvas')
    canvas.width = size
    canvas.height = size
    const ctx = canvas.getContext('2d')!
    const g = ctx.createRadialGradient(size / 2, size / 2, 8, size / 2, size / 2, size / 2)
    g.addColorStop(0, accent)
    g.addColorStop(1, color)
    ctx.fillStyle = g
    ctx.fillRect(0, 0, size, size)
    ctx.fillStyle = '#ffffff'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.font = `bold ${Math.floor(size * 0.42)}px system-ui, sans-serif`
    ctx.fillText(script, size / 2, size / 2 - 12)
    ctx.font = `600 ${Math.floor(size * 0.11)}px system-ui, sans-serif`
    ctx.fillText(native, size / 2, size / 2 + 58)
    const tex = new THREE.CanvasTexture(canvas)
    tex.colorSpace = THREE.SRGBColorSpace
    tex.needsUpdate = true
    return tex
  }, [accent, color, native, script])

  useFrame((_, delta) => {
    if (!mesh.current) return
    mesh.current.rotation.y += delta * 0.35
  })

  return (
    <Float speed={1.4} rotationIntensity={0.6} floatIntensity={1.2}>
      <mesh ref={mesh} castShadow>
        <icosahedronGeometry args={[1, 1]} />
        <meshStandardMaterial
          color="#ffffff"
          map={texture}
          flatShading
          roughness={0.35}
          metalness={0.15}
        />
      </mesh>
    </Float>
  )
}

type BallCanvasProps = {
  native: string
  script: string
  color?: string
  accent?: string
}

export default function BallCanvas({
  native,
  script,
  color = '#00695C',
  accent = '#E65100',
}: BallCanvasProps) {
  return (
    <Canvas
      dpr={[1, 1.5]}
      gl={{ antialias: true, alpha: true, powerPreference: 'high-performance' }}
      camera={{ position: [0, 0, 3.2], fov: 42 }}
      style={{ width: '100%', height: '100%' }}
      aria-hidden
    >
      <Suspense fallback={<CanvasLoader />}>
        <ambientLight intensity={0.55} />
        <directionalLight position={[4, 4, 2]} intensity={1.1} />
        <LanguageBall native={native} script={script} color={color} accent={accent} />
        <OrbitControls enableZoom={false} enablePan={false} autoRotate autoRotateSpeed={0.6} />
      </Suspense>
    </Canvas>
  )
}
