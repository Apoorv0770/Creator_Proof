import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './src/pages/**/*.{js,ts,jsx,tsx,mdx}',
    './src/components/**/*.{js,ts,jsx,tsx,mdx}',
    './src/app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        'nf-dark': '#0B0F1A',
        'nf-darker': '#121826',
        'nf-card': '#1A1F2E',
        'nf-purple': '#8A2BE2',
        'nf-purple-light': '#A855F7',
        'nf-purple-lighter': '#C084FC',
        'nf-glow': '#7C3AED',
      },
      backgroundImage: {
        'gradient-nf': 'linear-gradient(135deg, #0B0F1A 0%, #121826 100%)',
        'gradient-glow': 'linear-gradient(135deg, #8A2BE2 0%, #C084FC 100%)',
      },
      boxShadow: {
        'nf-glow': '0 0 30px rgba(138, 43, 226, 0.5)',
        'nf-glow-lg': '0 0 60px rgba(168, 85, 247, 0.4)',
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'glow': 'glow 2s ease-in-out infinite',
        'pulse-glow': 'pulse-glow 3s ease-in-out infinite',
        'shimmer': 'shimmer 2s ease-in-out infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-20px)' },
        },
        glow: {
          '0%, 100%': { textShadow: '0 0 10px rgba(168, 85, 247, 0.5)' },
          '50%': { textShadow: '0 0 20px rgba(168, 85, 247, 1)' },
        },
        'pulse-glow': {
          '0%': { boxShadow: '0 0 0 0 rgba(168, 85, 247, 0.7)' },
          '70%': { boxShadow: '0 0 0 20px rgba(168, 85, 247, 0)' },
          '100%': { boxShadow: '0 0 0 0 rgba(168, 85, 247, 0)' },
        },
        shimmer: {
          '0%': { backgroundPosition: '-1000px 0' },
          '100%': { backgroundPosition: '1000px 0' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
