'use client';

// =============================================================================
// PlayTogether AI — Animated AI Network Particle Background
// Canvas-based 60fps golden/purple particle network matching Flutter visual system.
// =============================================================================

import React, { useEffect, useRef } from 'react';

interface AnimatedAINetworkProps {
  particleCount?: number;
  opacity?: number;
  animationSpeed?: number;
  glowIntensity?: number;
}

interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  radius: number;
  color: string;
}

export function AnimatedAINetworkBackground({
  particleCount = 40,
  opacity = 0.85,
  animationSpeed = 1.0,
  glowIntensity = 1.0,
}: AnimatedAINetworkProps) {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animId: number;
    let width = (canvas.width = window.innerWidth);
    let height = (canvas.height = window.innerHeight);

    const handleResize = () => {
      if (!canvas) return;
      width = canvas.width = window.innerWidth;
      height = canvas.height = window.innerHeight;
    };
    window.addEventListener('resize', handleResize);

    const colors = [
      'rgba(245, 158, 11, 0.8)', // Gold
      'rgba(160, 120, 255, 0.8)', // Purple
      'rgba(123, 208, 255, 0.8)', // Cyan
      'rgba(247, 81, 161, 0.7)',  // Pink
    ];

    const particles: Particle[] = Array.from({ length: particleCount }).map(() => ({
      x: Math.random() * width,
      y: Math.random() * height,
      vx: (Math.random() - 0.5) * 0.7 * animationSpeed,
      vy: (Math.random() - 0.5) * 0.7 * animationSpeed,
      radius: 2 + Math.random() * 2.5,
      color: colors[Math.floor(Math.random() * colors.length)],
    }));

    const render = () => {
      ctx.clearRect(0, 0, width, height);

      // Draw connecting lines between close particles
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const dx = particles[i].x - particles[j].x;
          const dy = particles[i].y - particles[j].y;
          const dist = Math.sqrt(dx * dx + dy * dy);

          if (dist < 160) {
            const alpha = (1 - dist / 160) * 0.35 * opacity * glowIntensity;
            ctx.beginPath();
            ctx.moveTo(particles[i].x, particles[i].y);
            ctx.lineTo(particles[j].x, particles[j].y);
            ctx.strokeStyle = `rgba(160, 120, 255, ${alpha})`;
            ctx.lineWidth = 1.0;
            ctx.stroke();
          }
        }
      }

      // Draw particle nodes
      for (const p of particles) {
        p.x += p.vx;
        p.y += p.vy;

        if (p.x < 0 || p.x > width) p.vx *= -1;
        if (p.y < 0 || p.y > height) p.vy *= -1;

        ctx.beginPath();
        ctx.arc(p.x, p.y, p.radius, 0, Math.PI * 2);
        ctx.fillStyle = p.color;
        ctx.shadowColor = p.color;
        ctx.shadowBlur = 12 * glowIntensity;
        ctx.fill();
        ctx.shadowBlur = 0;
      }

      animId = requestAnimationFrame(render);
    };

    render();

    return () => {
      cancelAnimationFrame(animId);
      window.removeEventListener('resize', handleResize);
    };
  }, [particleCount, opacity, animationSpeed, glowIntensity]);

  return (
    <div className="fixed inset-0 pointer-events-none z-0 overflow-hidden">
      <canvas ref={canvasRef} className="w-full h-full" style={{ opacity }} />
      {/* Volumetric ambient bloom gradients */}
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: 'radial-gradient(circle at 20% 20%, rgba(160, 120, 255, 0.14) 0%, transparent 60%)',
        }}
      />
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: 'radial-gradient(circle at 80% 70%, rgba(123, 208, 255, 0.12) 0%, transparent 65%)',
        }}
      />
    </div>
  );
}

export default AnimatedAINetworkBackground;
