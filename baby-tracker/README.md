# LittleBites - Baby Food Tracker

**Codename:** LittleBites
**Phase:** Planning
**Created:** 2026-02-04

---

## Quick Overview

A beautiful, family-focused baby food tracking app. Start with a polished MVP for personal use, then scale to App Store with monetization potential.

**Key Differentiators:**
- Clean, minimal UI (don't overwhelm tired parents)
- Family sharing (multiple caregivers log for same child)
- One-time purchase option (most competitors are subscriptions)
- Better allergen reaction tracking with severity scoring
- Poop tracking (Avo got this right!)

**Tech Stack:** Flutter + Firebase

**Timeline:** 4-5 weeks to MVP

---

## Documentation

- [**PROJECT_PLAN.md**](./PROJECT_PLAN.md) - Comprehensive planning document
  - Competitor analysis
  - MVP features (Phase 1)
  - Future features (Phase 2)
  - Tech stack recommendation
  - Development roadmap
  - Data models
  - Monetization strategy
  - Marketing plan
  - Cost estimates
  - Success metrics

---

## Project Status

### Current Phase: 📋 Planning

**Completed:**
- ✅ Research completed (Solid Starts, BabyBites, Avo, BabyPlate, BLW Meals)
- ✅ Project plan created
- ✅ MVP features defined
- ✅ Tech stack selected (Flutter + Firebase)
- ✅ Data models designed
- ✅ Monetization strategy outlined

**Next Steps:**
- ⏳ Create UI mockups (Figma wireframes)
- ⏳ Initialize Flutter project
- ⏳ Configure Firebase (Auth + Firestore)
- ⏳ Build core data models

---

## Quick Commands

```bash
# Navigate to project
cd /Users/bclawd/.openclaw/workspace/baby-tracker

# View project plan
cat PROJECT_PLAN.md

# Initialize Flutter project (when ready)
flutter create littlebites

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

---

## Directory Structure (Planned)

```
baby-tracker/
├── PROJECT_PLAN.md          # Comprehensive planning doc
├── README.md                # This file
├── littlebites/             # Flutter app (will create)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/          # Data models
│   │   ├── screens/         # UI screens
│   │   ├── widgets/         # Reusable widgets
│   │   ├── services/        # Firebase services
│   │   └── providers/       # Riverpod state management
│   ├── ios/
│   ├── android/
│   └── pubspec.yaml
├── design/                  # UI mockups (Figma exports)
├── docs/                    # Additional documentation
└── screenshots/             # App screenshots for App Store
```

---

## Tech Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| **Mobile Framework** | Flutter (Dart) | Single codebase, beautiful UI, great performance |
| **State Management** | Riverpod | Type-safe, testable, great for Flutter |
| **Backend** | Firebase | Real-time sync, auth, offline-first |
| **Database** | Firestore | NoSQL, scales easily, real-time |
| **Authentication** | Firebase Auth | Email, Google, Apple sign-in |
| **Analytics** | Firebase Analytics | Built-in, free tier generous |
| **Storage** | Firebase Storage | Photos, backup data |

---

## Monetization

**Primary Model:** One-time purchase
- **Single User:** $19.99 - Full lifetime access
- **Family Pack:** $29.99 - Up to 5 family members
- **Pro:** $49.99 - All features + priority support

**Why one-time purchase?**
- Most competitors charge $5-15/month subscriptions
- Parents are subscription-fatigued
- Strong differentiator in the market
- Lower friction to purchase

**Revenue Potential (Year 1):**
- 5,000 downloads × $20 avg = $100K
- 10,000 downloads × $20 avg = $200K

---

## Questions for Bob

1. **Timeline:** Want to move fast (2-3 weeks MVP) or take time (6-8 weeks polished)?
2. **Tech stack:** Flutter (recommended) ok, or prefer something else?
3. **Design:** Want UI mockups first, or dive straight into code?
4. **Firebase vs Supabase:** Any preference? (Firebase easier, Supabase more control)
5. **Beta testers:** Who will test? Partner, family members?

---

*Ready to start building once you give the green light!* 🍼
