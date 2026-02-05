# LittleBites Testing Guide

## Auth Flow Testing

The application now has a complete auth flow integrated with Firebase. Here's how to test it:

### Test Environment
- **URL:** http://localhost:8080
- **Branch:** develop
- **Firebase Status:** Initialized ✅

### Test Scenarios

#### 1. Sign Up Flow
1. Open http://localhost:8080
2. You should see the Login screen (since no user is logged in)
3. Click "Sign Up" link
4. Fill in the form:
   - Name: Test User
   - Email: test@example.com (use a new email each test)
   - Password: test123456
   - Confirm Password: test123456
5. Click "Create Account"
6. **Expected:** You should be redirected to the Create Profile screen

#### 2. Create Profile Flow
1. After signing up, you should see the Create Profile screen
2. Fill in the form:
   - Baby's Name: Baby Test
   - Birth Date: Select a date (e.g., 6 months ago)
3. Click "Create Profile"
4. **Expected:** You should be redirected to the Home screen with your new profile

#### 3. Sign In Flow
1. Sign out from the app (via Settings screen or clear browser data)
2. On the Login screen, enter:
   - Email: test@example.com (your test email)
   - Password: test123456
3. Click "Sign In"
4. **Expected:** You should be logged in and see the Home screen

#### 4. Profile Persistence
1. Log out and close the browser
2. Reopen http://localhost:8080
3. **Expected:** You should still be logged in and see your existing profile

#### 5. Multiple Profiles (Advanced)
1. From the Home screen, navigate to Profiles
2. Click "Add Child"
3. Create a second profile
4. **Expected:** You should be able to switch between profiles

### Firebase Services Status

All Firebase services are implemented:

- ✅ **AuthService** - Email/password authentication
  - `signUpWithEmailAndPassword()` - Creates new user account
  - `signInWithEmailAndPassword()` - Logs in existing user
  - `signOut()` - Logs out current user
  - `sendPasswordResetEmail()` - Sends password reset email
  - Error handling with user-friendly messages

- ✅ **FirebaseMealService** - Firestore CRUD for meals
  - `getMeals(profileId)` - Get all meals for a profile
  - `streamMeals(profileId)` - Real-time stream of meals
  - `getTodayMeals(profileId)` - Get today's meals
  - `addMeal(meal)` - Add new meal
  - `updateMeal(meal)` - Update existing meal
  - `deleteMeal(mealId)` - Delete meal
  - `getMealById(mealId)` - Get meal by ID

- ✅ **FirebaseReactionService** - Firestore CRUD for reactions
  - `getReactions(profileId)` - Get all reactions
  - `streamReactions(profileId)` - Real-time stream
  - `getRecentReactions(profileId, limit)` - Get recent reactions
  - `addReaction(reaction)` - Add new reaction
  - `updateReaction(reaction)` - Update reaction
  - `deleteReaction(reactionId)` - Delete reaction

- ✅ **FirebasePoopService** - Firestore CRUD for poop logs
  - `getPoopLogs(profileId)` - Get all poop logs
  - `streamPoopLogs(profileId)` - Real-time stream
  - `getRecentPoopLogs(profileId, limit)` - Get recent logs
  - `addPoopLog(log)` - Add new log
  - `updatePoopLog(log)` - Update log
  - `deletePoopLog(logId)` - Delete log

- ✅ **FirebaseProfileService** - Firestore CRUD for profiles
  - `getProfiles()` - Get all user's profiles
  - `streamProfiles()` - Real-time stream of profiles
  - `getActiveProfile()` - Get currently active profile
  - `setActiveProfile(profileId)` - Set active profile
  - `addProfile(profile)` - Add new profile
  - `updateProfile(profile)` - Update profile
  - `deleteProfile(profileId)` - Delete profile

### Service Architecture

The app uses a ServiceFactory pattern that:

1. **Checks Firebase availability** - Determines if Firebase is initialized and user is authenticated
2. **Falls back to mock data** - If Firebase is not available, uses MockDataService
3. **Uses providers** - Services are provided via Riverpod providers for state management

**Providers:**
- `authServiceProvider` - Provides AuthService
- `authStateProvider` - Stream of auth state changes (User?)
- `currentUserProvider` - Current authenticated user
- `isLoggedInProvider` - Boolean: is user logged in?
- `mealServiceProvider` - Provides meal service (Firebase or mock)
- `reactionServiceProvider` - Provides reaction service
- `poopServiceProvider` - Provides poop service
- `profileServiceProvider` - Provides profile service

### Auth Flow State Machine

The AuthWrapper manages the auth flow with these states:

1. **checkingAuth** - Initial state, checking if user is logged in
2. **authLoading** - User is logged in, checking if they have profiles
3. **loggedIn** - User is logged in and has profiles - show main app
4. **needProfile** - User is logged in but has no profiles - show create profile screen
5. **loggedOut** - User is not logged in - show login screen
6. **error** - An error occurred - show error screen with retry button

### Known Issues & Future Work

**Priority 1 (Firebase Integration) - DONE:**
- ✅ Implement Firebase service classes
- ✅ Wire up auth screens
- ✅ Test auth flow end-to-end

**Priority 2 (Real-Time Sync) - NEXT:**
- ⏳ Stream-based updates from Firestore (methods already implemented, need UI integration)
- ⏳ Offline-first architecture with local caching
- ⏳ Conflict resolution

**Priority 3 (Photo Upload) - LATER:**
- ⏳ Firebase Storage integration
- ⏳ Image picker integration
- ⏳ Upload progress indicators

**Priority 4 (Testing & Polish) - LATER:**
- ⏳ Widget tests
- ⏳ Integration tests
- ⏳ Edge cases (no internet, auth errors, etc.)
- ⏳ Performance optimization

### Code Quality

- **Flutter Analyze:** 0 errors, 34 info-level warnings (mostly deprecated `withOpacity` calls)
- **Commits:** 3 commits pushed to `develop` branch
  - `feat: integrate auth state and service providers`
  - `fix: update withOpacity to withValues, add AsyncDataBuilder widget`
  - `feat: add create profile screen and update auth flow`

### Next Steps for Testing

1. **Manual Testing:** Follow the test scenarios above
2. **Report Issues:** Document any bugs or edge cases
3. **UI Polish:** Fix deprecation warnings if needed
4. **Real-Time Integration:** Update screens to use stream providers instead of one-time fetches
