import React, { useEffect, useRef } from 'react';

export default function WaveVisualizer({ isPlaying = false }) {
  const canvasRef = useRef(null);
  const animationRef = useRef(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    
    canvas.width = canvas.parentElement.clientWidth * 2;
    canvas.height = 160;
    canvas.style.width = '100%';
    canvas.style.height = '80px';

    let phase = 0;
    
    const draw = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      
      const width = canvas.width;
      const height = canvas.height;
      const centerY = height / 2;
      const maxAmplitude = isPlaying ? 50 : 2;
      
      phase += isPlaying ? 0.08 : 0.01;

      const waves = [
        { color: 'rgba(255, 153, 51, 0.45)', frequency: 0.008, amplitude: maxAmplitude * 0.9, speed: 1 },
        { color: 'rgba(22, 138, 168, 0.45)', frequency: 0.012, amplitude: maxAmplitude * 0.7, speed: -1.2 },
        { color: 'rgba(39, 155, 97, 0.35)', frequency: 0.005, amplitude: maxAmplitude * 1.2, speed: 0.7 }
      ];

      waves.forEach((wave) => {
        ctx.beginPath();
        ctx.strokeStyle = wave.color;
        ctx.lineWidth = 4;
        ctx.lineCap = 'round';
        
        for (let x = 0; x < width; x += 4) {
          const angle = x * wave.frequency + (phase * wave.speed);
          const edgeFade = Math.sin((x / width) * Math.PI);
          const y = centerY + Math.sin(angle) * wave.amplitude * edgeFade;
          
          if (x === 0) {
            ctx.moveTo(x, y);
          } else {
            ctx.lineTo(x, y);
          }
        }
        ctx.stroke();
      });

      animationRef.current = requestAnimationFrame(draw);
    };

    draw();

    const handleResize = () => {
      if (canvas && canvas.parentElement) {
        canvas.width = canvas.parentElement.clientWidth * 2;
      }
    };
    window.addEventListener('resize', handleResize);

    return () => {
      cancelAnimationFrame(animationRef.current);
      window.removeEventListener('resize', handleResize);
    };
  }, [isPlaying]);

  return (
    <div className="w-full flex items-center justify-center p-2 bg-gradient-to-r from-transparent via-teal-50/10 to-transparent overflow-hidden rounded-2xl">
      <canvas ref={canvasRef} className="block opacity-90" />
    </div>
  );
}
