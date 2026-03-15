# DIPODDI - Complete Technical Architecture & Reference Guide

> **Living Document** — Update this file after every significant change.
> Last updated: 2026-03-15

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Infrastructure](#2-infrastructure)
3. [Backend Architecture (Laravel 11)](#3-backend-architecture-laravel-11)
4. [Database Schema (41 Tables)](#4-database-schema-41-tables)
5. [API Endpoints (62)](#5-api-endpoints-62)
6. [DIPODDI Programme System](#6-dipoddi-programme-system)
7. [5-Zone Intensity System](#7-5-zone-intensity-system)
8. [Session Structure & Periodization](#8-session-structure--periodization)
9. [Match-Day & Pre-Match Logic](#9-match-day--pre-match-logic)
10. [iOS App Architecture (SwiftUI)](#10-ios-app-architecture-swiftui)
11. [Trilingual Localization (EN/FR/AR)](#11-trilingual-localization-enfrar)
12. [Security Architecture](#12-security-architecture)
13. [Admin Panel (Filament 3.x)](#13-admin-panel-filament-3x)
14. [Seeders & Data Inventory](#14-seeders--data-inventory)
15. [User Journey Flows](#15-user-journey-flows)
16. [Workout Plan Generation Algorithm](#16-workout-plan-generation-algorithm)
17. [Pre-Change Checklist](#17-pre-change-checklist)
18. [Post-Change Checklist](#18-post-change-checklist)
19. [Production Deployment Checklist](#19-production-deployment-checklist)

---

## 1. System Overview

```
+-------------------+       HTTPS/TLS        +---------------------------+
|                   |  ===================>   |     PRODUCTION SERVER     |
|   iOS App         |  Bearer Token + AppKey  |                           |
|   (SwiftUI)       |  <==================   |   Nginx (Reverse Proxy)   |
|                   |   JSON Responses        |         :80               |
+-------------------+                         +----------+----------------+
       |                                                 |
       | Keychain (token)                                | proxy_pass
       | SSL Pinning                                     v
       |                                      +---------------------------+
       |                                      |   Laravel 11 (PHP 8.3)    |
       |                                      |   Sanctum Auth            |
       |                                      |   Filament Admin Panel    |
       |                                      +----------+----------------+
       |                                                 |
       |                                                 | Eloquent ORM
       |                                                 v
       |                                      +---------------------------+
       |                                      |   MySQL 8.0               |
       |                                      |   41 tables               |
       |                                      |   dipodi_api database     |
       +--------------------------------------+---------------------------+
```

### Tech Stack Summary

| Layer       | Technology                    | Version |
|-------------|-------------------------------|---------|
| iOS App     | SwiftUI + Combine             | iOS 17+ |
| Backend     | Laravel                       | 11.x    |
| PHP         | PHP-FPM                       | 8.3     |
| Database    | MySQL                         | 8.0     |
| Auth        | Laravel Sanctum               | 4.x     |
| Admin Panel | Filament                      | 3.x     |
| Web Server  | Nginx                         | Alpine  |
| Container   | Docker Compose                | 3.x     |
| HealthKit   | Apple HealthKit               | Latest  |

---

## 2. Infrastructure

### Docker Compose (Development)

| Service  | Image / Build    | Port       | Purpose            |
|----------|------------------|------------|--------------------|
| `app`    | Dockerfile (PHP) | internal   | Laravel app (FPM)  |
| `nginx`  | nginx:alpine     | 8000:80    | Reverse proxy      |
| `mysql`  | mysql:8.0        | 3306:3306  | Database           |

- **Network:** `dipodi-network` (bridge)
- **Volume:** `dipodi-mysql-data` (persistent)
- **Container name:** `dipodi-app`
- **PHP Extensions:** pdo_mysql, redis, intl, opcache, bcmath, zip, gd
- **User:** `dipodi` (non-root)

### File Locations

| Component     | Path                                          |
|---------------|-----------------------------------------------|
| Backend       | `/private/var/www/dipodi-api/`                |
| iOS App       | `/private/var/www/xcode app/FootballApp/`     |
| Docker mount  | `/var/www/` (inside container)                |

### Production (Sliplane)

| Setting          | Value                                       |
|------------------|---------------------------------------------|
| Platform         | Sliplane (Docker-based PaaS)                |
| Domain           | `https://dipodi-api.sliplane.app`           |
| Custom domain    | `https://api.dipoddi.com` (when configured) |
| Dockerfile       | Single-container: PHP-FPM + Nginx + Supervisord |
| Health check     | `/health` → `{"status":"ok"}`               |
| Startup script   | `docker/start.sh` (generates .env, migrates, caches, starts) |
| SSL              | Automatic via Sliplane                      |
| Env vars         | Set in Sliplane service settings            |
| Database         | Sliplane MySQL addon or external            |

### Production Deployment Flow

```
git push origin main
    │
    v
Sliplane auto-deploys (webhook on main branch)
    │
    v
Docker build (Dockerfile)
    ├── Install system deps + PHP extensions
    ├── composer install --no-dev --no-scripts
    ├── Copy app code + run package:discover
    └── Set permissions
    │
    v
Container starts (docker/start.sh)
    ├── [1/6] Generate .env from Docker env vars
    ├── [2/6] Generate APP_KEY if missing
    ├── [3/6] Set storage permissions
    ├── [4/6] Run migrations (non-destructive)
    ├── [5/6] Cache config/routes/views
    └── [6/6] Start Supervisord → Nginx + PHP-FPM
    │
    v
Health check passes → Service live
```

---

## 3. Backend Architecture (Laravel 11)

### Directory Structure

```
dipodi-api/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/          # 19 API controllers
│   │   ├── Controllers/Auth/         # 8 web auth controllers
│   │   ├── Middleware/               # 12 middleware classes
│   │   └── Requests/                 # Form request validators
│   ├── Models/                       # 34 Eloquent models
│   ├── Services/
│   │   ├── Workout/
│   │   │   ├── WorkoutPlanGenerator.php
│   │   │   ├── MatchAwarePlanGenerator.php
│   │   │   └── FeedbackAdjustmentService.php
│   │   ├── Nutrition/
│   │   │   └── NutritionPlanGenerator.php
│   │   └── Export/
│   │       └── WorkoutPlanPdfExporter.php
│   ├── Filament/Admin/Resources/     # 27+ admin panel resources
│   └── Helpers/
│       └── ApiResponse.php           # Standardized JSON responses
├── database/
│   ├── migrations/                   # 41 migration files
│   └── seeders/                      # 27 seeder files
├── routes/
│   ├── api.php                       # 50+ API endpoints
│   └── web.php                       # Admin/web routes
└── docker-compose.yml
```

### All Models (34)

#### User & Profile

| Model | Table | Key Fields | Relationships |
|-------|-------|------------|---------------|
| `User` | users | name, email, password, role | hasOne(UserProfile), hasMany(WorkoutSessions, UserGoals, UserProgress, FeedbackSessions, HealthAssessmentSessions, WorkoutFeedbacks), belongsToMany(Achievements, Exercises) |
| `UserProfile` | user_profiles | 50+ fields (discipline, position, training_days[], nutrition prefs...) | belongsTo(User) |
| `PlayerProfile` | player_profiles | name, group, description | belongsToMany(WorkoutThemes) |

#### Workout System

| Model | Table | Key Fields | Relationships |
|-------|-------|------------|---------------|
| `WorkoutSession` | workout_sessions | user_id, day, theme, warmup, finisher, metadata(JSON) | belongsTo(User), hasMany(WorkoutSessionExercises) |
| `WorkoutSessionExercise` | workout_session_exercises | name, sets, reps, recovery, video_url | belongsTo(WorkoutSession) |
| `WorkoutTheme` | workout_themes | name, type, zone_color, display_name, quality_method, sort_order | hasOne(WorkoutThemeRule), belongsToMany(PlayerProfiles) |
| `WorkoutThemeRule` | workout_theme_rules | 26 fields (exercise_count, sets, reps, rpe, mets, freshness_24h/48h/72h, supercomp_window, gain_prediction, injury_risk...) | belongsTo(WorkoutTheme) |
| `Exercise` | exercises | name, category, sub_category, video_url, description, met_value | belongsToMany(Users) |
| `WorkoutFeedback` | workout_feedbacks | difficulty_rating, energy_level, enjoyment_rating, muscle_soreness, sore_areas, notes | belongsTo(User, WorkoutSession) |

#### Training Configuration

| Model | Table | Key Fields | Relationships |
|-------|-------|------------|---------------|
| `TrainingDayLogic` | training_day_logic | total_days, theme_principal_count, theme_random_count | — |
| `BonusWorkoutRule` | bonus_workout_rules | level, type, rules | — |
| `HomeWorkoutRule` | home_workout_rules | player_profile_id, objective, circuit_config | belongsTo(PlayerProfile) |
| `IntensityZone` | intensity_zones | color, name_en/fr/ar, intensity_range, rpe_min/max, description | — |

#### Nutrition

| Model | Table | Key Fields | Notes |
|-------|-------|------------|-------|
| `FoodItem` | food_items | name, category, tags[], h_plus_1_energy, h_plus_24_recovery, meal_timing | Sport timing data |
| `NutritionAdvice` | nutrition_advice | condition_name, foods_to_avoid[], foods_to_eat[], prophetic_advice_fr/en/ar | Condition-specific |

#### Goals & Achievements

| Model | Table | Key Fields | Notes |
|-------|-------|------------|-------|
| `UserGoal` | user_goals | goal_type, target, current, start_date, end_date, status | calculateProgress(), isOnTrack() |
| `Achievement` | achievements | key, name_en/fr/ar, description_en/fr/ar, icon, points, category | Trilingual |
| — | user_achievements | user_id, achievement_id, earned_at | Pivot table |

#### Feedback & Assessment

| Model | Table | Key Fields | Notes |
|-------|-------|------------|-------|
| `FeedbackSession` | feedback_sessions | user_id, category_id, session_uuid, status, insights | generateInsights() |
| `FeedbackCategory` | feedback_categories | key, name_en/fr/ar, discipline, position, goal | getRelevantForUser() |
| `FeedbackQuestion` | feedback_questions | question_en/fr/ar, answer_type, answer_options | getLocalizedQuestion() |
| `FeedbackAnswer` | feedback_answers | session_id, question_id, answer_value | getNumericValue() |
| `HealthAssessmentSession` | health_assessment_sessions | Same pattern as FeedbackSession | generateRecommendations() |
| `HealthAssessmentCategory` | health_assessment_categories | Cardiovascular, Respiratory, etc. | — |
| `HealthAssessmentQuestion` | health_assessment_questions | Trilingual with subcategories | — |
| `HealthAssessmentAnswer` | health_assessment_answers | session_id, question_id, answer_value | isPositive() |

#### Sleep & Recovery

| Model | Table | Key Fields |
|-------|-------|------------|
| `SleepProtocol` | sleep_protocols | condition_key, cycles_min/max, total_sleep, objective_en/fr/ar |
| `Chronotype` | chronotypes | 4 types: Lion/Bear/Wolf/Dolphin with trilingual descriptions |

#### Content & System

| Model | Table | Key Fields |
|-------|-------|------------|
| `Post` | posts | title_en/fr/ar, content_en/fr/ar, slug, featured_image, is_published |
| `PropheticRemedy` | prophetic_remedies | condition_key, element_name, mechanism, recipe_en/fr/ar |
| `Interest` | interests | name (Nutrition, Workout, Recovery, etc.) |
| `OnboardingOption` | onboarding_options | type, value, label |
| `PushNotification` | push_notifications | title, body, scheduled_at, status, target_users[] |
| `UserReminderSetting` | user_reminder_settings | breakfast/lunch/dinner/workout times + enabled flags |

### API Controllers (19)

| # | Controller | Methods | Purpose |
|---|-----------|---------|---------|
| 1 | `AuthController` | register, login, logout, forgotPassword | Authentication |
| 2 | `SocialAuthController` | login | Google/Facebook/Apple OAuth |
| 3 | `UserProfileController` | show, update | User profile CRUD |
| 4 | `OnboardingController` | getOnboardingData | Dropdown options |
| 5 | `WorkoutPlanController` | generate, getWeeklyPlan, logProgress, getProgress | Workout lifecycle |
| 6 | `NutritionPlanController` | generate | Personalized nutrition |
| 7 | `KineController` | index, favorites, toggleFavorite | Physiotherapy exercises |
| 8 | `DashboardController` | getMetrics | Aggregated metrics |
| 9 | `GoalController` | index, active, store, show, updateProgress, updateStatus | Goal CRUD |
| 10 | `AchievementController` | index, earned, show, leaderboard | Achievements |
| 11 | `FeedbackController` | categories, questions, submit, history, stats, session | Session feedback |
| 12 | `WorkoutFeedbackController` | questions, submit, history, recommendation | Post-workout feedback |
| 13 | `HealthAssessmentController` | categories, questions, fullAssessment, startSession, submit, history, session, insights | Health questionnaire |
| 14 | `SleepController` | protocols, chronotypes, calculate | Sleep science |
| 15 | `PropheticMedicineController` | index, show | Natural remedies |
| 16 | `IntensityZoneController` | index | 5-zone system |
| 17 | `PostController` | index, show, latest | Blog posts |
| 18 | `SettingsController` | getReminders, updateReminders | User settings |
| 19 | `ExportController` | pdf, html | Workout plan export |

### Services (Business Logic)

#### WorkoutPlanGenerator (`app/Services/Workout/`)
- Generates personalized weekly workout plans
- Matches user's `PlayerProfile` to `WorkoutThemes` via percentage allocations
- Zone-aware scheduling: avoids consecutive high-fatigue zones (freshness_24h < 0.5)
- Uses `TrainingDayLogic` for principal vs random theme distribution
- Calculates Foster Load: RPE x Duration (minutes)
- Saves 14-field session metadata (see [Section 6](#6-dipoddi-programme-system))

#### MatchAwarePlanGenerator (`app/Services/Workout/`)
- Generates match-aware weekly schedule
- Day types: T_HIGH_INTENSITY, T_STRENGTH, T_MATCH, T_RECOVERY, T_REST, T_MOBILITY
- Pre-match: lighter intensity themes
- Post-match: recovery-focused sessions

#### NutritionPlanGenerator (`app/Services/Nutrition/`)
- Harris-Benedict formula for BMR
- Activity level multiplier for TDEE
- Goal-based calorie adjustment (deficit/surplus/maintenance)
- Macro split: protein, carbs, fats
- Meal distribution based on `meals_per_day`
- Food selection matching dietary preferences

#### FeedbackAdjustmentService (`app/Services/Workout/`)
- Analyzes post-workout feedback (difficulty, energy, soreness)
- Methods: `averageDifficultyForTheme()`, `getRecommendation()`
- Recommends: increase/decrease intensity, add/reduce exercises

#### WorkoutPlanPdfExporter (`app/Services/Export/`)
- Exports weekly workout plan as PDF/HTML

### Middleware Stack

| Middleware | Purpose | Applied To |
|-----------|---------|------------|
| `auth:sanctum` | Bearer token validation | All protected routes |
| `VerifyAppKey` | X-App-Key SHA-256 hash check | All API routes |
| `SetLocaleFromHeader` | Sets locale from Accept-Language | All API routes |
| `ForceHttps` | Redirects HTTP→HTTPS | Production only |
| `throttle:auth` | 5 requests/min | Login, register |
| `throttle:api` | 60 requests/min | Standard endpoints |
| `throttle:heavy` | 10 requests/min | Plan generation, export |

### Response Format

All API responses use `ApiResponse` helper:

```json
{
  "success": true,
  "message": "Workout plan generated successfully",
  "data": { ... }
}
```

---

## 4. Database Schema (41 Tables)

### Entity Relationship Diagram

```
users (1) ──────► (1) user_profiles
  │                      │
  │                      ├── discipline (FOOTBALL/PADEL/FITNESS)
  │                      ├── position → maps to player_profiles.name
  │                      ├── training_days[] (JSON: ["LUN","MAR","JEU"])
  │                      ├── training_location (MUSCULATION_EN_SALLE/MAISON/DEHORS/MIXED)
  │                      └── 45+ nutrition/health/body fields
  │
  ├──► (N) workout_sessions ──► (N) workout_session_exercises
  │              │
  │              └── metadata JSON {14 fields - see Section 6}
  │
  ├──► (N) user_goals
  ├──► (N) user_achievements ──► achievements (30+)
  ├──► (N) user_progress (daily weight/measurements/mood)
  ├──► (N) feedback_sessions ──► feedback_answers
  ├──► (N) health_assessment_sessions ──► health_assessment_answers
  ├──► (N) workout_feedbacks
  ├──► (1) user_reminder_settings
  └──► (N) user_favorite_exercises ──► exercises (451)

player_profiles (36) ──► player_profile_themes (721) ──► workout_themes (76)
                              (percentage allocation)            │
                                                                 └──► workout_theme_rules (76)
                                                                       (1:1 - sets, reps, RPE,
                                                                        freshness, METs, etc.)

workout_themes ──► intensity_zones (5: blue/green/yellow/orange/red)

player_profiles ──► home_workout_rules (72: 36 profiles × 2 objectives)

training_day_logic (7 rows) — distribution rules for 1-7 training days

feedback_categories ──► feedback_questions
health_assessment_categories ──► health_assessment_questions

sleep_protocols (9 conditions)
chronotypes (4: Lion/Bear/Wolf/Dolphin)
prophetic_remedies (10 conditions, 45+ remedies)
food_items (200+ with H+1/H+24 sport timing)
nutrition_advice (condition-based dietary guidance)
exercises (451: MUSCULATION 114, MAISON 121, BONUS 134, KINE 65, CARDIO 17)
posts (trilingual blog)
interests, onboarding_options, push_notifications
```

### Table Groups

#### User & Profile (5 tables)

| Table | Rows | Key Columns |
|-------|------|-------------|
| `users` | dynamic | email, password(hashed), role(admin/coach/manager/user) |
| `user_profiles` | 1:1 with user | 50+ profile fields (see onboarding) |
| `user_progress` | daily entries | weight, waist, chest, hips, mood, notes |
| `user_reminder_settings` | 1:1 | breakfast/lunch/dinner/workout times + enabled |
| `personal_access_tokens` | per session | Sanctum tokens, 30-day expiry |

#### Workout System (10 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `player_profiles` | 36 | Football/Padel/Fitness archetypes |
| `workout_themes` | 76 | 19 gym + 54 cardio + 2 home + 1 mobility |
| `player_profile_themes` | 721 | Profile-to-theme percentage allocation (pivot) |
| `workout_theme_rules` | 76 | 1:1 with themes — sets/reps/RPE/freshness/METs |
| `exercises` | 451 | Exercise library with video URLs & MET values |
| `workout_sessions` | dynamic | Generated user workout plans (7/week) |
| `workout_session_exercises` | dynamic | Exercises within sessions |
| `bonus_workout_rules` | ~20 | Extra rules by level/type |
| `home_workout_rules` | 72 | Circuit params per profile × 2 objectives |
| `training_day_logic` | 7 | Principal vs random theme distribution |

#### Intensity & Recovery (3 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `intensity_zones` | 5 | Blue/Green/Yellow/Orange/Red with trilingual data |
| `sleep_protocols` | 9 | Condition-based sleep recommendations |
| `chronotypes` | 4 | Lion/Bear/Wolf/Dolphin profiles |

#### Nutrition (2 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `food_items` | 200+ | Foods with sport timing (H+1 energy, H+24 recovery) |
| `nutrition_advice` | 20+ | Condition-based dietary guidance |

#### Feedback & Assessment (8 tables)

| Table | Purpose |
|-------|---------|
| `feedback_categories` | Categories (position/goal-specific, trilingual) |
| `feedback_questions` | Questions per category (trilingual) |
| `feedback_sessions` | Session tracking with insights |
| `feedback_answers` | Individual user answers |
| `health_assessment_categories` | Health categories (Cardio, Respiratory, etc.) |
| `health_assessment_questions` | Health questions with subcategories |
| `health_assessment_sessions` | Sessions with recommendations |
| `health_assessment_answers` | Individual health answers |

#### Goals & Achievements (3 tables)

| Table | Purpose |
|-------|---------|
| `user_goals` | Fitness/lifestyle/nutrition goals with progress tracking |
| `achievements` | 30+ achievement definitions (trilingual, with points) |
| `user_achievements` | Pivot: user earned achievements with timestamps |

#### Content & System (7 tables)

| Table | Purpose |
|-------|---------|
| `posts` | Trilingual blog posts |
| `prophetic_remedies` | 45+ natural medicine remedies for 10 conditions |
| `interests` | User interest categories |
| `onboarding_options` | Dropdown options for onboarding forms |
| `push_notifications` | Scheduled notification management |
| `workout_feedbacks` | Post-workout difficulty/energy/soreness ratings |
| `user_favorite_exercises` | Pivot: user's kine favorites |

---

## 5. API Endpoints (62)

### Authentication (Rate: 5/min)

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | `/api/auth/register` | No | Create account |
| POST | `/api/auth/login` | No | Login, get token |
| POST | `/api/auth/forgot-password` | No | Password reset email |
| POST | `/api/auth/{provider}/login` | No | Social OAuth (google/facebook/apple) |
| POST | `/api/auth/logout` | Yes | Revoke current token |
| POST | `/api/auth/logout-all` | Yes | Revoke all tokens (all devices) |
| PUT | `/api/auth/password` | Yes | Change password (requires current_password) |
| GET | `/api/auth/me` | Yes | Get authenticated user info (auth status check) |

### User & Profile (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/user` | Get current user + profile |
| PUT | `/api/user/profile` | Update profile fields |
| GET | `/api/onboarding-data` | Onboarding dropdown options (public) |

### Workout (Rate: 10/min for generate/export)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/workout-plan/generate` | Generate weekly workout plan |
| GET | `/api/workout-plan` | Retrieve current plan (cached) |
| GET | `/api/export/workout-plan/pdf` | Export plan as PDF |
| GET | `/api/export/workout-plan/html` | Export plan as HTML |

### Progress (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/user-progress` | Log daily progress (weight, measurements) |
| GET | `/api/user-progress` | Progress history |

### Nutrition (Rate: 10/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/nutrition-plan` | Personalized meal plan (cached) |

### Kine / Physiotherapy (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/kine-data` | Exercise library by body part |
| GET | `/api/kine-favorites` | User's favorite exercises |
| POST | `/api/kine-favorites/toggle` | Toggle exercise favorite |

### Goals (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/goals` | List all goals |
| GET | `/api/goals/active` | Get active goal |
| POST | `/api/goals` | Create new goal |
| GET | `/api/goals/{id}` | Goal details |
| POST | `/api/goals/{id}/progress` | Log goal progress |
| PUT | `/api/goals/{id}/status` | Update goal status |

### Achievements (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/achievements` | All achievements |
| GET | `/api/achievements/earned` | User's earned |
| GET | `/api/achievements/leaderboard` | Points leaderboard |
| GET | `/api/achievements/{id}` | Achievement detail |

### Feedback (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/feedback/categories` | Available categories |
| GET | `/api/feedback/questions/{category}` | Questions for category |
| POST | `/api/feedback/submit` | Submit feedback session |
| GET | `/api/feedback/history` | Feedback history |
| GET | `/api/feedback/stats` | Feedback statistics |
| GET | `/api/feedback/sessions/{id}` | Session details |

### Post-Workout Feedback (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/workout-feedback/questions` | Post-workout questions |
| POST | `/api/workout-feedback` | Submit workout feedback |
| GET | `/api/workout-feedback/history` | Workout feedback history |
| GET | `/api/workout-feedback/recommendation/{theme}` | AI-adjusted recommendations |

### Health Assessment (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health-assessment/categories` | Assessment categories |
| GET | `/api/health-assessment/questions/{category}` | Category questions |
| GET | `/api/health-assessment/full` | All questions at once |
| POST | `/api/health-assessment/start` | Start new session |
| POST | `/api/health-assessment/submit` | Submit answers |
| GET | `/api/health-assessment/history` | Past assessments |
| GET | `/api/health-assessment/insights` | Health insights |
| GET | `/api/health-assessment/sessions/{id}` | Session details |

### Sleep & Recovery (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/sleep/protocols` | Sleep protocols by condition |
| GET | `/api/sleep/chronotypes` | 4 chronotype profiles |
| GET | `/api/sleep/calculate` | Bedtime calculator |

### Prophetic Medicine (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/prophetic-medicine` | List conditions |
| GET | `/api/prophetic-medicine/{key}` | Remedies for condition |

### Account / GDPR (Rate: 60/min)

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| GET | `/api/privacy` | No | Privacy policy & terms URLs, data retention info |
| GET | `/api/account/export` | Yes | Export all user data (GDPR Art. 15/20 — Right of Access / Data Portability) |
| DELETE | `/api/account` | Yes | Delete account & all data (GDPR Art. 17 — Right to Erasure). Requires `password` + `confirmation: "DELETE"` |

### Other (Rate: 60/min)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/intensity-zones` | 5 training intensity zones |
| GET | `/api/dashboard-metrics` | Dashboard aggregated data |
| GET | `/api/posts` | Blog posts (paginated) |
| GET | `/api/posts/latest` | Latest blog posts |
| GET | `/api/posts/{slug}` | Single blog post |
| GET/PUT | `/api/settings/reminders` | Reminder settings |

---

## 6. DIPODDI Programme System

### Workout Session Metadata (14 Fields)

Every training session stores a `metadata` JSON column with these 14 fields:

```json
{
    "zone_color": "orange",
    "display_name": "Definition du Muscle",
    "quality_method": "Seche / Definition",
    "rpe": 6,
    "mets": "7.3",
    "estimated_load": 450,
    "sleep_recommendation": "8h30",
    "hydration_recommendation": "1.25L",
    "is_principal_theme": true,
    "supercomp_window": "48h",
    "gain_prediction": "Qualite visuelle / Tonicite",
    "injury_risk": "Faible",
    "freshness_24h": "0.65",
    "weekly_load_so_far": 450
}
```

**Critical implementation detail:** The `WorkoutSession` model has `'metadata' => 'array'` cast. The `WorkoutPlanGenerator` must pass metadata as a raw PHP array — NOT `json_encode()` it — because Laravel auto-encodes on save. Double-encoding was a past bug (fixed 2026-03-15).

### iOS Metadata Struct

```swift
struct WorkoutSessionMetadata: Codable {
    let zoneColor: String?
    let displayName: String?
    let qualityMethod: String?
    let rpe: AnyCodableValue?
    let mets: AnyCodableValue?
    let estimatedLoad: AnyCodableValue?
    let sleepRecommendation: String?
    let hydrationRecommendation: String?
    let isPrincipalTheme: Bool?
    let supercompWindow: String?
    let gainPrediction: String?
    let injuryRisk: String?
    let freshness24h: AnyCodableValue?
    let weeklyLoadSoFar: AnyCodableValue?
}
```

**All 14 backend JSON keys map 1:1 to iOS struct fields via `keyDecodingStrategy: .convertFromSnakeCase`.**

### Workout Themes (76 Total)

#### Gym Themes (19)

| ID | Name | Display Name | Zone | Quality Method | Sort |
|----|------|-------------|------|----------------|------|
| 1 | Force maximale | Le Blindage | red | Force maximale | 1 |
| 2 | Force sous-maximale | L'Armure Fonctionnelle | orange | Force sous-maximale | 2 |
| 3 | Force dynamique | Vitesse de Contraction | red | Force dynamique | 3 |
| 4 | Force explosive | Le Premier Pas (Explo) | red | Force explosive | 4 |
| 5 | Puissance musculaire | Impact & Frappe de Balle | red | Puissance musculaire | 5 |
| 6 | Hypertrophie myofibrillaire | Densite Musculaire | orange | Hypertrophie Myo. | 6 |
| 7 | Hypertrophie sarcoplasmique | Protection des Chocs | yellow | Hypertrophie Sarc. | 7 |
| 8 | Volume musculaire | Gros Gabarit | yellow | Volume Musculaire | 8 |
| 9 | Endurance de force | Repetition de Duels | orange | Endurance de Force | 9 |
| 10 | Endurance musculaire | Solidite Posturale | green | Endurance Muscu. | 10 |
| 11 | Perte de poids | Affutage Poids/Puissance | orange | Perte de Poids | 11 |
| 12 | Seche / definition musculaire | Definition du Muscle | orange | Seche / Definition | 12 |
| 13 | Condition physique generale | Socle Athletique | orange | Condition (GPP) | 13 |
| 14 | Remise en forme | Reprise Douce | green | Remise en Forme | 14 |
| 15 | Prevention des blessures | Anti-Blessures | blue | Prevention | 15 |
| 16 | Renforcement articulaire | Genoux d'Acier | blue | Renforcement articulaire | 16 |
| 17 | Reathletisation | Retour au Terrain | blue | Reathlétisation | 17 |
| 18 | Coordination / proprioception | Equilibre d'Appuis | blue | Coordination | 18 |
| 52 | Repetitions des efforts | Enchainement d'Actions | yellow | Repetition Efforts | 19 |

#### Cardio Themes (54)

Distributed across all 5 zones: blue(9), green(12), orange(8), red(12), yellow(13).

Key cardio categories:
- **Endurance:** Endurance aerobie, Capacite aerobie, LSD, Zone 2, Endurance fondamentale (courte/moyenne/longue)
- **Intermittent:** 5/5, 10/10-15/15, 20/20-30/30, 45/45-1'/1'
- **HIIT variants:** HIIT, HIIT long, Tabata, SIT, Endurance HIIT
- **Speed:** Vitesse pure, Vitesse repetee (RSA), RHIE
- **Threshold:** Seuil SV1, Seuil SV2, Tempo run
- **Fartlek:** Court, Moyen, Long, Continu
- **Power:** Puissance explosive, Puissance anaerobie, Cotes puissance/endurance
- **Recovery:** Recuperation active, Fartlek long

#### Home Themes (2)

| ID | Name | Zone |
|----|------|------|
| 22 | Circuit Maison | yellow |
| 23 | HIIT Maison | orange |

#### Mobility Theme (1)

| ID | Name | Zone |
|----|------|------|
| 24 | Mobilite & Recuperation | blue |

### Player Profiles (36)

#### Football (16 profiles, 4 groups)

| Group | Profiles |
|-------|----------|
| GARDIEN (4) | La Panthere, La Pieuvre, Le Chat, L'Araignee |
| DEFENSEUR (4) | Le Controleur, Le Casseur, Le Relanceur, Le Polyvalent |
| MILIEU (4) | L'Architecte, The Rock, Le Pitbull, La Gazelle |
| ATTAQUANT (4) | Le Magicien, Le Sniper, Le Tank, Le Renard |

#### Padel (10 profiles, 6 groups)

| Group | Profiles |
|-------|----------|
| PADEL_DROITE (3) | Le Metronome, Le Marathonien, Le Stresse |
| PADEL_GAUCHE (3) | Le Smasheur, L'Aerien, Le Joueur Lourd |
| PADEL_DEFENSE (1) | Le Defenseur |
| PADEL_PREVENTION (1) | Le Fragile |
| PADEL_SANTE (1) | Le Veteran |
| PADEL_TIMING (1) | Le Matinal |

#### Fitness (10 profiles, 2 groups)

| Group | Profiles |
|-------|----------|
| FITNESS_FEMME (5) | La Silhouette, La Tonique, La Fine, L'Athlete Puissante, Bien-etre |
| FITNESS_HOMME (5) | L'Athletique, Le Massif, Le Sec, Le Fonctionnel, Le Force Brute |

### Profile-Theme Mapping

- **721 total mappings** in `player_profile_themes` pivot table
- **0 unmapped themes** — all 76 themes are assigned to at least one profile
- Each mapping has a `percentage` weight used for weighted random selection
- Example: "Le Blindage" might be 25% for Le Tank (ATTAQUANT) but only 5% for La Gazelle (MILIEU)

---

## 7. 5-Zone Intensity System

| Zone | Color | Intensity | RPE | Recovery | Purpose | Freshness 24h |
|------|-------|-----------|-----|----------|---------|---------------|
| 1 | Blue | 50-60% | 1-3 | 24h | Active recovery, warm-up | 0.85-0.95 |
| 2 | Green | 60-70% | 3-5 | 24-48h | Endurance, fat oxidation | 0.70-0.85 |
| 3 | Yellow | 70-80% | 5-7 | 48h | Tempo, lactate threshold | 0.55-0.70 |
| 4 | Orange | 80-90% | 7-9 | 48-72h | VO2max, speed endurance | 0.40-0.60 |
| 5 | Red | 90-100% | 9-10 | 72h+ | Max power, neuromuscular | 0.25-0.45 |

### Zone Distribution (Current)

| Zone Color | Theme Count |
|------------|-------------|
| Blue | 14 |
| Green | 15 |
| Yellow | 16 |
| Orange | 16 |
| Red | 15 |

### Supercompensation Tracking

Each `workout_theme_rule` has freshness decay values:
- `freshness_24h`: Recovery fraction at 24 hours (0.00-1.00)
- `freshness_48h`: Recovery fraction at 48 hours
- `freshness_72h`: Recovery fraction at 72 hours

The `WorkoutPlanGenerator` uses these to avoid scheduling high-fatigue workouts on consecutive days when freshness_24h < 0.5.

### Trilingual Zone Names (DB: `intensity_zones`)

| Color | FR | EN | AR |
|-------|----|----|-----|
| Blue | Recuperation & Oxygenation | Recovery & Oxygenation | التعافي والأكسجة |
| Green | Endurance Fondamentale & Zone 2 | Fundamental Endurance & Zone 2 | التحمل الأساسي والمنطقة 2 |
| Yellow | Rythme Match & Intermittence | Match Rhythm & Intermittence | إيقاع المباراة والتناوب |
| Orange | Haute Intensite & Resistance | High Intensity & Resistance | شدة عالية ومقاومة |
| Red | Intensite Maximale & Explosion | Maximum Intensity & Explosion | الشدة القصوى والانفجار |

---

## 8. Session Structure & Periodization

### Session Phase Structure

Every DIPODDI session follows a consistent phase structure with zone-appropriate intensities:

**Rule: Always start with mobility/renforcement, always end with bonus (abdos/gainage/pompes).**

#### Phase Template

| Phase | Duration | Zone | Purpose |
|-------|----------|------|---------|
| 1. Echauffement | 5-20 min | Blue/Green | Progressive warm-up (cardio + mobilite articulaire) |
| 2. Activation | 5 min | Green | Neuromuscular activation |
| 3. Corps de seance | 20-35 min | Session's dominant zone | Main training block |
| 4. Accelerations/Bloc | 5-10 min | Yellow-Red (optional) | Intensity peak (if applicable) |
| 5. Retour au calme | 5 min | Blue | Cool-down, stretching |
| 6. Partie Bonus | 5-10 min | Blue/Green | Abdos, gainage, pompes |

#### Session Examples by Dominant Zone

**Green Session (Zone 2 dominant):**
```
Phase          | Duration | Zone
Echauffement   | 15 min   | Blue
Activation     | 5 min    | Green
Corps de seance| 30 min   | Green
Accelerations  | 5 min    | Yellow
Retour au calme| 5 min    | Blue
```

**Orange Session (Zone 4 dominant):**
```
Phase            | Duration | Zone
Echauffement     | 15 min   | Green
Travail resistance| 20 min  | Orange
Rappel de vitesse| 5 min    | Red
Recuperation     | 20 min   | Blue
```

**Blue Session (Recovery):**
```
Phase          | Duration | Zone
Mise en train  | 20 min   | Blue
Travail de fond| 35 min   | Green
Retour au calme| 5 min    | Blue
```

### Warmup Intensity by Zone (Implemented)

The `WorkoutPlanGenerator.getZoneAwareWarmup()` matches warmup to session intensity:

| Session Zone | Warmup Duration | Warmup Content |
|-------------|----------------|----------------|
| Red | 15 min | Cardio → mobilite → activation neuromusculaire → montees en charge |
| Orange | 12 min | Cardio leger → mobilite dynamique → activation musculaire |
| Yellow | 10 min | Cardio leger + mobilite articulaire |
| Green | 8 min | Marche rapide + mobilite |
| Blue | 5 min | Echauffement leger |

### Bonus Finisher (Implemented)

Every session ends with a **Partie Bonus** based on user level:

| Level | ABDOS | POMPES | GAINAGE |
|-------|-------|--------|---------|
| DEBUTANT | 3×12, 45s rest | 3×10, 45s rest | 3×20s, 45s rest |
| INTERMEDIAIRE | 4×30, 30s rest | 4×20, 30s rest | 4×45s, 30s rest |
| AVANCE | 5×40, 20s rest | 5×30, 20s rest | 5×1min, 20s rest |

### Weekly Periodization

#### Zone Distribution Across the Week

Each day has a **dominant zone** with supporting zones:

**Example Week 1 (Low intensity — 60%):**
```
Jour      | Dominant | Distribution
Lundi     | Green    | Blue 20% | Green 80%
Mardi     | Yellow   | Blue 20% | Green 40% | Yellow 40%
Mercredi  | Blue     | Blue 100% (Recovery)
Jeudi     | Green    | Blue 15% | Green 85%
Vendredi  | Orange   | Blue 20% | Green 50% | Orange 30%
Samedi    | Green    | Blue 10% | Green 90%
Dimanche  | Repos    | -
```

**Example Week 2 (Medium intensity — 80%):**
```
Jour      | Dominant | Distribution
Lundi     | Green    | Blue 30% | Green 70%
Mardi     | Orange   | Blue 20% | Green 40% | Orange 40%
Mercredi  | Green    | Blue 20% | Green 80%
Jeudi     | Red      | Blue 30% | Green 40% | Red 30%
Vendredi  | Blue     | Blue 100%
Samedi    | Yellow   | Blue 10% | Green 40% | Yellow 50%
Dimanche  | Repos    | -
```

**Example Week 3 (High intensity — 100%):**
```
Jour      | Dominant | Distribution
Lundi     | Orange   | Blue 20% | Green 30% | Orange 50%
Mardi     | Red      | Blue 40% | Green 20% | Red 40%
Mercredi  | Blue     | Blue 100%
Jeudi     | Orange   | Blue 20% | Green 30% | Orange 50%
Vendredi  | Red      | Blue 40% | Green 10% | Red 50%
Samedi    | Blue     | Blue 100%
Dimanche  | Repos    | -
```

#### Key Weekly Rules (Implemented)

- Alternate easy (cold) and hard (hot) days
- Never schedule two red/orange zone sessions on consecutive days (freshness_24h < 0.5)
- Zone-aware scheduling in `WorkoutPlanGenerator` enforces this via `usedZones[]` tracking

### Monthly Periodization (4-Week Mesocycle)

**Progressive overload with deload week:**

| Week | Intensity | Zone Distribution |
|------|-----------|-------------------|
| Week 1 | 60% | Blue 45% / Green 45% / Yellow 5% / Orange 5% / Red 0% |
| Week 2 | 80% | Blue 40% / Green 35% / Yellow 10% / Orange 10% / Red 5% |
| Week 3 | 100% | Blue 35% / Green 35% / Yellow 5% / Orange 15% / Red 10% |
| Week 4 | 40% (Deload) | Blue 50% / Green 50% / Yellow 0% / Orange 0% / Red 0% |

**Multi-scale planning:**

| Scale | Action | Strategy |
|-------|--------|----------|
| Day | Choose | Define a target zone color based on session objective |
| Week | Distribute | Alternate easy (cold) and hard (hot) days |
| Month | Vary | Increase intensity over 3 weeks, then 1 deload week |

> **Note:** Monthly periodization (4-week mesocycle) is documented as the target model. The current backend generates one week at a time. Multi-week progression tracking is a future enhancement.

### Training Day Logic (Implemented)

The `training_day_logic` table controls how many days are "principal" (from profile themes) vs "random":

| Training Days | Principal | Random | Alt Principal | Alt Random |
|--------------|-----------|--------|---------------|------------|
| 1 | 1 | 0 | - | - |
| 2 | 2 | 0 | - | - |
| 3 | 2 | 1 | - | - |
| 4 | 2 | 2 | 3 | 1 |
| 5 | 3 | 2 | 4 | 1 |
| 6 | 3 | 3 | 4 | 2 |
| 7 | 4 | 3 | 5 | 2 |

- **Principal days**: Theme selected from user's profile weighted distribution
- **Random days**: Any theme of the correct type (gym/cardio/home) selected randomly
- The "Alt" columns provide an alternative split option

---

## 9. Match-Day & Pre-Match Logic

### Who This Applies To

- **Football players in a club** (has match day set)
- **Padel players** (has match day set)
- **Fitness / no-club users**: No match-day constraints — free scheduling

### Match Week Schedule (Implemented)

When a user has a match day (e.g., SAMEDI), the `MatchAwarePlanGenerator` automatically structures the week:

```
J-3+: Normal training (high_intensity or strength)
J-2:  Mobility & Recovery session (mobilite, blue zone)
J-1:  Pre-Match BONUS ONLY (abdos/gainage/pompes, skip rope optional)
       ⚠ NO gym, NO cardio salle, NO outdoor cardio, NO musculation
J:    MATCH DAY (red zone, RPE 9)
J+1:  Recovery (recuperation active, blue zone, KINE MOBILITE exercises)
J+2+: Normal training resumes
```

### Session Types (MatchAwarePlanGenerator Constants)

| Type | Constant | When | What Happens |
|------|----------|------|-------------|
| `match` | T_MATCH | Match day | "Jour de Match", red zone, RPE 9 |
| `pre_match_bonus` | T_PRE_MATCH_BONUS | J-1 (24h before) | Bonus only (abdos/gainage/pompes), optional corde a sauter, blue zone, RPE 2 |
| `mobility` | T_MOBILITY | J-2 (48h before) | Mobilite & Recuperation, KINE exercises, blue zone, RPE 2 |
| `recovery` | T_RECOVERY | J+1 (day after) | Recuperation active, KINE MOBILITE exercises, blue zone, RPE 2 |
| `high_intensity` | T_HIGH_INTENSITY | Normal training | Full training session with selected theme |
| `strength` | T_STRENGTH | Near match (fallback) | Reduced intensity if within 2 days of match |
| `rest` | T_REST | Non-training days | "Repos" — no exercises |

### Example: Match SAMEDI, Training MAR/JEU

```
LUNDI:    rest
MARDI:    high_intensity (full training)
MERCREDI: rest
JEUDI:    mobility (J-2, light recovery)
VENDREDI: pre_match_bonus (J-1, bonus only)
SAMEDI:   match
DIMANCHE: recovery (post-match)
```

### Strength Day Intensity Reduction

When a training day falls within 2 days of a match, the generator:
1. Assigns type `T_STRENGTH` instead of `T_HIGH_INTENSITY`
2. Caps RPE at max 5 (reduces by 2 if > 7)
3. Reduces estimated load by 30% (`estimatedLoad * 0.7`)

### Implementation Files

- `MatchAwarePlanGenerator.php` — Weekly schedule generation with match awareness
- `WorkoutPlanGenerator.php:generateSessionForDay()` — Session content per day type
- `WorkoutPlanGenerator.php:getDynamicBonusFinisher()` — Level-based bonus content

---

## 10. iOS App Architecture (SwiftUI)

### Project Structure

```
FootballApp/
├── FootballAppApp.swift              # @main entry, ViewModels init
├── ContentView.swift                 # Root: splash → auth → onboarding → main
├── Info.plist                        # App config (DiPODDI, HealthKit, etc.)
├── FootballApp.entitlements          # HealthKit + Push Notifications
│
├── Design/                           # Design system (10 files)
│   ├── DesignSystem.swift            # Card, AppButton, AppTheme, FormRow
│   ├── DarkPurpleAnimatedBackground.swift  # Animated mesh gradient
│   ├── Color+Theme.swift             # Complete color palette (#7B61FF primary)
│   ├── ColorExtensions.swift         # Color utilities
│   ├── AppIconView.swift             # Logo component
│   ├── UIEnhancements.swift          # UI quality improvements
│   ├── UIStyles.swift                # Reusable style definitions
│   ├── View+OptionalTint.swift       # Tint extension
│   ├── AppMaterialEnvironment.swift  # Material design environment
│   └── SelectionOptionCard.swift     # Selection card component
│
├── Models/
│   ├── APIModels.swift               # 80+ Codable structs (70KB)
│   └── ViewModels/                   # 15 files
│       ├── AuthViewModel.swift       # appState, login/register/logout
│       ├── OnboardingViewModel.swift  # Multi-step onboarding data
│       ├── WorkoutsViewModel.swift   # Weekly plan, sessions
│       ├── WorkoutDetailViewModel.swift  # Single session detail
│       ├── NutritionViewModel.swift  # Meal plan, macros, water
│       ├── KineViewModel.swift       # Recovery exercises, favorites
│       ├── ProfileViewModel.swift    # Profile, reminders, progress, HealthKit
│       ├── BlogViewModel.swift       # Blog posts
│       ├── GoalsViewModel.swift      # Goal CRUD
│       ├── AchievementsViewModel.swift  # Achievements, leaderboard
│       ├── FeedbackViewModel.swift   # Feedback questionnaire
│       ├── HealthAssessmentViewModel.swift  # Health questionnaire
│       ├── SleepViewModel.swift      # Sleep protocols, chronotypes
│       ├── PropheticMedicineViewModel.swift  # Natural remedies
│       ├── KeychainService.swift     # Secure token storage
│       └── PlayerProfileModels.swift # Sport archetype definitions
│
├── Service/                          # Networking & platform (7 files)
│   ├── APIService.swift              # HTTP client (617 lines, async/await + Combine)
│   ├── APIConstants.swift            # URLs, endpoints, app key, SSL pins
│   ├── CacheManager.swift            # NSCache with TTL
│   ├── NetworkMonitor.swift          # NWPathMonitor (WiFi/Cellular)
│   └── HealthKitManager.swift        # 19+ health data types (766 lines)
│
├── Utilities/
│   └── YouTubeHelper.swift           # YouTube URL parsing
│
├── Localization/                     # Trilingual support
│   ├── LanguageManager.swift         # Runtime language switching
│   ├── String+Localization.swift     # .localized / .localizedString
│   ├── ErrorLogger.swift             # Error localization
│   ├── en.lproj/Localizable.strings
│   ├── fr.lproj/Localizable.strings
│   └── ar.lproj/Localizable.strings
│
└── Views/                            # 70+ view files
    ├── Auth/                         # Login, Register, ThemeManager
    ├── Onboarding/                   # 13 files (7-step flow)
    ├── Main/MainTabView.swift        # 5-tab navigation
    ├── Workout/                      # 5 files (plan, reels, feedback, theme/zone info)
    ├── Nutrition/                    # 2 files (plan, reels)
    ├── Kine/                         # 5 files (exercises, YouTube, explanations)
    ├── Blog/                         # Blog post list
    ├── Profile/                      # 5 files (profile, reminders, progress, measurements)
    ├── Goals/                        # Goal management
    ├── Achievements/                 # Achievement tracking
    ├── Feedback/                     # Session feedback
    ├── HealthAssessment/             # Health questionnaires
    ├── Sleep/                        # Sleep calculator & protocols
    ├── PropheticMedicine/            # Natural remedies
    ├── Components/                   # Reusable UI (buttons, cards)
    └── Debug/                        # API testing view (dev only)
```

### App State Machine

```
App Launch
    │
    v
ContentView: Check Keychain for token
    │
    ├── No token ──► .authentication ──► AuthView (Login / Register)
    │                                        │
    │                    POST /auth/register  │  POST /auth/login
    │                                        │
    │                    Store token ◄────────┘
    │                        │
    v                        v
Check is_onboarding_complete
    │
    ├── false ──► .onboarding ──► OnboardingFlow (7 steps)
    │                                 │
    │                    PUT /user/profile (save all)
    │                                 │
    v                                 v
    └── true ──► .mainApp ──► MainTabView (5 tabs)
```

### Tab Navigation

```
MainTabView (FloatingTabBar)
├── [1] Workout    (figure.run)     → WorkoutView
├── [2] Nutrition  (leaf.fill)      → NutritionView
├── [3] Kine       (waveform)       → KineView
├── [4] Blog       (book)           → BlogTabView
└── [5] Profile    (person.fill)    → ProfileView
         │
         ├── Sleep & Recovery (sheet)
         ├── Prophetic Medicine (sheet)
         ├── Goals (sheet)
         ├── Achievements (sheet)
         ├── Health Assessment (sheet)
         ├── Feedback (sheet)
         ├── Reminder Settings (push)
         ├── Progress Tracking (push)
         ├── Update Onboarding (push)
         └── Logout
```

### Data Flow (MVVM)

```
View (SwiftUI @StateObject/@EnvironmentObject)
    │
    v
ViewModel (@Published properties)
    │
    v
APIService.shared.request<T: Codable>()
    │
    ├── Authorization: Bearer {KeychainService.token}
    ├── X-App-Key: {AppKeyProvider.key}
    ├── Accept-Language: {LanguageManager.locale}
    │
    v
URLSession (with optional SSL pinning delegate)
    │
    v
JSON Response → Codable Struct → @Published property → View updates
```

### ViewModels Summary

| ViewModel | Key Published Props | Key Methods |
|-----------|-------------------|-------------|
| `AuthViewModel` | appState, currentUser, isLoading, errorMessage | login(), register(), logout(), checkAuth() |
| `WorkoutsViewModel` | workoutSessions, completedWorkouts, weeklySchedule | loadWorkoutPlan(), generatePlan(), markComplete() |
| `NutritionViewModel` | nutritionPlan, meals, caloriesConsumed/Target, waterGlasses | loadNutritionPlan() |
| `KineViewModel` | exercisesByCategory, favorites, selectedExercise | loadExercises(), toggleFavorite() |
| `ProfileViewModel` | reminderSettings, progressLogs, stepsToday, latestWeight | loadProfile(), updateReminders(), logProgress() |
| `OnboardingViewModel` | data (OnboardingData), options, heightWeightStep | loadOptions(), saveProfile() |
| `BlogViewModel` | posts, isLoading | loadPosts(), loadLatest() |
| `GoalsViewModel` | goals, activeGoal | createGoal(), updateProgress(), updateStatus() |
| `AchievementsViewModel` | achievements, earnedAchievements, leaderboard | loadAll(), loadEarned(), loadLeaderboard() |
| `FeedbackViewModel` | availableCategories, selectedCategory, responses | loadCategories(), submitFeedback() |
| `HealthAssessmentViewModel` | categories, currentSession, insights | startSession(), submitAnswers() |
| `SleepViewModel` | protocols, chronotypes | loadProtocols(), calculateBedtime() |
| `PropheticMedicineViewModel` | conditions, remedies | loadConditions(), loadRemedies() |

### HealthKit Integration (19+ data types)

Read access: steps, active/resting energy, distance, exercise time, heart rate, HRV, VO2 Max, oxygen saturation, walking speed, flights climbed, activity rings, sleep analysis, stand time

Write access: weight, waist circumference

### Design System

| Token | Value |
|-------|-------|
| Primary Purple | #7B61FF |
| Accent Teal | #82EEF8 |
| Spacing Small | 8pt |
| Spacing Medium | 16pt |
| Spacing Large | 24pt |
| Spacing XL | 32pt |
| Corner Radius | 16pt (cards), 12pt (buttons) |
| Background | Animated dark purple mesh gradient |

---

## 11. Trilingual Localization (EN/FR/AR)

### Backend Approach

| Content Type | Approach |
|-------------|----------|
| Database fields | Separate columns: `name_fr`, `name_en`, `name_ar` |
| Model accessors | `getNameAttribute()` returns based on `app()->getLocale()` |
| API responses | Single `name` field (server resolves from locale) |
| Locale detection | `Accept-Language` header → `SetLocaleFromHeader` middleware |
| Default locale | `en` (English), fallback: `en` |
| JSON lang files | `lang/en.json`, `lang/fr.json`, `lang/ar.json` — 113+ keys for auth, validation, API messages |
| PHP lang files | `lang/{locale}/auth.php`, `validation.php`, `passwords.php`, `pagination.php` |
| Admin PHP lang files | `lang/{locale}/filament.php` — 350+ keys for all admin panel labels, sections, helpers |
| Auth messages | All use `__()` for locale-aware responses |
| Validation messages | Form requests use `__('validation.custom.*')` — no hardcoded strings |
| API controller pattern | All controllers use `ApiResponse::success/error()` + `__('api.*')` messages |

### Model Accessor Pattern (Locale Resolution)

All trilingual models implement automatic locale resolution via Eloquent accessors:

```php
// Example: OnboardingOption, Interest, Achievement, FeedbackCategory, etc.
public function getNameAttribute(): ?string
{
    $locale = app()->getLocale();
    $field = "name_{$locale}";
    return $this->attributes[$field] ?? $this->attributes['name_en'] ?? null;
}
```

**Models with locale-resolving accessors:**
- `OnboardingOption` → `name`
- `Interest` → `name`
- `Achievement` → `name`, `description`
- `FeedbackCategory` → `name`
- `FeedbackQuestion` → `question`
- `HealthAssessmentCategory` → `name`
- `HealthAssessmentQuestion` → `question`
- `NutritionAdvice` → `prophetic_advice`
- `Post` → `title`, `content`

### Admin Panel Translation Pattern

All Filament resources use `__('filament.*')` for every user-facing string:

```php
// Labels:     __('filament.labels.exercise_count')
// Sections:   __('filament.sections.theme_info')
// Helpers:    __('filament.helper.zone_color_desc')
// Placeholders: __('filament.placeholders.theme_name')
// Empty states: __('filament.empty.exercises')
// Options:    __('filament.roles.admin'), __('filament.zone_colors.blue')
```

Translation file structure (`lang/{locale}/filament.php`):
- `nav.*` — Navigation groups (dashboard, workout_training, health_wellness, etc.)
- `resources.*` — Resource labels
- `labels.*` — 130+ field labels
- `sections.*` — 60+ section titles with descriptions
- `helpers.*` — 35+ helper texts
- `placeholders.*` — 50+ placeholder texts
- `empty.*` — 15+ empty state messages
- `widgets.*` — Dashboard widget labels, stat names, descriptions
- `roles.*`, `days.*`, `gender.*`, `moods.*`, etc. — Select option translations
- `dashboard.*` — Dashboard-specific strings

### iOS Approach

| Aspect | Implementation |
|--------|---------------|
| Static strings | `Localizable.strings` per language (2600+ keys each) |
| Runtime switching | `LanguageManager.shared` with bundle swapping |
| String extension | `.localized` (LocalizedStringKey), `.localizedString` (String) |
| RTL support | Automatic layout direction for Arabic |
| Refresh mechanism | `refreshID: UUID` triggers full UI rebuild on language change |

### Localized Content Areas

- All UI labels, buttons, navigation titles
- Onboarding steps and options
- Zone names and descriptions (in `intensity_zones` table)
- Achievement names and descriptions
- Feedback/health assessment questions
- Sleep protocol objectives
- Prophetic medicine recipes
- Blog post titles and content
- Error messages and validation feedback
- GDPR views (Privacy Policy, Delete Account)
- Workout metadata (zone names, RPE, theme descriptions)

---

## 12. Security Architecture

### Authentication Flow

```
1. User registers/logs in
      │
      v
2. Server creates Sanctum token (7-day expiry)
      │
      v
3. Token returned in JSON response
      │
      v
4. iOS stores token in Keychain (kSecAttrAccessibleWhenUnlocked)
      │
      v
5. Every API request includes:
      ├── Authorization: Bearer {token}
      └── X-App-Key: {obfuscated app key}
      │
      v
6. Server validates:
      ├── Token validity (Sanctum middleware)
      └── App key hash match (VerifyAppKey middleware)
```

### Security Layers

| Layer | Implementation |
|-------|---------------|
| Transport | HTTPS + SSL certificate pinning (SHA-256 public key) |
| Authentication | Laravel Sanctum (Bearer token, 7-day expiry) |
| App Verification | X-App-Key header (SHA-256 hash comparison) |
| Rate Limiting | 3 tiers: auth (5/min), standard (60/min), heavy (10/min) |
| Input Validation | Laravel Form Requests on all endpoints |
| User Scoping | All queries scoped to `$request->user()->id` |
| Mass Assignment | `$fillable` whitelists on all models |
| Token Storage | iOS Keychain (not UserDefaults) |
| Key Obfuscation | App key split into 4 segments in binary |
| Force HTTPS | Middleware redirects HTTP→HTTPS in production |
| Password Hashing | bcrypt via Laravel's `hashed` cast |
| CSRF Protection | Active on web routes (admin panel) |
| Admin Access | Role-based: only admin/coach/manager can access Filament |

### GDPR Compliance

| Right | Implementation |
|-------|---------------|
| Right of Access (Art. 15) | `GET /api/account/export` — returns all user data in structured JSON |
| Data Portability (Art. 20) | Same export endpoint, JSON format |
| Right to Erasure (Art. 17) | `DELETE /api/account` — requires password + "DELETE" confirmation |
| Privacy Info | `GET /api/privacy` — privacy policy URL, terms URL, retention policies |
| Data Retention | All data retained until account deletion; permanently removed within 30 days |
| Contact | `privacy@dipoddi.com` |

**iOS GDPR Views:**
- `PrivacyPolicyView.swift` — Full privacy policy display (6 sections, trilingual)
- `DeleteAccountView.swift` — Account deletion with password confirmation + "DELETE" typing
- Both accessible from ProfileView → Privacy & Data section

**Backend Controller:** `AccountController.php`
- `exportData()` — Exports: account, profile, goals, progress, workout sessions, feedback, health assessments, achievements, reminder settings
- `deleteAccount()` — Revokes all tokens, cascading FK deletes all related data
- `privacyInfo()` — Returns privacy URLs and retention policies

### SSL Pinning (iOS)

```swift
// APIConstants.swift
enum SSLPins {
    static let pins: [String] = [
        // SHA-256 hash of server's TLS public key
    ]
    static var isEnabled: Bool {
        APIConstants.isProduction && !pins.isEmpty
    }
}
```

---

## 13. Admin Panel (Filament 3.x)

### Access Control & Auth Configuration

- URL: `/admin`
- Roles: `admin`, `coach`, `manager`
- Guard: web session (not Sanctum)
- Method: `User::canAccessPanel()` checks role
- **Login**: Built-in Filament login with rate limiting (5 attempts/min)
- **Password Reset**: `/admin/password-reset/request` — email-based recovery
- **Profile**: `/admin/profile` — full profile editor (name, email, password)
- **Dark Mode**: Enabled with toggle
- **SPA Mode**: Enabled for faster navigation
- **Database Notifications**: Enabled with 60s polling
- **Rate Limiting**: 60 requests/minute via throttle middleware
- **Unsaved Changes Alerts**: Enabled to prevent data loss
- **Global Search**: `Cmd+K` / `Ctrl+K` keyboard binding

### Navigation Groups & Resources

| Group | Resources |
|-------|-----------|
| User Management | Users, UserProfiles, UserGoals, UserProgress |
| Workout Programme | WorkoutThemes (with full rule editing), Exercises, BonusWorkoutRules, WorkoutSessions |
| Programme & Recovery | IntensityZones, SleepProtocols, Chronotypes, PropheticRemedies, HomeWorkoutRules, TrainingDayLogic |
| Nutrition | FoodItems, NutritionAdvice |
| Feedback & Assessment | FeedbackCategories, FeedbackSessions, HealthAssessmentCategories, HealthAssessmentSessions |
| Content | Posts, Achievements, Interests, OnboardingOptions |
| System | PushNotifications, PlayerProfiles |

### WorkoutThemeResource (Key Admin Form)

The theme admin form has 6 organized fieldsets for rule editing:

1. **Training Parameters**: exercise_count, sets, reps, recovery_time, load_type, charges, speed_intensity
2. **Metabolic Parameters**: mets, duration, rpe (1-10), load_ua, impact (1-5)
3. **Recovery & Freshness**: sleep_requirement, hydration, freshness_24h/48h/72h
4. **Performance Science**: supercomp_window, gain_prediction, injury_risk (select)
5. **Load Thresholds**: daily_alert_threshold, weekly_alert_threshold, elastic_recoil, cfa
6. **Target Profiles**: target_profiles (JSON)

### Dashboard Widgets

- StatsOverviewWidget (users, sessions, goals)
- NewUsersChart
- LatestUsersTable
- GoalProgressWidget
- FeedbackOverviewWidget
- HealthAssessmentOverviewWidget
- AchievementsWidget
- OnboardingStatsWidget
- WorkoutNutritionWidget

---

## 14. Seeders & Data Inventory

### Seeder Execution Order

| # | Seeder | Records | Purpose |
|---|--------|---------|---------|
| 1 | `AdminSeeder` | 3 | Admin, coach, manager users |
| 2 | `UserSeeder` | 11 | Sample users with profiles |
| 3 | `PlayerProfileSeeder` | 36 | Football/Padel/Fitness archetypes |
| 4 | `DipoddiProgrammeSeeder` | ~2000 | 76 themes, exercises, base rules |
| 5 | `DipoddiProgrammeEnhancementSeeder` | 18 | Zone/freshness data for gym themes |
| 6 | `DipoddiCardioAndMappingsSeeder` | ~200 | Cardio themes & profile mappings |
| 7 | `CardioThemeEnhancementSeeder` | ~54 | Enhanced cardio rule data |
| 8 | `CardioProfileMappingSeeder` | ~248 | Cardio-to-profile mappings |
| 9 | `DipoddiProgrammeCorrectionSeeder` | ~150 | Corrected display_names, zone_colors, added missing themes |
| 10 | `WorkoutThemeRuleSeeder` | ~76 | Complete rule data for all themes |
| 11 | `ExerciseSeeder` | 451 | Exercise library with videos |
| 12 | `IntensityZoneSeeder` | 5 | 5 zones with trilingual data |
| 13 | `TrainingDayLogicSeeder` | 7 | Day distribution rules |
| 14 | `HomeWorkoutRuleSeeder` | 72 | Home circuit configs |
| 15 | `BonusWorkoutRuleSeeder` | ~20 | Bonus workout configs |
| 16 | `FoodItemSeeder` | 200+ | Sport nutrition database |
| 17 | `NutritionAdviceSeeder` | 20+ | Condition-based guidance |
| 18 | `FeedbackSeeder` | 230+ | Position-specific questions |
| 19 | `HealthAssessmentSeeder` | 100+ | Health questionnaire data |
| 20 | `AchievementSeeder` | 30+ | Achievement definitions |
| 21 | `SleepProtocolSeeder` | 13 | 9 protocols + 4 chronotypes |
| 22 | `PropheticMedicineSeeder` | 45 | 10 conditions, 45 remedies |
| 23 | `InterestSeeder` | ~10 | User interest categories |
| 24 | `OnboardingOptionSeeder` | ~50 | Dropdown options |
| 25 | `UserFavoriteExerciseSeeder` | ~20 | Sample favorites |
| 26 | `UserReminderSettingSeeder` | ~14 | Default reminder settings |

### Current Data Volumes

| Entity | Count |
|--------|-------|
| Users | 14 |
| Player Profiles | 36 |
| Workout Themes | 76 (19 gym + 54 cardio + 2 home + 1 mobility) |
| Theme Rules | 76 (100% coverage, 1:1) |
| Profile-Theme Mappings | 721 (0 unmapped) |
| Exercises | 451 (MUSCULATION 114, MAISON 121, BONUS 134, KINE 65, CARDIO 17) |
| Intensity Zones | 5 |
| Training Day Logic | 7 |
| Home Workout Rules | 72 |

---

## 15. User Journey Flows

### First Launch (Onboarding — 7 Steps)

```
Step 0: Welcome (intro animation)
Step 1: About You
    ├── Gender (male/female)
    ├── Birth date
    ├── Height (cm)
    ├── Weight (kg)
    └── Age (auto-calculated)

Step 2: Sport & Level
    ├── Discipline: FOOTBALL / PADEL / FITNESS
    ├── Position → selects from 36 PlayerProfiles
    ├── Level: DEBUTANT / INTERMEDIAIRE / AVANCE
    └── Pro level: AMATEUR / SEMI_PRO / PRO

Step 3: Goals & Training
    ├── Goal: PERTE_DE_POIDS / PRISE_DE_MUSCLE / PERFORMANCE / REMISE_EN_FORME
    ├── Ideal weight (kg)
    ├── Training location: MUSCULATION_EN_SALLE / MAISON / DEHORS / MIXED
    ├── Training days: ["LUN","MAR","MER","JEU","VEN","SAM","DIM"]
    ├── Match day: AUCUN / LUN / MAR / ... / DIM
    └── Equipment preferences (gym/cardio/outdoor/home arrays)

Step 4: Nutrition
    ├── Is vegetarian (toggle)
    ├── Meals per day (1-6)
    ├── 12 food consumption frequency sliders
    ├── Bad habits (multi-select)
    └── Snacking habits

Step 5: Health
    ├── Medication (yes/no)
    ├── Diabetes (yes/no)
    ├── Injuries (yes/no + location)
    ├── Family history (multi-select)
    └── Medical history (multi-select)

Step 6: Summary & Finish
    └── PUT /api/user/profile → is_onboarding_complete = true
```

### Daily Workout Flow

```
Workout Tab
    │
    ├── GET /api/workout-plan (weekly plan, 7 sessions)
    │
    ├── View daily sessions (Mon-Sun cards)
    │       ├── Training day: Theme + zone color badge + display_name
    │       └── Rest day: "Repos" label
    │
    ├── Tap training session → WorkoutSessionReelsView
    │       ├── Swipeable exercise cards with embedded video
    │       ├── Zone color indicator + RPE badge
    │       ├── Sleep & hydration recommendations
    │       ├── Sets × Reps with recovery timer
    │       ├── ThemeInfoView (full metadata display)
    │       └── ZoneInfoView (5-zone explanation)
    │
    └── Complete session → PostWorkoutFeedbackView
            ├── Difficulty (1-5 scale)
            ├── Energy level (1-5)
            ├── Muscle soreness areas
            └── POST /api/workout-feedback
```

---

## 16. Workout Plan Generation Algorithm

```
POST /api/workout-plan/generate
    │
    v
1. Load UserProfile (discipline, position, level, goal, training_days[], match_day)
    │
    v
2. Find matching PlayerProfile from 36 archetypes
   (UserProfile.position == PlayerProfile.name)
    │
    v
3. Get player_profile_themes (percentage allocations)
   e.g., "Le Blindage" 25%, "Le Sprint" 20%, ...
    │
    v
4. MatchAwarePlanGenerator::generate(match_day, training_days)
   → Returns 7-day schedule with day types:
   T_HIGH_INTENSITY, T_STRENGTH, T_MATCH, T_RECOVERY, T_REST, T_MOBILITY
    │
    v
5. Load TrainingDayLogic for user's training_days count
   e.g., 4 days → 2 principal, 2 random
    │
    v
6. Resolve theme type from training_location:
   gym → 'gym', home → 'home', outdoor → 'cardio', mixed → 'gym'
    │
    v
7. For each training day:
    │
    ├── Select theme:
    │   ├── Principal day: weighted random from profile's themes
    │   └── Random day: any theme of correct type
    │
    ├── Zone-aware scheduling:
    │   └── Skip if zone used yesterday AND freshness_24h < 0.5
    │
    ├── Load WorkoutThemeRule:
    │   └── exercise_count, sets, reps, recovery_time, RPE, METs...
    │
    ├── Select exercises from pool (match theme category)
    │
    ├── Generate warmup & finisher
    │
    ├── Calculate Foster Load: RPE × duration_minutes
    │
    └── Save WorkoutSession + exercises + metadata (14 fields)
    │
    v
8. Return 7-day plan (training + rest sessions)
```

**Key implementation file:** `app/Services/Workout/WorkoutPlanGenerator.php`
- Constructor: `__construct(User $user)` — loads `$user->profile`
- Main method: `generateAndSaveWeeklyPlan()`
- Metadata: passed as raw PHP array (NOT json_encoded) due to model cast

---

## 17. Pre-Change Checklist

Before making any changes, verify:

### Backend Changes

- [ ] Read the relevant model(s) — check `$fillable`, `$casts`, relationships
- [ ] Read the relevant controller(s) — check validation rules, response format
- [ ] Check route definition in `routes/api.php` — middleware, rate limits
- [ ] Check if related seeder data exists and might need updating
- [ ] Verify the Filament admin resource reflects any model changes
- [ ] Check if the change affects the `WorkoutPlanGenerator` pipeline
- [ ] Review the `WorkoutSession.metadata` 14-field contract if touching workout logic

### iOS Changes

- [ ] Read `APIModels.swift` — check Codable struct matches backend JSON
- [ ] Read the relevant ViewModel — check @Published properties and API calls
- [ ] Check `APIService.swift` — verify endpoint URL and request format
- [ ] Check `APIConstants.swift` — verify endpoint is defined
- [ ] Verify localization keys exist in all 3 `.strings` files
- [ ] Check if the view uses any Design System components that might change

### Cross-System Changes

- [ ] Verify API request/response format matches between backend and iOS
- [ ] Check that JSON keys use snake_case (backend) → camelCase (iOS via decoder)
- [ ] Test with `docker exec dipodi-app php artisan tinker` for backend verification
- [ ] Ensure any new localization keys are added to EN, FR, and AR files

---

## 18. Post-Change Checklist

After making changes:

- [ ] Clear all Laravel caches: `php artisan cache:clear && php artisan config:clear && php artisan route:clear && php artisan view:clear`
- [ ] If seeder changed: re-run with `php artisan db:seed --class=SpecificSeeder`
- [ ] If migration added: `php artisan migrate`
- [ ] Verify API response format with curl or tinker
- [ ] If workout pipeline changed: generate a test plan and verify 14 metadata fields
- [ ] If admin form changed: verify Filament panel loads without errors
- [ ] If iOS model changed: verify Codable decoding doesn't crash
- [ ] If localization added: verify all 3 language files have the key
- [ ] **Update this ARCHITECTURE.md** with any structural changes:
  - New models, controllers, endpoints
  - New/modified seeder data
  - Changed data volumes or relationships
  - New iOS views or ViewModels

---

## 19. Production Deployment Checklist

### Sliplane Environment Variables (set in dashboard)

| Variable | Required | Notes |
|----------|----------|-------|
| `APP_KEY` | ✅ | `base64:...` — generate with `php artisan key:generate --show` |
| `APP_ENV` | ✅ | `production` |
| `APP_DEBUG` | ✅ | `false` |
| `APP_URL` | ✅ | `https://dipodi-api.sliplane.app` |
| `DB_HOST` | ✅ | Sliplane MySQL addon host |
| `DB_DATABASE` | ✅ | `dipodi_api` |
| `DB_USERNAME` | ✅ | MySQL user |
| `DB_PASSWORD` | ✅ | Strong random password (32+ chars) |
| `DIPODI_APP_KEY_HASH` | ✅ | SHA-256 hash of iOS X-App-Key |
| `CACHE_DRIVER` | ⬚ | `file` (default) or `redis` |
| `SESSION_DRIVER` | ⬚ | `file` (default) or `redis` |
| `QUEUE_CONNECTION` | ⬚ | `sync` (default) or `redis` |
| `SANCTUM_TOKEN_EXPIRATION` | ⬚ | `10080` (7 days in minutes) |
| `MAIL_MAILER` | ⬚ | `log` (default) or `smtp` |
| `CORS_ALLOWED_ORIGINS` | ⬚ | `*` or specific domains |

### Sliplane Service Settings

- [ ] Health check path: `/health`
- [ ] Port: `80`
- [ ] Auto-deploy: enabled on `main` branch
- [ ] Repository: `Symeonlab/dipodi-api`
- [ ] Dockerfile path: `Dockerfile`

### Backend (automated by docker/start.sh)

- [x] `APP_ENV=production` and `APP_DEBUG=false` — set via env vars
- [x] `php artisan migrate --force` — runs on every container start
- [x] `php artisan optimize` (config/route/view cache) — runs on start
- [x] ForceHttps middleware — enabled in bootstrap/app.php
- [x] SSL — automatic via Sliplane
- [ ] Configure production MySQL credentials in Sliplane env vars
- [ ] Set `DIPODI_APP_KEY_HASH` in Sliplane env vars
- [ ] Run initial `php artisan db:seed --force` (one-time, via exec)
- [ ] Configure mail driver (SMTP/SES) when ready
- [ ] Add Redis addon when scaling (optional)
- [ ] Set up custom domain `api.dipoddi.com` → CNAME to Sliplane

### iOS

- [ ] Set production API URL: `https://dipodi-api.sliplane.app/api`
- [ ] Set iOS X-App-Key to match `DIPODI_APP_KEY_HASH`
- [ ] Set build configuration to Release
- [ ] Update bundle identifier and version
- [ ] Configure App Store Connect metadata
- [ ] Remove debug views and test endpoints
- [ ] Verify Keychain access settings
- [ ] Test on physical devices (iPhone + iPad)
- [ ] Submit for App Store review
