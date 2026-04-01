# NeuroForge Setup and Integration Guide

## Initial Setup Checklist

- [x] Project scaffolding complete
- [x] All dependencies configured
- [ ] Firebase project created
- [ ] Environment variables configured
- [ ] Development server tested
- [ ] Build verified
- [ ] Deployment configured

## 📋 Step-by-Step Setup

### 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "NeuroForge"
3. Enable Google Analytics (optional)
4. Once created, go to Project Settings
5. Create a web app:
   - Click "</>" icon
   - Name it "NeuroForge Web"
   - Copy the Firebase config

### 2. Authentication Setup

1. Go to Authentication > Sign-in method
2. Enable the following providers:
   - Email/Password
   - Google

### 3. Firestore Database Setup

1. Create Cloud Firestore database:
   - Start in production mode
   - Choose region closest to you
2. Create collections:
   - `users` - Store user profiles
   - `designs` - Store design projects
   - `projects` - Store project data

3. Set security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    match /designs/{designId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    match /projects/{projectId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Environment Variables

1. Copy `.env.local.example` to `.env.local`
2. Add your Firebase credentials:

```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_domain
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_bucket
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```

## 🔌 API Integration

### Design Generation API

To integrate real AI design generation, implement an API endpoint:

```typescript
// src/app/api/designs/generate/route.ts
import { NextRequest, NextResponse } from "next/server";

export async function POST(request: NextRequest) {
  try {
    const { description, category } = await request.json();

    // Call your AI service (OpenAI, Replicate, etc.)
    const response = await fetch(process.env.AI_API_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env.AI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        prompt: `Generate a ${category} design based on: ${description}`,
        num_images: 3,
      }),
    });

    const designs = await response.json();
    return NextResponse.json({ designs });
  } catch (error) {
    return NextResponse.json({ error: "Generation failed" }, { status: 500 });
  }
}
```

### Recommended AI Providers

1. **OpenAI DALL-E 3** - Text-to-image
   - [docs.openai.com](https://platform.openai.com/docs)
   - Excellent for design generation

2. **Replicate** - Open-source models
   - [replicate.com](https://replicate.com)
   - More affordable option

3. **Stability AI** - Stable Diffusion
   - [platform.stability.ai](https://platform.stability.ai)
   - Fast and reliable

4. **Hugging Face** - Multiple models
   - [huggingface.co](https://huggingface.co)
   - Open-source options

## 🚀 Development Commands

```bash
# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Start production server
npm start

# Run linter
npm run lint

# Type checking
npm run type-check
```

## 📊 Database Schema

### Users Collection

```javascript
{
  uid: string,
  email: string,
  displayName: string,
  photoURL: string,
  role: 'user' | 'admin',
  subscription: 'free' | 'pro' | 'enterprise',
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Designs Collection

```javascript
{
  id: string,
  userId: string,
  title: string,
  description: string,
  category: string,
  images: [
    {
      url: string,
      title: string,
      tags: string[]
    }
  ],
  status: 'draft' | 'completed',
  createdAt: timestamp,
  updatedAt: timestamp
}
```

## 🔒 Security Best Practices

1. **Environment Variables**
   - Never commit `.env.local` to git
   - Use `.env.local.example` as template
   - Rotate credentials regularly

2. **Firebase Security**
   - Use strict Firestore rules
   - Enable reCAPTCHA for auth
   - Use custom claims for roles

3. **API Security**
   - Implement rate limiting
   - Validate all inputs
   - Use HTTPS only
   - Add CORS headers properly

## 🧪 Testing

### Manual Testing Checklist

- [ ] Home page loads and 3D scene renders
- [ ] Authentication flow works (signup/signin)
- [ ] Dashboard loads user data
- [ ] Design generation form validates
- [ ] Pricing toggle works
- [ ] Responsive design on mobile
- [ ] Dark/Light theme toggle works

### Unit Testing Setup

```bash
npm install --save-dev @testing-library/react @testing-library/jest-dom jest
```

## 📈 Performance Optimization

1. **Image Optimization**
   - Use Next.js Image component
   - Optimize image sizes
   - Use WebP format

2. **Code Splitting**
   - Dynamic imports for heavy components
   - Route-based splitting built-in

3. **Caching**
   - Set appropriate cache headers
   - Use revalidation strategies

## 🐛 Debugging

### Common Issues

1. **Firebase not initializing**
   - Check `.env.local` variables
   - Verify Firebase project is active

2. **3D scene not rendering**
   - Check WebGL support
   - Verify Three.js installation
   - Check browser compatibility

3. **Build errors**
   - Clear `.next` folder
   - Reinstall node_modules
   - Check Node version

## 📚 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [Framer Motion](https://www.framer.com/motion/)
- [Three.js](https://threejs.org/docs/)

## 🎯 Next Steps After Setup

1. Configure real AI API
2. Set up email notifications
3. Implement payment system (Stripe)
4. Add analytics (Vercel Analytics)
5. Set up monitoring (Sentry)
6. Deploy to Vercel
7. Set up CI/CD pipeline
8. Add automated testing

---

**Need help?** Check the README.md or create an issue on GitHub.
