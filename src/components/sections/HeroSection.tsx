'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';
import { useEffect, useState } from 'react';
import { createContainerVariants, createItemVariants } from '@/lib/animations';

export function HeroSection() {
  const [typedText, setTypedText] = useState('');
  const fullText = 'Your AI-Powered Creative Universe';

  useEffect(() => {
    let index = 0;
    const interval = setInterval(() => {
      if (index <= fullText.length) {
        setTypedText(fullText.slice(0, index));
        index++;
      } else {
        clearInterval(interval);
      }
    }, 50);

    return () => clearInterval(interval);
  }, []);

  const containerVariants = createContainerVariants(0.2, 0.3);
  const itemVariants = createItemVariants(0.8, 'easeOut');

  return (
    <section className="relative min-h-screen flex items-center justify-center pt-20 overflow-hidden">
      {/* Gradient overlay */}
      <div className="absolute inset-0 bg-gradient-radial from-nf-purple/20 via-transparent to-transparent opacity-40" />

      {/* Animated background elements */}
      <motion.div
        className="absolute top-20 right-10 w-64 h-64 bg-nf-purple/10 rounded-full blur-3xl"
        animate={{
          x: [0, 30, 0],
          y: [0, -30, 0],
        }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
      />

      <motion.div
        className="absolute bottom-20 left-10 w-96 h-96 bg-nf-glow/10 rounded-full blur-3xl"
        animate={{
          x: [0, -40, 0],
          y: [0, 40, 0],
        }}
        transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut' }}
      />

      <motion.div
        className="relative z-10 text-center px-4 max-w-5xl mx-auto"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* Badge */}
        <motion.div variants={itemVariants} className="mb-8">
          <span className="inline-block px-4 py-2 rounded-full bg-nf-purple/20 border border-nf-purple/40 text-nf-purple-light text-sm font-medium">
            ✨ Alpha Release - Early Access Available
          </span>
        </motion.div>

        {/* Main Headline */}
        <motion.h1
          variants={itemVariants}
          className="text-4xl md:text-6xl lg:text-7xl font-black mb-6 bg-gradient-glow bg-clip-text text-transparent leading-tight min-h-[1.2em]"
        >
          {typedText}
          <span className="animate-pulse">|</span>
        </motion.h1>

        {/* Subheadline */}
        <motion.p
          variants={itemVariants}
          className="text-lg md:text-xl text-gray-300 mb-8 max-w-2xl mx-auto leading-relaxed"
        >
          Upload. Generate. Refine. Deploy.
          <br />
          <span className="text-nf-purple-light font-medium">
            Unleash your creativity with AI-powered design generation at your fingertips.
          </span>
        </motion.p>

        {/* CTA Buttons */}
        <motion.div
          variants={itemVariants}
          className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-16"
        >
          <Link href="/dashboard">
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-8 py-4 bg-gradient-glow text-white font-bold rounded-xl shadow-nf-glow hover:shadow-nf-glow-lg transition-all duration-300"
            >
              Start Creating
              <span className="ml-2">→</span>
            </motion.button>
          </Link>

          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className="px-8 py-4 border-2 border-nf-purple/50 text-nf-purple-light font-bold rounded-xl hover:bg-nf-purple/10 transition-all duration-300"
          >
            Explore Demo
          </motion.button>
        </motion.div>

        {/* Feature hints */}
        <motion.div
          variants={itemVariants}
          className="grid grid-cols-3 gap-4 max-w-md mx-auto text-sm text-gray-400"
        >
          <div className="text-center">
            <div className="text-2xl mb-2">✨</div>
            <span>AI-Powered</span>
          </div>
          <div className="text-center">
            <div className="text-2xl mb-2">⚡</div>
            <span>Lightning Fast</span>
          </div>
          <div className="text-center">
            <div className="text-2xl mb-2">🎨</div>
            <span>Unlimited Styles</span>
          </div>
        </motion.div>
      </motion.div>

      {/* Scroll indicator */}
      <motion.div
        className="absolute bottom-10 left-1/2 transform -translate-x-1/2"
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
      >
        <div className="text-gray-400 text-center">
          <div className="text-xs mb-2">Scroll to explore</div>
          <svg
            className="w-5 h-5 mx-auto"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M19 14l-7 7m0 0l-7-7m7 7V3"
            />
          </svg>
        </div>
      </motion.div>
    </section>
  );
}
