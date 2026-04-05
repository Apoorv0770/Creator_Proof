# Creator Proof Flutter App - Setup Guide

## Complete Setup Instructions for Beginners

---

## Part 1: Install Flutter

### Step 1.1: Download Flutter

1. Go to: https://docs.flutter.dev/get-started/install/windows
2. Click "flutter_windows_3.x.x-stable.zip" to download
3. Extract the ZIP file to `C:\flutter` (NOT in Program Files!)

### Step 1.2: Add Flutter to PATH

1. Press `Win + X`, click "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find "Path", click "Edit"
5. Click "New", add: `C:\flutter\bin`
6. Click OK on all windows

### Step 1.3: Verify Installation

1. Open NEW Command Prompt (Win + R, type `cmd`)
2. Run: `flutter doctor`
3. You should see Flutter is installed

---

## Part 2: Install Android Studio

### Step 2.1: Download Android Studio

1. Go to: https://developer.android.com/studio
2. Download and install Android Studio
3. During setup, check "Android SDK" and "Android Virtual Device"

### Step 2.2: Setup Android SDK

1. Open Android Studio
2. Go to Tools → SDK Manager
3. Under "SDK Platforms", check "Android 13" or latest
4. Under "SDK Tools", check:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
5. Click Apply and wait for download

### Step 2.3: Accept Licenses

Run in Command Prompt:

```
flutter doctor --android-licenses
```

Type `y` for all prompts

---

## Part 3: Configure Firebase for Android

### Step 3.1: Add Android App to Firebase

1. Go to https://console.firebase.google.com
2. Open your "Creatorproof" project
3. Click "Add app" → Android icon
4. Enter package name: `com.example.cep_app`
5. Click "Register app"

### Step 3.2: Download Config File

1. Click "Download google-services.json"
2. Save this file to:
   ```
   D:\WORK\CEP\app.cep\cep_app\android\app\google-services.json
   ```

### Step 3.3: Enable Firebase Services

In Firebase Console:

1. Authentication → Sign-in method → Enable Google
2. Firestore Database → Create database (test mode)
3. Storage → Get started (test mode)

---

## Part 4: Run the App

### Step 4.1: Open Terminal in Project

1. Open VS Code
2. File → Open Folder → `D:\WORK\CEP\app.cep\cep_app`
3. Terminal → New Terminal

### Step 4.2: Get Dependencies

```
flutter pub get
```

Wait for it to complete (may take a few minutes first time)

### Step 4.3: Start Android Emulator

Option A: From Android Studio

1. Open Android Studio
2. Tools → Device Manager
3. Create Virtual Device → Select phone → Download system image → Finish
4. Click Play button to start emulator

Option B: From Command Line

```
flutter emulators
flutter emulators --launch <emulator_id>
```

### Step 4.4: Run the App

```
flutter run
```

The app will build and install on the emulator!

---

## Part 5: Run on Real Android Phone

### Step 5.1: Enable Developer Mode

1. On your phone: Settings → About phone
2. Tap "Build number" 7 times
3. Go back to Settings → Developer options
4. Enable "USB debugging"

### Step 5.2: Connect Phone

1. Connect phone to computer with USB cable
2. On phone, tap "Allow" when prompted for USB debugging
3. Run `flutter devices` to verify phone is detected
4. Run `flutter run`

---

## Troubleshooting

### "JAVA_HOME not set"

1. Download JDK from https://adoptium.net
2. Install it
3. Add to Environment Variables:
   - Variable: `JAVA_HOME`
   - Value: `C:\Program Files\Eclipse Adoptium\jdk-17.x.x` (your path)

### "Android SDK not found"

Run: `flutter config --android-sdk "C:\Users\YOUR_NAME\AppData\Local\Android\Sdk"`

### "google-services.json not found"

Make sure the file is in:

```
D:\WORK\CEP\app.cep\cep_app\android\app\google-services.json
```

### "Gradle build failed"

1. Delete `android/.gradle` folder
2. Run `flutter clean`
3. Run `flutter pub get`
4. Try `flutter run` again

---

## What Each Screen Does

1. **Splash Screen** - Loading screen when app starts
2. **Login Screen** - Sign in with Google
3. **Home Screen** - Dashboard with your proofs and stats
4. **Upload Screen** - Create new proof (pick file, add details, store on blockchain)
5. **Verify Screen** - Check if a file/hash has been registered
6. **Explore Screen** - Browse public proofs from other creators
7. **Profile Screen** - Your account settings and wallet connection

---

## Next Steps After Setup

1. Sign in with Google
2. Connect wallet (MetaMask mobile or WalletConnect)
3. Upload your first file
4. Store proof on Polygon blockchain
5. Share your verified proof!
