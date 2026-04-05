export const APP_NAME = 'NeuroForge';

export const COLORS = {
  primary: '#8A2BE2',
  primaryLight: '#A855F7',
  primaryLighter: '#C084FC',
  dark: '#0B0F1A',
  darker: '#121826',
  card: '#1A1F2E',
  glow: '#7C3AED',
};

export const DESIGN_CATEGORIES = [
  { id: 'web', label: 'Web Design', icon: '🌐' },
  { id: 'poster', label: 'Poster', icon: '📄' },
  { id: 'ui', label: 'UI/UX', icon: '🎨' },
  { id: 'branding', label: 'Branding', icon: '🏷️' },
];

export const PRICING_TIERS = [
  {
    id: 'free',
    name: 'Free',
    monthlyPrice: 0,
    yearlyPrice: 0,
    features: [
      '5 designs per month',
      'Basic AI generation',
      'Community support',
      'Standard quality output',
    ],
  },
  {
    id: 'pro',
    name: 'Pro',
    monthlyPrice: 29,
    yearlyPrice: 290,
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
    id: 'enterprise',
    name: 'Enterprise',
    monthlyPrice: 99,
    yearlyPrice: 990,
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

export const ANIMATION_DURATION = {
  fast: 0.3,
  normal: 0.5,
  slow: 1,
};

export const SOCIALS = [
  { name: 'Twitter', url: 'https://twitter.com', icon: '𝕏' },
  { name: 'LinkedIn', url: 'https://linkedin.com', icon: 'in' },
  { name: 'Discord', url: 'https://discord.com', icon: '💬' },
];
