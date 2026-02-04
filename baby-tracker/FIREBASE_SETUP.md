# Firebase Setup Guide - LittleBites

**Phase:** Development Setup
**Created:** 2026-02-04

---

## Prerequisites

Before setting up Firebase:
1. ✅ Flutter installed (currently downloading via Homebrew)
2. ⏳ Google account (Gmail)
3. ⏳ Flutter project created
4. ⏳ Firebase CLI installed

---

## Step 1: Install Firebase CLI

```bash
# Install Firebase CLI via npm
npm install -g firebase-tools

# Or via Homebrew (Mac)
brew install firebase-cli

# Login to Firebase
firebase login
```

---

## Step 2: Create Firebase Project

**Via Firebase Console (Web):**

1. Go to https://console.firebase.google.com/
2. Click "Add project"
3. Project name: `littlebites-baby-tracker`
4. Accept default Firebase terms
5. Accept Google Analytics (optional but recommended)
6. Select account for Analytics
7. Click "Create project" (takes ~30 seconds)

**Project created!** 🔥

---

## Step 3: Enable Required Firebase Services

### 3.1 Enable Authentication

1. In Firebase Console → Build → Authentication
2. Click "Get Started"
3. **Sign-in method** tab:
   - ✅ **Email/Password:** Enable
   - ✅ **Google:** Enable (for OAuth)
   - ✅ **Apple:** Enable (for iOS)
4. Click "Save"

### 3.2 Enable Firestore Database

1. In Firebase Console → Build → Firestore Database
2. Click "Create database"
3. Choose location: `asia-southeast1` (Sydney-friendly) or `australia-southeast1`
4. **Security rules:** Start in **Test mode** (for development)
   - Allow read/write for 30 days
   - Will tighten rules before production
5. Click "Enable"

### 3.3 Enable Firebase Storage (for photos)

1. In Firebase Console → Build → Storage
2. Click "Get Started"
3. Choose location: Same as Firestore
4. **Security rules:** Start in **Test mode**
   - Allow read/write for 30 days
5. Click "Enable"

### 3.4 Enable Analytics (Optional but Recommended)

Already enabled during project setup. Good for tracking user behavior.

---

## Step 4: Configure Flutter Project for Firebase

### 4.1 Install FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Verify installation
flutterfire --version
```

### 4.2 Configure Firebase for Flutter

```bash
# Navigate to Flutter project
cd /Users/bclawd/.openclaw/workspace/baby-tracker/littlebites

# Configure Firebase
flutterfire configure

# Interactive prompts:
# 1. Select Firebase project: littlebites-baby-tracker
# 2. Select platforms: iOS, Android
# 3. Let it auto-generate config files
```

This creates:
- `lib/firebase_options.dart` - Firebase configuration
- Updates `ios/` folder with GoogleService-Info.plist
- Updates `android/` folder with google-services.json

---

## Step 5: Add Firebase Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  
  # State Management
  flutter_riverpod: ^2.5.0
  
  # UI
  cupertino_icons: ^1.0.6
  google_fonts: ^6.0.0
  
  # Icons
  flutter_feather_icons: ^2.0.0
  
  # Utils
  intl: ^0.19.0
  image_picker: ^1.0.0
  share_plus: ^7.0.0
  
  # (Add more as needed)
```

Then install dependencies:

```bash
flutter pub get
```

---

## Step 6: Initialize Firebase in Flutter

Update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Required for async main
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LittleBites',
      theme: ThemeData(
        primaryColor: const Color(0xFF4A90E2),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @onerride
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LittleBites'),
      ),
      body: const Center(
        child: Text('Welcome to LittleBites! 🍼'),
      ),
    );
  }
}
```

---

## Step 7: Configure Firestore Security Rules

**Development (Test Mode):**

```javascript
// Firestore Rules (Development)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2026, 3, 1);
    }
  }
}
```

**Production (Tightened Rules):**

```javascript
// Firestore Rules (Production)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Check if user owns the data
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Helper function: Check if user is in family
    function isFamilyMember(familyId) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.familyId == familyId;
    }
    
    // Users collection: Only user can read/write their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    // Profiles (children): Family members can access
    match /profiles/{profileId} {
      allow read: if isFamilyMember(resource.data.familyId);
      allow write: if isFamilyMember(resource.data.familyId);
    }
    
    // Logs (meals, reactions, poop): Family members can access
    match /logs/{logId} {
      allow read: if isFamilyMember(resource.data.familyId);
      allow write: if isFamilyMember(resource.data.familyId);
    }
    
    // Foods: Public read (for allergen database), family write
    match /foods/{foodId} {
      allow read: if true;
      allow write: if isAuthenticated();
    }
  }
}
```

---

## Step 8: Configure Storage Security Rules

**Development (Test Mode):**

```javascript
// Storage Rules (Development)
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if request.time < timestamp.date(2026, 3, 1);
    }
  }
}
```

**Production (Tightened Rules):**

```javascript
// Storage Rules (Production)
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function: Check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function: Check if user is in family
    function isFamilyMember(familyId) {
      return isAuthenticated() && 
             firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.familyId == familyId;
    }
    
    // User avatars: Only user can upload their own avatar
    match /users/{userId}/avatar/{fileName} {
      allow read: if true;
      allow write: if isAuthenticated() && request.auth.uid == userId;
    }
    
    // Food photos: Family members can upload/access
    match /families/{familyId}/foods/{foodId}/{fileName} {
      allow read: if isFamilyMember(familyId);
      allow write: if isFamilyMember(familyId);
    }
    
    // Meal photos: Family members can upload/access
    match /families/{familyId}/meals/{mealId}/{fileName} {
      allow read: if isFamilyMember(familyId);
      allow write: if isFamilyMember(familyId);
    }
    
    // Reaction photos: Family members can upload/access
    match /families/{familyId}/reactions/{reactionId}/{fileName} {
      allow read: if isFamilyMember(familyId);
      allow write: if isFamilyMember(familyId);
    }
    
    // Poop log photos: Family members can upload/access
    match /families/{familyId}/poop/{poopId}/{fileName} {
      allow read: if isFamilyMember(familyId);
      allow write: if isFamilyMember(familyId);
    }
  }
}
```

---

## Step 9: Test Firebase Connection

Run the app:

```bash
# On iOS
flutter run -d ios

# On Android
flutter run -d android
```

**What to check:**
- ✅ App launches without errors
- ✅ Firebase initializes successfully (check console logs)
- ✅ No authentication errors

---

## Step 10: Create Firestore Collections (Optional)

**Option 1: Let the app create collections on first use** (easier)
- Just let the app write data to Firestore
- Collections are auto-created

**Option 2: Manually create collections** (for testing structure)

Create these collections via Firebase Console:
- `users` - User profiles
- `profiles` - Child profiles
- `foods` - Food database (with allergens)
- `logs` - Meals, reactions, poop logs

---

## Firebase Project Structure

```
littlebites-baby-tracker/
├── Authentication (Auth)
├── Firestore (Database)
│   ├── users/
│   │   └── {userId}/
│   │       ├── email: string
│   │       ├── name: string
│   │       ├── familyId: string
│   │       └── createdAt: timestamp
│   │
│   ├── profiles/
│   │   └── {profileId}/
│   │       ├── name: string
│   │       ├── birthDate: timestamp
│   │       ├── familyId: string
│   │       ├── parentId: string
│   │       └── createdAt: timestamp
│   │
│   ├── foods/
│   │   └── {foodId}/
│   │       ├── name: string
│   │       ├── allergens: string[]
│   │       ├── category: string
│   │       └── preparation: string?
│   │
│   ├── logs/
│   │   └── {logId}/
│   │       ├── type: string  // "meal", "reaction", "poop"
│   │       ├── profileId: string
│   │       ├── data: object
│   │       ├── timestamp: timestamp
│   │       ├── loggedBy: string
│   │       └── photos: string[]
│   │
│   └── families/
│       └── {familyId}/
│           ├── name: string
│           ├── members: string[]
│           └── createdAt: timestamp
│
└── Storage (Files)
    ├── users/{userId}/avatar/
    ├── families/{familyId}/foods/
    ├── families/{familyId}/meals/
    ├── families/{familyId}/reactions/
    └── families/{familyId}/poop/
```

---

## Firebase Free Tier Limits

**Good news:** Free tier is generous for MVP and early growth!

**Firestore:**
- 50K daily reads
- 20K daily writes
- 20K daily deletes

**Storage:**
- 5GB stored
- 1GB daily download

**Authentication:**
- 3K SMS verifications/month
- 10K phone authentications/month

**Should be fine for:**
- Personal use ✅
- Early beta testers (10-20 users) ✅
- First 1,000 downloads ✅

**When to upgrade:** Firestore Blaze plan ($25/mo) when you hit limits

---

## Next Steps After Firebase Setup

1. Create data models (Food, Profile, Log, Reaction, PoopLog, User)
2. Set up Riverpod providers for Firebase services
3. Implement Firebase Auth wrapper
4. Implement Firestore CRUD operations
5. Build Home screen
6. Test real-time sync across devices

---

## Troubleshooting

**Issue:** "Firebase initialization failed"
- **Fix:** Check `firebase_options.dart` exists and config is correct
- **Fix:** Run `flutterfire configure` again

**Issue:** "Permission denied" on Firestore
- **Fix:** Check security rules are in test mode for development
- **Fix:** Ensure user is authenticated

**Issue:** Platform-specific issues (iOS/Android)
- **Fix:** iOS: Update `ios/Runner/Info.plist` with required keys
- **Fix:** Android: Update `android/app/build.gradle` with Firebase SDK

---

## Resources

- **Firebase Docs:** https://firebase.flutter.dev/
- **FlutterFire CLI:** https://firebase.google.com/docs/flutter/setup
- **Firestore Rules:** https://firebase.google.com/docs/firestore/security/get-started
- **Storage Rules:** https://firebase.google.com/docs/storage/security/start

---

*Ready to configure Firebase! 🔥*
