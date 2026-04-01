# NeuroForge - AI-Powered Design Generation Platform

A production-ready, ultra-premium web application showcasing cutting-edge AI design generation with immersive 3D animations, real-time collaboration, and a futuristic design language.

## 🎨 Features

### Visual Design

- **Futuristic Dark Theme**: Deep charcoal/black gradients with electric purple accents
- **Glassmorphism UI**: Frosted glass overlays with backdrop blur effects
- **3D Animations**: Rotating liquid purple energy rings powered by Three.js and React Three Fiber
- **Particle Background**: Ambient animated particle field for immersive atmosphere
- **Smooth Micro-interactions**: Magnetic buttons, cursor-based lighting effects, and hover animations
- **Responsive Design**: Mobile-first approach with full responsiveness across all devices

### Core Features

- **AI Design Generation**: Step-by-step design creation with upload, generate, and refine flows
- **User Authentication**: Firebase auth with email/password and Google sign-in
- **Dashboard**: Usage analytics, project management, and quick stats
- **Pricing System**: 3-tier pricing with monthly/yearly toggle
- **Blog Section**: Interactive blog cards with hover effects and animations
- **Design Templates**: Multiple design categories (Web, Poster, UI, Branding)

### Technology Stack

- **Frontend**: Next.js 15, React 18, TypeScript
- **Styling**: Tailwind CSS with custom animations
- **3D Graphics**: Three.js with React Three Fiber
- **Animations**: Framer Motion for smooth transitions
- **Backend**: Firebase Authentication & Firestore
- **Deployment**: Optimized for Vercel

## 🚀 Quick Start

### Prerequisites

- Node.js 18.x or higher
- npm or yarn package manager
- Firebase project (free tier available)

### Installation

1. **Clone or Download the Project**

```bash
cd neuroforge
```

2. **Install Dependencies**

```bash
npm install
```

3. **Configure Firebase**
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Create a new project
   - Enable Authentication (Email/Password and Google)
   - Copy your config values
   - Rename `.env.local.example` to `.env.local`:

```bash
cp .env.local.example .env.local
```

- Add your Firebase credentials to `.env.local`

4. **Run Development Server**

```bash
npm run dev
```

5. **Open in Browser**

```
http://localhost:3000
```

## 📁 Project Structure

```
/src
├── /app                      # Next.js App Router pages
│   ├── /auth                # Authentication pages
│   ├── /dashboard           # User dashboard
│   ├── /generate            # AI design generation
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Home page
│   └── globals.css          # Global styles
├── /components
│   ├── /3d                  # Three.js/React Three Fiber components
│   │   ├── HeroScene.tsx   # Main 3D hero element
│   │   └── ParticleBackground.tsx # Ambient particle field
│   ├── /layout              # Layout components
│   │   ├── Header.tsx       # Navigation header
│   │   └── Footer.tsx       # Footer
│   ├── /sections            # Page sections
│   │   ├── HeroSection.tsx   # Hero with typing animation
│   │   ├── FeaturesSection.tsx
│   │   ├── PricingSection.tsx # With toggle
│   │   ├── BlogSection.tsx    # Interactive blog cards
│   │   └── CTASection.tsx     # Call-to-action with wave effect
│   └── /providers           # Context/Provider components
│       └── Providers.tsx    # Theme and global providers
├── /lib                     # Utility functions
│   ├── firebase.ts          # Firebase configuration
│   └── utils.ts             # Helper functions
├── next.config.ts           # Next.js configuration
├── tailwind.config.ts       # Tailwind CSS customization
└── tsconfig.json            # TypeScript configuration
```

## 🎯 Key Pages

### Home Page (`/`)

- Immersive hero section with 3D animations
- Feature showcase with hover effects
- Pricing comparison with toggle
- Blog section with interactive cards
- Final CTA section with wave animations

### Authentication Page (`/auth`)

- Email/password sign-up and sign-in
- Google OAuth integration
- Real-time form validation
- Error handling with user feedback

### Dashboard Page (`/dashboard`)

- User profile and stats
- Recent projects
- Quick access to design generator
- Theme toggle (Light/Dark)
- Sign-out functionality

### Design Generation Page (`/generate`)

- Multi-step form for design input
- Moodboard upload capability
- Category selection
- AI generation with progress animation
- Generated design preview and download options

## 🛠 Development

### Building for Production

```bash
npm run build
npm start
```

### Running Type Checks

```bash
npm run type-check
```

### Linting

```bash
npm run lint
```

## 📦 Dependencies

### Core

- `next@^15.1.0` - React framework
- `react@^18.3.1` - UI library
- `typescript@^5.7.2` - Type safety

### Styling & Animation

- `tailwindcss@^3.4.1` - Utility-first CSS
- `framer-motion@^11.5.4` - Animation library

### 3D Graphics

- `three@^r128` - 3D library
- `@react-three/fiber@^8.17.0` - React renderer for Three.js
- `@react-three/drei@^9.115.0` - Helpful components for Three.js

### Backend & Auth

- `firebase@^10.12.0` - Auth & database
- `next-themes@^0.3.0` - Theme management

### Utilities

- `clsx@^2.1.0` - Conditional classnames
- `tailwind-merge@^2.4.0` - Merge Tailwind classes

## 🚀 Deployment

### Deploy to Vercel

1. **Push to GitHub**

```bash
git init
git add .
git commit -m "Initial commit: NeuroForge"
git push -u origin main
```

2. **Connect to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Import your repository
   - Add environment variables from `.env.local`
   - Deploy!

### Alternative: Docker

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

## 🔐 Environment Variables

Create a `.env.local` file with:

```env
# Firebase
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=...
NEXT_PUBLIC_FIREBASE_PROJECT_ID=...
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=...
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...

# Optional: AI API
NEXT_PUBLIC_AI_API_ENDPOINT=...
NEXT_PUBLIC_AI_API_KEY=...
```

## 🎨 Customization

### Colors

Edit `tailwind.config.ts` to customize the color palette:

```typescript
colors: {
  'nf-dark': '#0B0F1A',
  'nf-purple': '#8A2BE2',
  // ... more colors
}
```

### Animations

Modify animation keyframes in `tailwind.config.ts` and `src/app/globals.css`

### 3D Scene

Customize 3D elements in `src/components/3d/HeroScene.tsx`

## 📱 Responsive Breakpoints

- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

All components are optimized for mobile-first design.

## 🔧 Performance Optimization

- Image optimization with Next.js Image component
- Code splitting with dynamic imports
- CSS minification with Tailwind
- JavaScript optimization with SWC
- 3D scene optimizations with proper LOD

## 📚 API Integration

The app is structured to integrate with your backend:

```typescript
// Example: In src/app/generate/page.tsx
const response = await fetch("/api/generate", {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ description, category }),
});
```

Create API routes in `src/app/api/` directory.

## 🐛 Troubleshooting

### Firebase Connection Issues

- Verify credentials in `.env.local`
- Check Firebase project is active
- Enable required authentication methods

### 3D Scene Not Rendering

- Ensure Three.js is installed: `npm install three @react-three/fiber`
- Check browser WebGL support
- Verify GPU acceleration is enabled

### Build Errors

- Clear `.next` folder: `rm -rf .next`
- Reinstall dependencies: `npm install`
- Check Node version: `node --version`

## 📄 License

MIT License - Feel free to use this project for personal and commercial purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Check the documentation
- Review the code comments

## 🎯 Future Enhancements

- [ ] Real AI integration (OpenAI API, Hugging Face)
- [ ] WebSocket for real-time collaboration
- [ ] Advanced design editor
- [ ] Team management and permissions
- [ ] Design history and versioning
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] API documentation (OpenAPI/Swagger)

---

**Built with ❤️ for creative professionals. Transform your ideas into reality with NeuroForge.**
