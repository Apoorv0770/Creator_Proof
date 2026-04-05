export interface User {
  id: string;
  email: string;
  displayName?: string;
  photoURL?: string;
  role: 'user' | 'admin';
  createdAt: Date;
  updatedAt: Date;
}

export interface Design {
  id: string;
  userId: string;
  title: string;
  description: string;
  category: 'web' | 'poster' | 'ui' | 'branding';
  images: DesignImage[];
  status: 'draft' | 'completed';
  createdAt: Date;
  updatedAt: Date;
}

export interface DesignImage {
  id: string;
  url: string;
  title: string;
  tags: string[];
}

export interface Project {
  id: string;
  userId: string;
  name: string;
  description: string;
  designs: string[];
  createdAt: Date;
  updatedAt: Date;
}

export interface PricingTier {
  id: string;
  name: 'free' | 'pro' | 'enterprise';
  monthlyPrice: number;
  yearlyPrice: number;
  features: string[];
  description: string;
  highlighted?: boolean;
}

export interface UserStats {
  designsCreated: number;
  apiCallsThisMonth: number;
  storageUsed: number;
  totalStorage: number;
  lastActiveAt: Date;
}
