'use client';

import { motion } from 'framer-motion';
import { containerVariants, itemVariants } from '@/lib/animations';

const features = [
  {
    icon: '🎨',
    title: 'AI Design Generation',
    description: 'Generate stunning designs in seconds using cutting-edge AI algorithms.',
  },
  {
    icon: '⚡',
    title: 'Lightning Fast Processing',
    description: 'Experience instant results with our optimized AI infrastructure.',
  },
  {
    icon: '🔄',
    title: 'Unlimited Iterations',
    description: 'Refine and regenerate designs endlessly until perfection is reached.',
  },
  {
    icon: '📊',
    title: 'Advanced Analytics',
    description: 'Track your creative journey with detailed usage statistics.',
  },
  {
    icon: '🤝',
    title: 'Team Collaboration',
    description: 'Share projects and collaborate with your team in real-time.',
  },
  {
    icon: '☁️',
    title: 'Cloud Storage',
    description: 'Access your designs from anywhere with secure cloud storage.',
  },
];

export function FeaturesSection() {
  return (
    <section
      id="features"
      className="relative py-24 px-4 md:px-12 overflow-hidden"
    >
      {/* Decorative elements */}
      <div className="absolute top-0 right-0 w-96 h-96 bg-nf-purple/5 rounded-full blur-3xl -z-10" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-nf-glow/5 rounded-full blur-3xl -z-10" />

      <div className="max-w-7xl mx-auto">
        <motion.div
          className="text-center mb-16"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true }}
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            Powerful Features for
            <br />
            <span className="bg-gradient-glow bg-clip-text text-transparent">
              Creative Professionals
            </span>
          </h2>
          <p className="text-gray-400 text-lg max-w-2xl mx-auto">
            Everything you need to create, refine, and deploy stunning designs with
            AI-powered intelligence.
          </p>
        </motion.div>

        <motion.div
          className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={{ y: -10 }}
              className="group glass rounded-2xl p-8 hover:bg-nf-purple/10 transition-all duration-300"
            >
              <div className="text-4xl mb-4 group-hover:scale-110 transition-transform duration-300">
                {feature.icon}
              </div>
              <h3 className="text-xl font-bold text-white mb-3">
                {feature.title}
              </h3>
              <p className="text-gray-400 group-hover:text-gray-300 transition-colors">
                {feature.description}
              </p>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
