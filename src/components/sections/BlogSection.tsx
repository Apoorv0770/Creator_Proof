'use client';

import { motion } from 'framer-motion';
import { useState } from 'react';
import { createContainerVariants, itemVariants } from '@/lib/animations';

interface BlogPost {
  id: number;
  title: string;
  excerpt: string;
  date: string;
  image: string;
  category: string;
}

const blogPosts: BlogPost[] = [
  {
    id: 1,
    title: 'The Future of AI-Powered Design',
    excerpt:
      'Explore how artificial intelligence is revolutionizing the creative industry and changing the way designers work.',
    date: 'Feb 17, 2026',
    image: 'https://images.unsplash.com/photo-1677442d019cecf8d7e83efdc1564b578?w=500&h=300',
    category: 'AI & Design',
  },
  {
    id: 2,
    title: 'Mastering Creative Workflows',
    excerpt:
      'Learn best practices for organizing your design process and collaborating with team members efficiently.',
    date: 'Feb 15, 2026',
    image: 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=500&h=300',
    category: 'Workflow',
  },
  {
    id: 3,
    title: 'Generative Design: What You Need to Know',
    excerpt:
      'A comprehensive guide to understanding generative design and how NeuroForge implements cutting-edge algorithms.',
    date: 'Feb 13, 2026',
    image: 'https://images.unsplash.com/photo-1561070791-2526d30994b5?w=500&h=300',
    category: 'Technology',
  },
];

export function BlogSection() {
  const [hoveredId, setHoveredId] = useState<number | null>(null);
  const containerVariants = createContainerVariants(0.15);

  return (
    <section
      id="blog"
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
            Latest Insights &
            <br />
            <span className="bg-gradient-glow bg-clip-text text-transparent">
              Creative Tips
            </span>
          </h2>
          <p className="text-gray-400 text-lg max-w-2xl mx-auto">
            Stay updated with the latest trends in AI-powered design and creative
            innovation.
          </p>
        </motion.div>

        <motion.div
          className="grid grid-cols-1 md:grid-cols-3 gap-8"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
        >
          {blogPosts.map((post) => (
            <motion.article
              key={post.id}
              variants={itemVariants}
              onMouseEnter={() => setHoveredId(post.id)}
              onMouseLeave={() => setHoveredId(null)}
              className="group glass rounded-2xl overflow-hidden hover:bg-nf-purple/10 transition-all duration-300"
            >
              {/* Image */}
              <div className="relative h-48 overflow-hidden">
                <motion.img
                  src={post.image}
                  alt={post.title}
                  className="w-full h-full object-cover"
                  animate={{
                    scale: hoveredId === post.id ? 1.1 : 1,
                  }}
                  transition={{ duration: 0.3 }}
                />
                <div className="absolute inset-0 bg-gradient-to-t from-nf-dark/80 to-transparent" />
                <motion.div
                  className="absolute top-4 right-4 px-3 py-1 bg-nf-purple/80 text-white text-xs font-bold rounded-full"
                  animate={{
                    y: hoveredId === post.id ? -5 : 0,
                  }}
                >
                  {post.category}
                </motion.div>
              </div>

              {/* Content */}
              <div className="p-6">
                <motion.h3
                  className="text-lg font-bold text-white mb-3 line-clamp-2"
                  animate={{
                    color: hoveredId === post.id ? '#C084FC' : '#FFFFFF',
                  }}
                >
                  {post.title}
                </motion.h3>

                <p className="text-gray-400 text-sm mb-4 line-clamp-2">
                  {post.excerpt}
                </p>

                <div className="flex items-center justify-between mt-6">
                  <span className="text-xs text-gray-500">{post.date}</span>
                  <motion.div
                    animate={{
                      x: hoveredId === post.id ? 5 : 0,
                    }}
                    className="text-nf-purple-light font-bold"
                  >
                    Read More →
                  </motion.div>
                </div>
              </div>

              {/* Glow on hover */}
              {hoveredId === post.id && (
                <motion.div
                  className="absolute inset-0 border-2 border-nf-purple/50 rounded-2xl pointer-events-none"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                />
              )}
            </motion.article>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
