import { Header } from '@/components/layout/Header';
import { HeroSection } from '@/components/sections/HeroSection';
import { FeaturesSection } from '@/components/sections/FeaturesSection';
import { PricingSection } from '@/components/sections/PricingSection';
import { BlogSection } from '@/components/sections/BlogSection';
import { CTASection } from '@/components/sections/CTASection';
import { Footer } from '@/components/layout/Footer';

export default function Home() {
  return (
    <main className="relative overflow-hidden bg-gradient-nf">
      <Header />
      <HeroSection />
      <FeaturesSection />
      <PricingSection />
      <BlogSection />
      <CTASection />
      <Footer />
    </main>
  );
}
