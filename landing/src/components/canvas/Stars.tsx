import { useRef, useMemo } from 'react'
import { useFrame } from '@react-three/fiber'
import { Points, PointMaterial } from '@react-three/drei'
import * as THREE from 'three'

type Props = {
  count?: number
  color?: string
}

function randomInSphere(count: number, radius: number) {
  const positions = new Float32Array(count * 3)
  for (let i = 0; i < count; i++) {
    const u = Math.random()
    const v = Math.random()
    const theta = 2 * Math.PI * u
    const phi = Math.acos(2 * v - 1)
    const r = radius * Math.cbrt(Math.random())
    positions[i * 3] = r * Math.sin(phi) * Math.cos(theta)
    positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta)
    positions[i * 3 + 2] = r * Math.cos(phi)
  }
  return positions
}

export default function Stars({ count = 3200, color = '#ffffff' }: Props) {
  const ref = useRef<THREE.Points>(null)
  const positions = useMemo(() => randomInSphere(count, 1.4), [count])

  useFrame((_, delta) => {
    if (!ref.current) return
    ref.current.rotation.x -= delta / 14
    ref.current.rotation.y -= delta / 20
  })

  return (
    <group rotation={[0, 0, Math.PI / 4]}>
      <Points ref={ref} positions={positions} stride={3} frustumCulled>
        <PointMaterial
          transparent
          color={color}
          size={0.0024}
          sizeAttenuation
          depthWrite={false}
        />
      </Points>
    </group>
  )
}
