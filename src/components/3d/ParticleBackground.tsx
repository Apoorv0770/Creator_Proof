'use client';

import { useRef, useMemo } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { Points, PointMaterial } from '@react-three/drei';

function ParticleField() {
  const points = useRef<any>(null);

  const particlesCount = 500;
  const particles = useMemo(() => {
    const positions = new Float32Array(particlesCount * 3);
    for (let i = 0; i < particlesCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 2000;
      positions[i + 1] = (Math.random() - 0.5) * 2000;
      positions[i + 2] = (Math.random() - 0.5) * 2000;
    }
    return positions;
  }, []);

  useFrame(() => {
    if (points.current) {
      points.current.rotation.x -= 0.0003;
      points.current.rotation.y -= 0.0005;
    }
  });

  return (
    <group ref={points}>
      <Points positions={particles} stride={3} frustumCulled={false}>
        <PointMaterial
          transparent
          color="#a855f7"
          size={2}
          sizeAttenuation
          opacity={0.4}
        />
      </Points>
    </group>
  );
}

export function ParticleBackground() {
  return (
    <Canvas
      camera={{ position: [0, 0, 300] }}
      className="fixed inset-0 -z-10"
    >
      <ParticleField />
    </Canvas>
  );
}
