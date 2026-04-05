'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { motion } from 'framer-motion';
import { signOut, onAuthStateChanged, User } from 'firebase/auth';
import { auth } from '@/lib/firebase';
import { containerVariants, itemVariants } from '@/lib/animations';
import { useTheme } from 'next-themes';

export default function DashboardPage() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const router = useRouter();
  const { theme, setTheme } = useTheme();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        setLoading(false);
      } else {
        router.push('/auth');
      }
    });

    return () => unsubscribe();
  }, [router]);

  const handleSignOut = async () => {
    await signOut(auth);
    router.push('/');
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-nf flex items-center justify-center">
        <div className="text-center">
          <motion.div
            animate={{ rotate: 360 }}
            transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
            className="w-12 h-12 border-4 border-nf-purple border-t-transparent rounded-full mx-auto mb-4"
          />
          <p className="text-gray-400">Loading...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-nf">
      {/* Header */}
      <header className="border-b border-nf-purple/20 bg-nf-darker/50 backdrop-blur-md sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 md:px-12 py-4 flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2 group">
            <div className="w-8 h-8 bg-gradient-glow rounded-lg flex items-center justify-center shadow-nf-glow">
              <svg
                className="w-5 h-5 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 10V3L4 14h7v7l9-11h-7z"
                />
              </svg>
            </div>
            <span className="text-lg font-bold bg-gradient-glow bg-clip-text text-transparent">
              NeuroForge
            </span>
          </Link>

          <div className="flex items-center space-x-4">
            {/* Theme Toggle */}
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="p-2 rounded-lg border border-nf-purple/20 hover:bg-nf-purple/10 transition-all"
            >
              {theme === 'dark' ? '🌙' : '☀️'}
            </motion.button>

            {/* User Menu */}
            <div className="flex items-center space-x-4 md:ml-4 md:pl-4 md:border-l md:border-nf-purple/20">
              <div className="hidden md:flex flex-col items-end">
                <p className="text-sm font-medium text-white">{user?.email}</p>
                <p className="text-xs text-gray-400">Pro Member</p>
              </div>

              <div className="w-10 h-10 rounded-full bg-gradient-glow flex items-center justify-center shadow-nf-glow">
                <span className="text-white font-bold">
                  {user?.email?.[0].toUpperCase()}
                </span>
              </div>

              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={handleSignOut}
                className="px-4 py-2 bg-nf-purple/20 hover:bg-nf-purple/30 border border-nf-purple/30 rounded-lg text-sm font-medium text-nf-purple-light transition-all"
              >
                Sign Out
              </motion.button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 md:px-12 py-12">
        <motion.div
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          {/* Welcome Section */}
          <motion.div variants={itemVariants} className="mb-12">
            <h1 className="text-4xl font-bold text-white mb-2">
              Welcome back, {user?.email?.split('@')[0]}!
            </h1>
            <p className="text-gray-400">
              Ready to create something amazing today?
            </p>
          </motion.div>

          {/* Quick Stats */}
          <motion.div
            variants={itemVariants}
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12"
          >
            {[
              { label: 'Designs Created', value: '12', icon: '🎨' },
              { label: 'API Calls This Month', value: '342', icon: '⚡' },
              { label: 'Account Status', value: 'Pro', icon: '👑' },
            ].map((stat, index) => (
              <motion.div
                key={index}
                whileHover={{ scale: 1.05 }}
                className="glass rounded-2xl p-6 hover:bg-nf-purple/10 transition-all"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm text-gray-400 mb-2">{stat.label}</p>
                    <p className="text-3xl font-bold text-white">{stat.value}</p>
                  </div>
                  <div className="text-4xl">{stat.icon}</div>
                </div>
              </motion.div>
            ))}
          </motion.div>

          {/* Main Action Card */}
          <motion.div
            variants={itemVariants}
            className="mb-12"
          >
            <Link href="/generate">
              <motion.div
                whileHover={{ scale: 1.02 }}
                className="glass rounded-2xl p-12 bg-gradient-to-r from-nf-purple/20 to-nf-glow/20 border border-nf-purple/40 cursor-pointer hover:border-nf-purple/60 transition-all"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <h2 className="text-2xl font-bold text-white mb-2">
                      Create New Design
                    </h2>
                    <p className="text-gray-300">
                      Upload a brief, watch AI generate stunning designs in seconds
                    </p>
                  </div>
                  <div className="text-6xl">✨</div>
                </div>
              </motion.div>
            </Link>
          </motion.div>

          {/* Recent Projects */}
          <motion.div variants={itemVariants}>
            <h2 className="text-2xl font-bold text-white mb-6">Recent Projects</h2>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3].map((project) => (
                <motion.div
                  key={project}
                  whileHover={{ y: -10 }}
                  className="glass rounded-2xl overflow-hidden hover:bg-nf-purple/10 transition-all cursor-pointer"
                >
                  <div className="h-32 bg-gradient-to-br from-nf-purple/30 to-nf-glow/30 flex items-center justify-center">
                    <div className="text-5xl">🎨</div>
                  </div>
                  <div className="p-4">
                    <h3 className="font-bold text-white mb-1">
                      Project {project}
                    </h3>
                    <p className="text-sm text-gray-400 mb-4">
                      Created 2 days ago
                    </p>
                    <motion.button
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      className="w-full py-2 bg-nf-purple/20 hover:bg-nf-purple/30 text-nf-purple-light rounded-lg text-sm font-medium transition-all"
                    >
                      View Details
                    </motion.button>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </motion.div>
      </main>
    </div>
  );
}
