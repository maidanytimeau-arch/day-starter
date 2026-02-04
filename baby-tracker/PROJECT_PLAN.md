# Baby Food Tracker - Project Plan

**Project Codename:** LittleBites
**Status:** Planning Phase
**Created:** 2026-02-04
**Target:** Personal use → Scale to public launch

---

## Executive Summary

A beautiful, family-focused baby food tracking app that simplifies the solids journey. Start with a polished MVP for personal/family use, then scale to App Store with monetization potential.

**Differentiation:** Clean UI, family collaboration, one-time purchase option, better allergen tracking.

---

## Competitor Analysis

| App | Strengths | Weaknesses |
|-----|-----------|------------|
| **Solid Starts** | Comprehensive food database, expert guidance | Subscription only, cluttered UI |
| **BabyBites** | Simple, one-time purchase | Limited features, basic tracking |
| **Avo** | Unique poop tracking | Niche focus, outdated UI |
| **BabyPlate** | Weekly progressive plans | Subscription, basic tracking |
| **BLW Meals** | Age-based guidance | Meal-focused, not tracking |

**Market Gaps:**
- ❌ Most apps require subscriptions ($5-15/month)
- ❌ Poor family sharing (single parent use)
- ❌ Cluttered interfaces with too many features
- ❌ Limited allergen severity tracking
- ❌ Poor data visualization over time

---

## MVP Features (Phase 1 - Personal/Family Use)

### Core Tracking
- ✅ **Food Log** - Add foods with date, time, preparation method
- ✅ **Allergen Detection** - Auto-tag common allergens (nuts, dairy, eggs, etc.)
- ✅ **Reaction Tracking** - Severity scoring (1-5), symptoms, timeline
- ✅ **Poop Tracker** - Color, consistency, notes (Avo got this right)
- ✅ **Daily Summary** - Quick overview of today's intake and reactions

### Family Features
- ✅ **Multiple Profiles** - Track multiple children
- ✅ **Caregiver Sharing** - Invite partner/family to log for same child
- ✅ **Sync Across Devices** - Real-time updates (parent + partner)

### Data & Insights
- ✅ **Food History** - See all foods ever tried
- ✅ **Reaction Timeline** - Visual chart of reactions over time
- ✅ **Success Rate** - Track acceptance level per food
- ✅ **Export Data** - PDF/CSV for doctor visits

### UX/Design
- ✅ **Clean, Minimal UI** - Don't overwhelm new parents
- ✅ **Dark Mode** - Late-night feeds
- ✅ **Quick Actions** - Log meal in <10 seconds
- ✅ **Offline Support** - Works without internet

---

## Future Features (Phase 2 - Public Launch)

### Advanced Tracking
- 🔄 **Nutrition Analysis** - Macro breakdown of meals
- 🔄 **Meal Planning** - Weekly meal suggestions
- 🔄 **Growth Tracking** - Weight/height milestones
- 🔄 **Photo Gallery** - Meal photos, reaction photos

### Premium Features (Optional Tier)
- 🔄 **Expert Content** - Pediatrician articles, weaning guides
- 🔄 **Community** - Share recipes, tips with other parents
- 🔄 **Integration** - Apple Health, Google Fit sync
- 🔄 **AI Suggestions** - "Try X food next" based on history

### Monetization
- 💰 **One-time purchase** ($19.99) - Full lifetime access
- 💰 **Family Pack** ($29.99) - Up to 5 family members
- 💰 **Premium tier** ($4.99/month or $39.99/year) - Expert content + AI

---

## Tech Stack Recommendation

### Mobile App
**Framework:** Flutter (Dart)
- ✅ Single codebase for iOS + Android
- ✅ Beautiful, smooth UI out of the box
- ✅ Excellent state management (Riverpod/Bloc)
- ✅ Great offline support
- ✅ Large community and packages

### Backend
**Option A (Recommended for MVP): Firebase**
- ✅ Real-time sync (perfect for family sharing)
- ✅ Offline-first by default
- ✅ Auth built-in (email, Google, Apple)
- ✅ Free tier generous for personal use
- ✅ Easy to scale later

**Option B (More Control): Supabase**
- ✅ PostgreSQL-based (open source Firebase alternative)
- ✅ Real-time subscriptions
- ✅ Better query capabilities
- ✅ Self-host option available
- ❌ Slightly more setup than Firebase

### Frontend Architecture
```
Flutter App (Riverpod)
    ↓
Firebase SDK
    ↓
Firestore (data) + Auth (users)
```

---

## Development Roadmap

### Phase 1: MVP (2-3 weeks)
**Week 1: Foundation**
- [ ] Set up Flutter project (iOS + Android)
- [ ] Configure Firebase (Auth + Firestore)
- [ ] Design data models (foods, logs, reactions, profiles)
- [ ] Build core UI structure (navigation, theme)

**Week 2: Core Tracking**
- [ ] Food logging feature (add, edit, delete)
- [ ] Allergen auto-tagging system
- [ ] Reaction tracking with severity scoring
- [ ] Poop tracking feature
- [ ] Daily summary view

**Week 3: Family + Polish**
- [ ] Multiple child profiles
- [ ] Family sharing (invite caregivers)
- [ ] Real-time sync testing
- [ ] Offline support
- [ ] Data export (PDF/CSV)
- [ ] Dark mode
- [ ] Bug fixes, testing with family

### Phase 2: Production Ready (1-2 weeks)
**Week 4: Store Launch Prep**
- [ ] App Store Connect setup (iOS)
- [ ] Google Play Console setup (Android)
- [ ] Privacy policy, terms of service
- [ ] App screenshots and descriptions
- [ ] Beta testing with family/friends
- [ ] Analytics (Firebase Analytics)

**Week 5: Launch**
- [ ] Submit to App Store (review takes 1-3 days)
- [ ] Submit to Google Play (review takes <1 day)
- [ ] Launch marketing (social media, parent groups)
- [ ] Monitor reviews and feedback
- [ ] Quick fix releases

### Phase 3: Growth (Ongoing)
- [ ] Gather user feedback
- [ ] Iterate on top-requested features
- [ ] Add premium tier content
- [ ] Expand to more countries/languages

---

## Data Models

### Profile (Child)
```dart
{
  id: string
  name: string
  birthDate: DateTime
  avatar?: string
  parentId: string
  createdAt: DateTime
}
```

### Food
```dart
{
  id: string
  name: string
  allergens: string[] // ["dairy", "nuts", "eggs", "soy", "wheat", "fish", "shellfish"]
  category: string // "fruit", "vegetable", "protein", "grain", "dairy"
  preparation?: string // "steamed", "roasted", "pureed", "finger food"
}
```

### Log (Meal Entry)
```dart
{
  id: string
  profileId: string
  foods: Food[] // Array of foods in this meal
  timestamp: DateTime
  notes?: string
  loggedBy: string // userId
  photos?: string[] // Image URLs
}
```

### Reaction
```dart
{
  id: string
  profileId: string
  foodId?: string // Optional - could be environmental
  severity: number // 1-5 (mild to severe)
  symptoms: string[] // ["rash", "vomiting", "hives", "swelling"]
  startTime: DateTime
  endTime?: DateTime
  notes?: string
  loggedBy: string
  photos?: string[]
}
```

### PoopLog
```dart
{
  id: string
  profileId: string
  timestamp: DateTime
  color: string // "brown", "green", "yellow", "black", "red"
  consistency: string // "hard", "formed", "soft", "loose", "watery"
  notes?: string
  photos?: string[]
}
```

### User (Caregiver)
```dart
{
  id: string (Firebase Auth UID)
  email: string
  name: string
  avatar?: string
  familyId?: string // For family sharing
  invitedBy?: string
  createdAt: DateTime
}
```

---

## User Flow

### Core Flow: Log a Meal
1. Open app → Tap "+" button
2. Select child (if multiple)
3. Add foods (type name or select from history)
4. Choose preparation method (optional)
5. Add notes/photos (optional)
6. Save → Logged to Firebase, syncs to family devices

### Reaction Flow
1. Tap "Report Reaction" from home
2. Select child
3. Select suspected food (or environmental)
4. Choose severity (1-5 slider)
5. Select symptoms (checkboxes)
6. Add notes/photos
7. Save → Alert family members if severity ≥3

### Family Sharing Flow
1. Settings → Invite Family Member
2. Enter email → Send invite
3. Recipient clicks link, signs in
4. Added to family, sees shared profiles
5. Can log for all family children

---

## Monetization Strategy

### Option A: One-Time Purchase (Recommended)
- **Single User:** $19.99 - Full lifetime access
- **Family Pack:** $29.99 - Up to 5 family members
- **Pro:** $49.99 - All features + priority support + early access

**Why:** Most competitors are subscription-based ($5-15/month). One-time purchase is a major differentiator. Parents are tired of subscriptions.

### Option B: Hybrid Model
- **Free Tier:** Basic tracking (limited to 1 child, 30-day history)
- **Premium ($4.99/month or $39.99/year):** Unlimited everything, family sharing, advanced insights

**Why:** Lower barrier to entry, but recurring revenue. Risk: Lower perceived value vs one-time purchase.

### Revenue Estimate (Conservative)
- 100 downloads/month × $20 avg = $2,000/month
- 1,000 downloads/month × $20 avg = $20,000/month
- 10,000 downloads/month × $20 avg = $200,000/month

**Realistic first year:** 5,000-10,000 downloads = $100K-$200K revenue

---

## Marketing Strategy

### Pre-Launch
- Build waitlist on landing page (email capture)
- Share development progress on social media
- Join parent/Baby Led Weaning communities
- Beta testing with 20-30 families

### Launch
- App Store/Google Play Featured (if lucky!)
- Social media campaign (Instagram, TikTok, Reddit)
- Influencer partnerships (mom bloggers, pediatricians)
- Limited launch discount (50% off first week)

### Post-Launch
- Gather and showcase testimonials
- Encourage word-of-mouth (referral program)
- Content marketing (weaning guides, recipes)
- Cross-promote with baby brands

---

## Costs

### Development Costs
- **Time:** 4-5 weeks (full-time) or 8-10 weeks (part-time)
- **Developer tools:** $0 (Flutter, VS Code free)
- **Design:** $0 (I'll design, or Figma free tier)

### Ongoing Costs
- **Firebase Free Tier:** $0 (up to 50K daily reads, 20K daily writes)
- **App Store Developer:** $99/year (Apple)
- **Google Play Developer:** $25 one-time (Android)
- **Hosting (website):** Free (GitHub Pages, Netlify)

### Scaling Costs (if successful)
- **Firebase Blaze Plan:** ~$25-100/month (beyond free tier)
- **Marketing:** $500-2000/month initially
- **Support tools:** ~$50/month (if need help desk)

---

## Success Metrics

### Launch Goals
- ✅ App approved on both stores
- ✅ 100+ downloads in first month
- ✅ 4.0+ star rating with 20+ reviews
- ✅ 70%+ retention (returning after 1 week)

### 6-Month Goals
- ✅ 5,000+ downloads
- ✅ 4.5+ star rating with 100+ reviews
- ✅ 50%+ retention (returning after 1 month)
- ✅ 10% conversion rate (if using freemium)
- ✅ $100K+ revenue

### 12-Month Goals
- ✅ 25,000+ downloads
- ✅ Feature in "New & Noteworthy"
- ✅ Partner with pediatricians/brands
- ✅ $500K+ revenue

---

## Risks & Mitigation

### Risk 1: Market Saturation
**Mitigation:** Focus on family sharing and one-time purchase as key differentiators. Better UI/UX than competitors.

### Risk 2: Technical Issues
**Mitigation:** Thorough beta testing, Firebase autoscaling, quick update cycle.

### Risk 3: Low Discovery
**Mitigation:** Aggressive social media marketing, community engagement, early influencer partnerships.

### Risk 4: Competitor Copy
**Mitigation:** Build strong brand loyalty, iterate quickly, add unique features (poop tracking, better allergen scoring).

### Risk 5: App Store Rejection
**Mitigation:** Follow all guidelines carefully, build medical disclaimer for reaction tracking (not diagnostic).

---

## Next Steps

1. ✅ **Research Phase** (NOW) - Study competitors, define features
2. **Design Phase** - Create wireframes, UI mockups, design system
3. **Setup Phase** - Initialize Flutter project, Firebase config
4. **Development Phase** - Build MVP (see roadmap above)
5. **Testing Phase** - Beta test with family/friends
6. **Launch Phase** - Submit to stores, marketing campaign
7. **Growth Phase** - Iterate based on feedback

---

## Questions for Bob

1. **Timeline:** Want to move fast (2-3 weeks MVP) or take time (6-8 weeks polished)?
2. **Tech stack:** Flutter (recommended) or prefer something else?
3. **Design:** Want me to create UI mockups first, or dive straight into code?
4. **Firebase vs Supabase:** Any preference? Firebase is easier; Supabase gives more control.
5. **Family testing:** Who will be the beta testers? Partner, other family members?

---

*Let me know which direction to take, and I'll start building!* 🍼
