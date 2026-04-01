import type { Metadata } from 'next';
import './globals.css';
import { Providers } from '@/components/providers/Providers';

export const metadata: Metadata = {
  title: 'NeuroForge - AI Design Generation Platform',
  description:
    'Your AI-powered creative universe. Upload, generate, refine, and deploy stunning designs with cutting-edge AI technology.',
  keywords: [
    'AI Design',
    'Design Generation',
    'Creative AI',
    'Design Platform',
    'Generative Design',
  ],
  viewport: 'width=device-width, initial-scale=1',
  openGraph: {
    type: 'website',
    url: 'https://neuroforge.ai',
    title: 'NeuroForge - AI Design Generation Platform',
    description: 'Your AI-powered creative universe',
    images: [
      {
        url: 'https://images.unsplash.com/photo-1677442d019cecf8d7e83efdc1564b578?w=1200&h=630',
        width: 1200,
        height: 630,
      },
    ],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <meta name="theme-color" content="#0B0F1A" />
        <link rel="icon" href="/favicon.ico" />
      </head>
      <body className="overflow-x-hidden bg-gradient-nf">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
