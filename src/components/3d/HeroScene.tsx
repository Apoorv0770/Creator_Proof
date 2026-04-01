'use client';

import { useRef } from 'react';
import { Canvas, useFrame, useThree } from '@react-three/fiber';
import { OrbitControls, Torus } from '@react-three/drei';
import { Group } from 'three';

function LiquidElement() {
  const meshRef = useRef<Group>(null);
  const { mouse } = useThree();

  useFrame(() => {
    if (meshRef.current) {
      meshRef.current.rotation.x += 0.001;
      meshRef.current.rotation.y += 0.003;
      meshRef.current.rotation.z += 0.0005;

      // Magnetic effect to mouse movement
      const targetX = (mouse.y * Math.PI) / 6;
      const targetY = (mouse.x * Math.PI) / 6;

      meshRef.current.rotation.x += (targetX - meshRef.current.rotation.x) * 0.05;
      meshRef.current.rotation.y += (targetY - meshRef.current.rotation.y) * 0.05;
    }
  });

  return (
    <group ref={meshRef}>
      <Torus args={[3, 1, 16, 100]} position={[0, 0, 0]}>
        <meshStandardMaterial
          color="#a855f7"
          emissive="#8a2be2"
          emissiveIntensity={0.8}
          metalness={0.8}
          roughness={0.2}
        />
      </Torus>

      {/* Additional floating elements */}
      <mesh position={[5, 2, 0]}>
        <sphereGeometry args={[0.8, 32, 32]} />
        <meshStandardMaterial
          color="#c084fc"
          emissive="#a855f7"
          emissiveIntensity={0.6}
          metalness={0.7}
          roughness={0.3}
        />
      </mesh>

      <mesh position={[-4, -3, -2]}>
        <sphereGeometry args={[0.6, 32, 32]} />
        <meshStandardMaterial
          color="#7c3aed"
          emissive="#8a2be2"
          emissiveIntensity={0.7}
          metalness={0.8}
          roughness={0.2}
        />
      </mesh>
    </group>
  );
}

export function HeroScene() {
  return (
    <Canvas
      camera={{ position: [0, 0, 8], fov: 75 }}
      className="w-full h-full"
    >
      <ambientLight intensity={0.5} />
      <directionalLight position={[5, 5, 5]} intensity={1} />
      <pointLight position={[0, 10, 10]} intensity={0.8} color="#a855f7" />
      <pointLight position={[-10, -10, 5]} intensity={0.6} color="#8a2be2" />

      <LiquidElement />

      <OrbitControls
        enableZoom={false}
        enablePan={false}
        autoRotate
        autoRotateSpeed={2}
      />
    </Canvas>
  );
}
