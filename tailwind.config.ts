import type { Config } from 'tailwindcss';

const config: Config = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './lib/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#070812',
        surface: {
          lowest: '#0C0E16',
          low: '#191B24',
          DEFAULT: '#1D1F28',
          high: '#282A32',
          highest: '#33343E',
          bright: '#373942',
        },
        primary: {
          DEFAULT: '#D0BCFF',
          container: '#A078FF',
          inverse: '#6D3BD7',
          onContainer: '#340080',
        },
        secondary: {
          DEFAULT: '#7BD0FF',
          container: '#00A6E0',
          fixed: '#C4E7FF',
          onContainer: '#00374D',
        },
        tertiary: {
          DEFAULT: '#FFB0CD',
          container: '#F751A1',
          onContainer: '#570032',
        },
        tv: {
          emerald: '#34D399',
          amber: '#F59E0B',
          ruby: '#EF4444',
          gold: '#F59E0B',
        },
        onSurface: {
          DEFAULT: '#E2E1EE',
          variant: '#CBC3D7',
        },
        outline: {
          DEFAULT: '#958EA0',
          variant: '#494454',
        },
      },
      fontFamily: {
        space: ['var(--font-space)', 'Space Grotesk', 'sans-serif'],
        outfit: ['var(--font-outfit)', 'Outfit', 'sans-serif'],
      },
      boxShadow: {
        'tv-focus': '0 0 35px 2px rgba(123, 208, 255, 0.45), 0 0 45px 4px rgba(160, 120, 255, 0.35)',
        'tv-card': '0 16px 40px -10px rgba(0, 0, 0, 0.7)',
        'tv-glow-purple': '0 0 40px rgba(160, 120, 255, 0.5)',
        'tv-glow-cyan': '0 0 40px rgba(123, 208, 255, 0.5)',
        'tv-glow-gold': '0 0 40px rgba(245, 158, 11, 0.5)',
      },
      animation: {
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'orb-glow': 'orbGlow 4s ease-in-out infinite alternate',
      },
      keyframes: {
        orbGlow: {
          '0%': { transform: 'scale(0.96)', opacity: '0.85', filter: 'drop-shadow(0 0 25px rgba(160, 120, 255, 0.6))' },
          '100%': { transform: 'scale(1.04)', opacity: '1.0', filter: 'drop-shadow(0 0 45px rgba(123, 208, 255, 0.8))' },
        },
      },
    },
  },
  plugins: [],
};

export default config;
