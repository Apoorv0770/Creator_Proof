import { Variants } from 'framer-motion';

// Stagger container variants
export const containerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

// Item variants with fade-up animation
export const itemVariants: Variants = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: 0.5 },
  },
};

// Factory function for custom stagger timing
export const createContainerVariants = (
  staggerChildren = 0.1,
  delayChildren = 0
): Variants => ({
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren,
      delayChildren,
    },
  },
});

// Factory function for custom item animation
export const createItemVariants = (
  duration = 0.5,
  ease: string = 'easeOut'
): Variants => ({
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration, ease },
  },
});
