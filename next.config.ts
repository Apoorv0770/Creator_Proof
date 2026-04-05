/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  images: {
    domains: ['images.unsplash.com', 'images.pexels.com'],
  },
  experimental: {
    optimizePackageImports: ['framer-motion', 'three'],
  },
};

export default nextConfig;
