'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { onAuthStateChanged, User } from 'firebase/auth';
import { auth } from '@/lib/firebase';

type GenerationStep = 'upload' | 'generate' | 'results';

interface GeneratedDesign {
  id: number;
  title: string;
  category: string;
  image: string;
}

export default function GeneratePage() {
  const [, setUser] = useState<User | null>(null);
  const [currentStep, setCurrentStep] = useState<GenerationStep>('upload');
  const [loading, setLoading] = useState(true);
  const [, setIsGenerating] = useState(false);
  const [generatedDesigns, setGeneratedDesigns] = useState<GeneratedDesign[]>([]);

  // Form state
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('web');
  const [uploadedFile, setUploadedFile] = useState<File | null>(null);

  const router = useRouter();

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

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setUploadedFile(file);
    }
  };

  const handleGenerateDesigns = async () => {
    if (!description.trim()) {
      alert('Please enter a design description');
      return;
    }

    setIsGenerating(true);
    setCurrentStep('generate');

    // Simulate AI generation process
    await new Promise((resolve) => setTimeout(resolve, 2000));

    // Mock generated designs
    const mockDesigns: GeneratedDesign[] = [
      {
        id: 1,
        title: 'Modern Minimalist',
        category: category,
        image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500&h=400',
      },
      {
        id: 2,
        title: 'Bold & Vibrant',
        category: category,
        image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&h=400',
      },
      {
        id: 3,
        title: 'Elegant Classic',
        category: category,
        image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500&h=400',
      },
    ];

    setGeneratedDesigns(mockDesigns);
    setIsGenerating(false);
    setCurrentStep('results');
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
          <Link href="/dashboard" className="flex items-center space-x-2 group">
            <svg
              className="w-5 h-5 text-nf-purple-light"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M15 19l-7-7 7-7"
              />
            </svg>
            <span className="text-gray-300 hover:text-white">Back to Dashboard</span>
          </Link>

          <h1 className="text-2xl font-bold bg-gradient-glow bg-clip-text text-transparent">
            AI Design Generator
          </h1>

          <div className="w-8" />
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 md:px-12 py-12">
        {/* Step Indicator */}
        <div className="flex items-center justify-between mb-12">
          {(['upload', 'generate', 'results'] as const).map(
            (step, index) => (
              <div key={step} className="flex items-center">
                <motion.div
                  className={`w-10 h-10 rounded-full flex items-center justify-center font-bold transition-all ${
                    currentStep === step || index < ['upload', 'generate', 'results'].indexOf(currentStep)
                      ? 'bg-gradient-glow text-white shadow-nf-glow'
                      : 'bg-nf-card/50 text-gray-400 border border-nf-purple/20'
                  }`}
                >
                  {index + 1}
                </motion.div>

                {index < 2 && (
                  <div
                    className={`h-1 w-16 md:w-24 transition-all ${
                      index < ['upload', 'generate', 'results'].indexOf(currentStep)
                        ? 'bg-gradient-glow'
                        : 'bg-nf-purple/20'
                    }`}
                  />
                )}
              </div>
            )
          )}
        </div>

        {/* Step Content */}
        <AnimatePresence mode="wait">
          {currentStep === 'upload' && (
            <motion.div
              key="upload"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="glass rounded-2xl p-8 md:p-12"
            >
              <h2 className="text-3xl font-bold text-white mb-2">
                Step 1: Upload Your Brief
              </h2>
              <p className="text-gray-400 mb-8">
                Describe your design vision or moodboard. The more detailed, the better
                the results.
              </p>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                {/* Description */}
                <div>
                  <label className="block text-sm font-medium text-gray-300 mb-4">
                    Design Description
                  </label>
                  <motion.textarea
                    whileFocus={{ scale: 1.02 }}
                    value={description}
                    onChange={(e) => setDescription(e.target.value)}
                    placeholder="Describe your design idea... e.g., 'Modern tech startup landing page with purple and blue gradients, minimalist design'"
                    rows={6}
                    className="w-full px-4 py-3 bg-nf-card/50 border border-nf-purple/20 rounded-lg text-white placeholder-gray-500 focus:outline-none focus:border-nf-purple focus:ring-1 focus:ring-nf-purple transition-all resize-none"
                  />
                </div>

                {/* Sidebar */}
                <div className="space-y-6">
                  {/* Category */}
                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-3">
                      Design Category
                    </label>
                    <div className="space-y-2">
                      {['web', 'poster', 'ui', 'branding'].map((cat) => (
                        <motion.label
                          key={cat}
                          className="flex items-center space-x-3 cursor-pointer"
                        >
                          <input
                            type="radio"
                            name="category"
                            value={cat}
                            checked={category === cat}
                            onChange={(e) => setCategory(e.target.value)}
                            className="w-4 h-4 accent-nf-purple"
                          />
                          <span className="text-gray-300 capitalize">{cat}</span>
                        </motion.label>
                      ))}
                    </div>
                  </div>

                  {/* File Upload */}
                  <div>
                    <label className="block text-sm font-medium text-gray-300 mb-3">
                      Upload Moodboard (Optional)
                    </label>
                    <motion.label
                      whileHover={{ scale: 1.02 }}
                      className="block border-2 border-dashed border-nf-purple/30 rounded-lg p-6 text-center cursor-pointer hover:border-nf-purple transition-all"
                    >
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleFileUpload}
                        className="hidden"
                      />
                      <div className="text-4xl mb-2">📁</div>
                      <p className="text-sm text-gray-400">
                        {uploadedFile
                          ? uploadedFile.name
                          : 'Click to upload or drag and drop'}
                      </p>
                    </motion.label>
                  </div>
                </div>
              </div>

              {/* Button */}
              <motion.button
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={handleGenerateDesigns}
                className="mt-8 px-8 py-4 bg-gradient-glow text-white font-bold rounded-lg shadow-nf-glow hover:shadow-nf-glow-lg transition-all"
              >
                Generate Designs
                <span className="ml-2">→</span>
              </motion.button>
            </motion.div>
          )}

          {currentStep === 'generate' && (
            <motion.div
              key="generate"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="glass rounded-2xl p-12 text-center"
            >
              <motion.div
                animate={{ rotate: 360 }}
                transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                className="w-16 h-16 border-4 border-nf-purple border-t-transparent rounded-full mx-auto mb-6"
              />

              <h2 className="text-3xl font-bold text-white mb-4">
                Generating Your Designs
              </h2>
              <p className="text-gray-400 mb-4">
                Our AI is working its magic...
              </p>

              {/* Progress Bar */}
              <motion.div
                className="max-w-md mx-auto"
                initial={{ opacity: 0, scaleX: 0 }}
                animate={{ opacity: 1, scaleX: 1 }}
              >
                <div className="h-2 bg-nf-card/50 rounded-full overflow-hidden">
                  <motion.div
                    className="h-full bg-gradient-glow"
                    animate={{ width: '100%' }}
                    transition={{ duration: 3, ease: 'easeInOut' }}
                  />
                </div>
              </motion.div>

              {/* Animated tips */}
              <motion.div
                className="mt-8 text-sm text-gray-400"
                animate={{ opacity: [0.5, 1, 0.5] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                <p>✨ Tip: Great designs start with clear descriptions!</p>
              </motion.div>
            </motion.div>
          )}

          {currentStep === 'results' && (
            <motion.div
              key="results"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
            >
              <h2 className="text-3xl font-bold text-white mb-2">
                Step 3: Your Generated Designs
              </h2>
              <p className="text-gray-400 mb-8">
                Select a design to refine or download
              </p>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
                {generatedDesigns.map((design, index) => (
                  <motion.div
                    key={design.id}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: index * 0.1 }}
                    whileHover={{ y: -10 }}
                    className="glass rounded-2xl overflow-hidden hover:bg-nf-purple/10 transition-all cursor-pointer group"
                  >
                    <div className="relative h-64 overflow-hidden">
                      <motion.img
                        src={design.image}
                        alt={design.title}
                        className="w-full h-full object-cover"
                        whileHover={{ scale: 1.1 }}
                        transition={{ duration: 0.3 }}
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-nf-dark/80 to-transparent" />
                      <motion.div
                        className="absolute top-4 right-4 px-3 py-1 bg-nf-purple/80 text-white text-xs font-bold rounded-full"
                        whileHover={{ scale: 1.1 }}
                      >
                        {design.category}
                      </motion.div>
                    </div>

                    <div className="p-6">
                      <h3 className="text-lg font-bold text-white mb-4">
                        {design.title}
                      </h3>

                      <div className="flex gap-3">
                        <motion.button
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                          className="flex-1 py-2 bg-gradient-glow text-white font-semibold rounded-lg hover:shadow-nf-glow transition-all"
                        >
                          Refine
                        </motion.button>
                        <motion.button
                          whileHover={{ scale: 1.05 }}
                          whileTap={{ scale: 0.95 }}
                          className="flex-1 py-2 border-2 border-nf-purple/30 text-nf-purple-light font-semibold rounded-lg hover:bg-nf-purple/10 transition-all"
                        >
                          Download
                        </motion.button>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>

              {/* Action Buttons */}
              <div className="flex gap-4 mt-12 justify-center">
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => {
                    setCurrentStep('upload');
                    setDescription('');
                    setGeneratedDesigns([]);
                  }}
                  className="px-8 py-4 bg-nf-purple/20 border border-nf-purple/30 text-nf-purple-light font-bold rounded-lg hover:bg-nf-purple/30 transition-all"
                >
                  Create Another
                </motion.button>

                <Link href="/dashboard">
                  <motion.button
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    className="px-8 py-4 bg-gradient-glow text-white font-bold rounded-lg shadow-nf-glow hover:shadow-nf-glow-lg transition-all"
                  >
                    Back to Dashboard
                  </motion.button>
                </Link>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </main>
    </div>
  );
}
