import { Html, useProgress } from '@react-three/drei'

export default function CanvasLoader() {
  const { progress } = useProgress()

  return (
    <Html center>
      <div className="canvas-loader" role="status" aria-live="polite">
        <div className="canvas-loader__ring" />
        <p className="canvas-loader__text">{progress.toFixed(0)}%</p>
      </div>
    </Html>
  )
}
