'use client';

import { motion } from 'framer-motion';
import { useState } from 'react';
import { createContainerVariants, itemVariants } from '@/lib/animations';

interface PricingTier {
  name: string;
  monthlyPrice: number;
  yearlyPrice: number;
  description: string;
  features: string[];
  highlighted?: boolean;
}

const pricingTiers: PricingTier[] = [
  {
    name: 'Free',
    monthlyPrice: 0,
    yearlyPrice: 0,
    description: 'Perfect for getting started',
    features: [
      '5 designs per month',
      'Basic AI generation',
      'Community support',
      'Standard quality output',
    ],
  },
  {
    name: 'Pro',
    monthlyPrice: 29,
    yearlyPrice: 290,
    description: 'For serious creators',
    features: [
      'Unlimited designs',
      'Advanced AI generation',
      'Priority support',
      'Premium quality output',
      'Team collaboration',
      'Advanced analytics',
    ],
    highlighted: true,
  },
  {
    name: 'Enterprise',
    monthlyPrice: 99,
    yearlyPrice: 990,
    description: 'For large teams',
    features: [
      'Everything in Pro',
      'Custom AI models',
      'Dedicated support',
      'White-label options',
      'API access',
      'Advanced security',
      'Custom integrations',
    ],
  },
];

export function PricingSection() {
  const [isYearly, setIsYearly] = useState(false);
  const containerVariants = createContainerVariants(0.2);

  return (
    <section
      id="pricing"
      className="relative py-24 px-4 md:px-12 overflow-hidden"
    >
      {/* Decorative elements */}
      <div className="absolute top-1/2 right-0 w-96 h-96 bg-nf-purple/5 rounded-full blur-3xl -z-10" />
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-nf-glow/5 rounded-full blur-3xl -z-10" />

      <div className="max-w-7xl mx-auto">
        <motion.div
          className="text-center mb-12"
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true }}
        >
          <h2 className="text-4xl md:text-5xl font-bold mb-4">
            Simple,
            <br />
            <span className="bg-gradient-glow bg-clip-text text-transparent">
              Transparent Pricing
            </span>
          </h2>
          <p className="text-gray-400 text-lg max-w-2xl mx-auto mb-8">
            Choose the perfect plan for your creative needs.
          </p>

          {/* Toggle */}
          <div className="flex justify-center items-center space-x-4">
            <span
              className={`text-sm font-medium ${
                !isYearly ? 'text-white' : 'text-gray-400'
              }`}
            >
              Monthly
            </span>
            <motion.button
              className="relative w-16 h-8 bg-nf-purple/30 rounded-full p-1"
              onClick={() => setIsYearly(!isYearly)}
              whileTap={{ scale: 0.95 }}
            >
              <motion.div
                className="w-6 h-6 bg-gradient-glow rounded-full shadow-nf-glow"
                animate={{
                  x: isYearly ? 32 : 0,
                }}
                transition={{ type: 'spring', stiffness: 500, damping: 30 }}
              />
            </motion.button>
            <span
              className={`text-sm font-medium ${
                isYearly ? 'text-white' : 'text-gray-400'
              }`}
            >
              Yearly
              <span className="ml-2 text-nf-purple-light">Save 17%</span>
            </span>
          </div>
        </motion.div>

        <motion.div
          className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
        >
          {pricingTiers.map((tier, index) => (
            <motion.div
              key={index}
              variants={itemVariants}
              whileHover={tier.highlighted ? { scale: 1.05 } : undefined}
              className={`relative rounded-2xl p-8 transition-all duration-300 ${
                tier.highlighted
                  ? 'md:scale-105 z-10 ring-2 ring-nf-purple shadow-nf-glow-lg'
                  : 'glass'
              }`}
            >
              {tier.highlighted && (
                <motion.div
                  className="absolute -top-4 left-1/2 transform -translate-x-1/2 px-4 py-1 bg-gradient-glow text-white text-xs font-bold rounded-full"
                  animate={{ boxShadow: ['0 0 20px rgba(168, 85, 247, 0.5)', '0 0 30px rgba(168, 85, 247, 0.8)', '0 0 20px rgba(168, 85, 247, 0.5)'] }}
                  transition={{ duration: 2, repeat: Infinity }}
                >
                  Most Popular
                </motion.div>
              )}

              <h3 className="text-2xl font-bold text-white mb-2">{tier.name}</h3>
              <p className="text-gray-400 text-sm mb-6">{tier.description}</p>

              {/* Price */}
              <div className="mb-8">
                <span className="text-5xl font-black text-white">
                  ${isYearly ? tier.yearlyPrice : tier.monthlyPrice}
                </span>
                <span className="text-gray-400 ml-2">
                  /{isYearly ? 'year' : 'month'}
                </span>
              </div>

              {/* CTA Button */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                className={`w-full py-3 font-bold rounded-lg mb-8 transition-all duration-300 ${
                  tier.highlighted
                    ? 'bg-gradient-glow text-white shadow-nf-glow hover:shadow-nf-glow-lg'
                    : 'border-2 border-nf-purple/30 text-nf-purple-light hover:bg-nf-purple/10'
                }`}
              >
                Get Started
              </motion.button>

              {/* Features */}
              <ul className="space-y-4">
                {tier.features.map((feature, featureIndex) => (
                  <li
                    key={featureIndex}
                    className="flex items-center text-gray-300"
                  >
                    <span className="text-nf-purple-light mr-3">✓</span>
                    <span>{feature}</span>
                  </li>
                ))}
              </ul>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
