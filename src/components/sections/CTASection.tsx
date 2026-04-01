'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';

export function CTASection() {
  return (
    <section className="relative py-32 px-4 md:px-12 overflow-hidden">
      {/* Animated background gradients */}
      <motion.div
        className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-r from-nf-purple/30 to-transparent rounded-full blur-3xl"
        animate={{
          y: [0, -30, 0],
          x: [0, 20, 0],
        }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
      />

      <motion.div
        className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-to-l from-nf-glow/30 to-transparent rounded-full blur-3xl"
        animate={{
          y: [0, 30, 0],
          x: [0, -20, 0],
        }}
        transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut' }}
      />

      {/* Wave effect */}
      <svg
        className="absolute inset-0 w-full h-full opacity-20"
        viewBox="0 0 1200 120"
        preserveAspectRatio="none"
      >
        <motion.path
          d="M0,50 Q300,0 600,50 T1200,50 L1200,120 L0,120 Z"
          stroke="url(#waveGradient)"
          strokeWidth="2"
          fill="none"
          animate={{
            d: [
              'M0,50 Q300,0 600,50 T1200,50 L1200,120 L0,120 Z',
              'M0,60 Q300,10 600,60 T1200,60 L1200,120 L0,120 Z',
              'M0,50 Q300,0 600,50 T1200,50 L1200,120 L0,120 Z',
            ],
          }}
          transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
        />
        <defs>
          <linearGradient id="waveGradient" x1="0%" y1="0%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#8a2be2" />
            <stop offset="50%" stopColor="#a855f7" />
            <stop offset="100%" stopColor="#c084fc" />
          </linearGradient>
        </defs>
      </svg>

      <div className="relative z-10 max-w-4xl mx-auto text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          viewport={{ once: true }}
        >
          <h2 className="text-4xl md:text-6xl font-black mb-6 bg-gradient-glow bg-clip-text text-transparent leading-tight">
            Start Your Creative Evolution Today
          </h2>

          <p className="text-lg md:text-xl text-gray-300 mb-12 max-w-2xl mx-auto leading-relaxed">
            Join thousands of creators who are already using NeuroForge to
            revolutionize their creative process. Your next masterpiece awaits.
          </p>

          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center items-center"
            initial={{ opacity: 0, scale: 0.9 }}
            whileInView={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            viewport={{ once: true }}
          >
            <Link href="/auth?signup=true">
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className="group relative px-10 py-5 bg-gradient-glow text-white font-bold text-lg rounded-xl shadow-nf-glow hover:shadow-nf-glow-lg transition-all duration-300 overflow-hidden"
              >
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-transparent via-white to-transparent opacity-0 group-hover:opacity-20"
                  animate={{
                    x: ['100%', '-100%'],
                  }}
                  transition={{ duration: 0.5, repeat: Infinity }}
                />
                <span className="relative">
                  Get Started Free
                  <span className="ml-2">→</span>
                </span>
              </motion.button>
            </Link>

            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="px-10 py-5 border-2 border-nf-purple/50 text-nf-purple-light font-bold text-lg rounded-xl hover:bg-nf-purple/10 transition-all duration-300"
            >
              Schedule Demo
            </motion.button>
          </motion.div>

          {/* Trust badges */}
          <motion.div
            className="mt-16 flex flex-col md:flex-row justify-center items-center gap-8 text-sm text-gray-400"
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            transition={{ duration: 0.5, delay: 0.4 }}
            viewport={{ once: true }}
          >
            <div className="flex items-center gap-2">
              <span className="text-nf-purple-light">✓</span>
              <span>No credit card required</span>
            </div>
            <div className="hidden md:block w-px h-6 bg-nf-purple/30" />
            <div className="flex items-center gap-2">
              <span className="text-nf-purple-light">✓</span>
              <span>14-day free trial</span>
            </div>
            <div className="hidden md:block w-px h-6 bg-nf-purple/30" />
            <div className="flex items-center gap-2">
              <span className="text-nf-purple-light">✓</span>
              <span>Cancel anytime</span>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
