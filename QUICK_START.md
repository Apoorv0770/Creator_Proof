# Quick Start Guide - NeuroForge

## ⚡ 5-Minute Setup

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Environment Variables

```bash
cp .env.local.example .env.local
# Edit .env.local and add your Firebase credentials
```

### 3. Start Development Server

```bash
npm run dev
```

### 4. Open in Browser

```
http://localhost:3000
```

## 🎯 First Steps as a Developer

### Explore the Project

```bash
# View home page and 3D scene
http://localhost:3000

# Try authentication
http://localhost:3000/auth

# View dashboard (requires login)
http://localhost:3000/dashboard

# Try design generator
http://localhost:3000/generate
```

### Key Directories to Know

- `src/app/` - Pages and routing
- `src/components/` - Reusable components
- `src/lib/` - Utilities and Firebase config
- `src/hooks/` - Custom React hooks

## 📝 Common Tasks

### Add a New Page

```bash
# Create directory
mkdir src/app/newpage

# Create page file
touch src/app/newpage/page.tsx
```

Example page:

```typescript
'use client';

import { motion } from 'framer-motion';

export default function NewPage() {
  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="min-h-screen bg-gradient-nf"
    >
      {/* Your content */}
    </motion.div>
  );
}
```

### Add a New Component

```bash
# Create component file
touch src/components/MyComponent.tsx
```

Example component:

```typescript
'use client';

import { motion } from 'framer-motion';

interface Props {
  title: string;
}

export function MyComponent({ title }: Props) {
  return (
    <motion.div
      whileHover={{ scale: 1.05 }}
      className="glass rounded-2xl p-6"
    >
      {title}
    </motion.div>
  );
}
```

### Update Tailwind Theme

Edit `tailwind.config.ts`:

```typescript
colors: {
  'custom-color': '#FFFFFF',
}
```

Then use in components:

```tsx
<div className="bg-custom-color text-custom-color"></div>
```

## 🔒 Authentication Flow

### How It Works

1. User visits `/auth`
2. Chooses email or Google sign-in
3. Firebase authenticates
4. User redirected to `/dashboard`
5. Protected routes check auth status

### Protect a Route

```typescript
'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/hooks/useAuth';

export default function ProtectedPage() {
  const { user, loading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!loading && !user) {
      router.push('/auth');
    }
  }, [user, loading, router]);

  if (loading) return <div>Loading...</div>;

  return <div>Protected content</div>;
}
```

## 🎨 Animation Examples

### Simple Fade-In

```typescript
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.5 }}
>
  Content
</motion.div>
```

### Hover Effect

```typescript
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
>
  Click me
</motion.button>
```

### Staggered Animation

```typescript
const container = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
    },
  },
};

const item = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 },
};

<motion.div variants={container} initial="hidden" animate="visible">
  {items.map(i => (
    <motion.div key={i} variants={item}>
      {i}
    </motion.div>
  ))}
</motion.div>
```

## 📊 Firebase Integration

### Add Data to Firestore

```typescript
import { db } from "@/lib/firebase";
import { collection, addDoc } from "firebase/firestore";

// Add a document
await addDoc(collection(db, "designs"), {
  title: "My Design",
  userId: user.uid,
  createdAt: new Date(),
});
```

### Read Data from Firestore

```typescript
import { db } from "@/lib/firebase";
import { collection, query, where, getDocs } from "firebase/firestore";

// Query documents
const q = query(collection(db, "designs"), where("userId", "==", user.uid));
const docs = await getDocs(q);
```

## 🔍 Debugging Tips

### Enable Debug Mode

In `src/lib/firebase.ts`, uncomment emulator setup for local testing.

### Check Network Requests

1. Open DevTools (F12)
2. Go to Network tab
3. Watch API calls
4. Check Firebase requests

### View Component Props

1. Install React DevTools browser extension
2. Select component in DevTools
3. See props and state

## 🚀 Production Checklist

Before deploying:

- [ ] Firebase security rules configured
- [ ] Environment variables set
- [ ] AI API integrated
- [ ] All pages tested
- [ ] Responsive design verified
- [ ] Performance optimized
- [ ] Error pages created
- [ ] Analytics configured

## 📚 Useful Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm start                # Start prod server
npm run lint             # Run linter
npm run type-check       # Check TypeScript

# Firebase CLI (if needed)
firebase login
firebase init
firebase deploy
```

## 🆘 Common Issues

### Issue: Firebase not connecting

**Solution**: Check `.env.local` variables

```bash
cp .env.local.example .env.local
# Add your real Firebase credentials
npm run dev
```

### Issue: 3D scene not rendering

**Solution**: Check browser WebGL support

- Open http://localhost:3000
- Open Console (F12)
- Look for WebGL errors

### Issue: Build errors

**Solution**: Clear cache and reinstall

```bash
rm -rf .next node_modules
npm install
npm run build
```

## 📖 Documentation

- [README.md](README.md) - Project overview
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - What's implemented

## 🎯 Next Steps

1. ✅ Explore the codebase
2. ✅ Set up Firebase
3. ✅ Run development server
4. ✅ Test authentication
5. ✅ Customize components
6. ✅ Add real AI integration
7. ✅ Deploy to Vercel

---

**Happy coding! 🚀**

Need help? Check the docs or ask in discussions!
