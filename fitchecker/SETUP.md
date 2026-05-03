# FitChecker — Setup Guide

## Prerequisites

1. **Flutter SDK** — [Install Flutter](https://docs.flutter.dev/get-started/install/windows)
2. **Android Studio** or **VS Code** with Flutter extension
3. **Supabase account** — [supabase.com](https://supabase.com) (free tier)
4. **Gemini API key** — [aistudio.google.com](https://aistudio.google.com/app/apikey)

---

## Step 1: Install Flutter

```bash
# Download Flutter SDK from https://docs.flutter.dev/get-started/install
# Extract and add to PATH
# Verify installation:
flutter doctor
```

---

## Step 2: Set Up Supabase

### 2.1 Create Project
1. Go to [supabase.com](https://supabase.com) → **New Project**
2. Name it `fitchecker`
3. Set a strong database password
4. Choose your region
5. Wait for project to be created

### 2.2 Run Database Schema
1. Go to **SQL Editor** → **New Query**
2. Copy the entire contents of `supabase_schema.sql`
3. Paste and click **Run**
4. This creates:
   - `profiles` table
   - `measurements` table
   - Row Level Security policies
   - Storage buckets (`profile-images`, `clothing-images`)

### 2.3 Get API Keys
1. Go to **Settings** → **API**
2. Copy:
   - **Project URL** → paste into `.env` as `SUPABASE_URL`
   - **anon public key** → paste into `.env` as `SUPABASE_ANON_KEY`

### 2.4 Enable Auth Providers
1. Go to **Authentication** → **Providers**
2. **Email** should be enabled by default
3. Optional: Enable **Google** provider (requires Google Cloud OAuth credentials)

---

## Step 3: Get Gemini API Key

1. Go to [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
2. Click **Create API Key**
3. Copy the key → paste into `.env` as `AI_API_KEY`

---

## Step 4: Configure Environment

Open `.env` in the project root and replace the placeholders:

```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOi...your-anon-key
AI_API_KEY=AIzaSy...your-gemini-key
```

---

## Step 5: Run the App

```bash
# Navigate to project directory
cd fitchecker

# Get dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## Project Structure

```
fitchecker/
├── .env                          ← API keys (edit this)
├── pubspec.yaml                  ← Dependencies
├── supabase_schema.sql           ← Database setup
├── assets/                       ← Image assets
├── lib/
│   ├── main.dart                 ← App entry point
│   ├── config/
│   │   ├── theme.dart            ← Design system
│   │   ├── routes.dart           ← Navigation
│   │   └── constants.dart        ← App constants
│   ├── models/
│   │   ├── user_profile.dart     ← Profile model
│   │   ├── measurement.dart      ← Measurement model
│   │   └── fit_result.dart       ← Fit result model
│   ├── services/
│   │   ├── auth_service.dart     ← Supabase auth
│   │   ├── database_service.dart ← CRUD operations
│   │   ├── storage_service.dart  ← Image storage
│   │   ├── fit_check_service.dart← Rule-based fit logic
│   │   └── ai_service.dart       ← Gemini AI integration
│   ├── providers/
│   │   ├── auth_provider.dart    ← Auth state
│   │   └── profile_provider.dart ← Profile state
│   ├── widgets/
│   │   ├── app_header.dart       ← Persistent header
│   │   ├── bottom_nav.dart       ← Bottom navigation
│   │   ├── custom_text_field.dart
│   │   ├── custom_button.dart
│   │   ├── custom_card.dart
│   │   └── custom_dropdown.dart
│   └── screens/
│       ├── login_screen.dart
│       ├── user_selection_screen.dart
│       ├── add_person_screen.dart
│       ├── home_screen.dart
│       ├── upload_screen.dart
│       ├── result_screen.dart
│       └── profile_screen.dart
```

---

## Adding a Background Image

1. Place your image in `assets/` (e.g., `assets/background.jpg`)
2. It's already listed in `pubspec.yaml` under assets
3. In `lib/screens/home_screen.dart`, find the comment:
   ```
   // REPLACE_WITH_BACKGROUND_IMAGE
   ```
4. Replace the gradient Container with:
   ```dart
   Image.asset('assets/background.jpg', fit: BoxFit.cover)
   ```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter pub get` fails | Run `flutter doctor` and fix issues |
| Supabase auth not working | Check `.env` keys are correct |
| Google sign-in fails | Configure OAuth in Supabase dashboard |
| AI analysis shows mock data | Verify `AI_API_KEY` in `.env` |
| Images not uploading | Check storage bucket policies in Supabase |
| Build errors | Run `flutter clean && flutter pub get` |

---

## Brand Size Charts

The app includes mock size charts for:
- **Zudio** — Indian budget brand
- **H&M** — European fast fashion
- **Zara** — European premium fast fashion

Size charts are in `lib/services/fit_check_service.dart`. You can add more brands by following the same pattern.

---

## Notes

- The app uses **Gemini 1.5 Flash** for AI styling advice
- If no API key is configured, the app falls back to elegant mock advice
- Profile images are stored in Supabase Storage and used for AI skin tone analysis
- All measurements are in centimeters (cm)
