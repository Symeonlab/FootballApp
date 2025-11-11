# API Endpoints Documentation

This document maps the iOS app's API calls to the Laravel backend routes.

## 🔓 Public Endpoints (No Authentication Required)

### Authentication

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `POST` | `register()` | `/api/auth/register` | Register new user |
| `POST` | `login()` | `/api/auth/login` | Login user |
| `POST` | `forgotPassword()` | `/api/auth/forgot-password` | Request password reset |
| `POST` | `socialLogin()` | `/api/auth/{provider}/login` | Social login (Google/Facebook/Apple) |

### Onboarding

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getOnboardingData()` | `/api/onboarding-data` | Get onboarding options/data |

---

## 🔒 Protected Endpoints (Requires Authentication Token)

### User & Profile

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getUser()` | `/api/user` | Get current user info |
| `PUT` | `updateUserProfile()` | `/api/user/profile` | Update user profile (onboarding) |
| `POST` | `logout()` | `/api/auth/logout` | Logout user |

### Dashboard

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getDashboardMetrics()` | `/api/dashboard-metrics` | Get dashboard statistics |

### Nutrition

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getNutritionPlan()` | `/api/nutrition-plan` | Get nutrition plan |

### Workouts

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `POST` | `generateWorkoutPlan()` | `/api/workout-plan/generate` | Generate new workout plan |
| `GET` | `getWorkoutPlan()` | `/api/workout-plan` | Get weekly workout plan |
| `POST` | `logProgress()` | `/api/user-progress` | Log workout completion |
| `GET` | `getProgress()` | `/api/user-progress` | Get progress history |

### Kine/Recovery

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getKineData()` | `/api/kine-data` | Get recovery exercises |
| `GET` | `getKineFavorites()` | `/api/kine-favorites` | Get favorite exercises |
| `POST` | `toggleKineFavorite()` | `/api/kine-favorites/toggle` | Toggle exercise favorite |

### Settings

| Method | iOS Function | Laravel Route | Description |
|--------|-------------|---------------|-------------|
| `GET` | `getReminderSettings()` | `/api/settings/reminders` | Get reminder settings |
| `PUT` | `updateReminderSettings()` | `/api/settings/reminders` | Update reminder settings |

---

## 📝 Request/Response Examples

### Register User

**Request:**
```swift
try await APIService.shared.register(
    name: "John Doe",
    email: "john@example.com",
    password: "password123",
    passwordConfirmation: "password123"
)
```

**Laravel Endpoint:**
```
POST /api/auth/register
```

**Request Body:**
```json
{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123",
    "password_confirmation": "password123"
}
```

**Response:**
```json
{
    "message": "User registered successfully",
    "token": "2|abc123...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "user",
        "profile": null
    }
}
```

---

### Login User

**Request:**
```swift
try await APIService.shared.login(
    email: "john@example.com",
    password: "password123"
)
```

**Laravel Endpoint:**
```
POST /api/auth/login
```

**Request Body:**
```json
{
    "email": "john@example.com",
    "password": "password123"
}
```

**Response:**
```json
{
    "message": "Login successful",
    "token": "3|xyz789...",
    "user": {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "role": "user",
        "profile": {
            "id": 1,
            "user_id": 1,
            "is_onboarding_complete": false
        }
    }
}
```

---

### Get Workout Plan

**Request:**
```swift
let plan = try await APIService.shared.getWorkoutPlan()
```

**Laravel Endpoint:**
```
GET /api/workout-plan
Headers: Authorization: Bearer {token}
```

**Response:**
```json
[
    {
        "id": 1,
        "day": "LUNDI",
        "theme": "Strength",
        "warmup": "5 min jog",
        "finisher": "Cool down",
        "exercises": [
            {
                "id": 1,
                "name": "Squats",
                "sets": "3 sets",
                "reps": "12 reps",
                "recovery": "60s",
                "video_url": null,
                "is_completed": false
            }
        ],
        "is_completed": false,
        "completion_date": null
    }
]
```

---

### Toggle Favorite Exercise

**Request:**
```swift
try await APIService.shared.toggleKineFavorite(exerciseID: 5)
```

**Laravel Endpoint:**
```
POST /api/kine-favorites/toggle
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
    "exercise_id": 5
}
```

**Response:**
```json
{
    "message": "Favorite toggled",
    "is_favorite": true
}
```

---

## 🔑 Authentication Flow

```
1. User registers or logs in
   └─> App receives token + user data

2. Token saved to Keychain
   └─> APITokenManager.shared.currentToken = token

3. All protected endpoints include token
   └─> Header: "Authorization: Bearer {token}"

4. Token validation fails
   └─> App automatically logs out user
   └─> Returns to authentication screen
```

---

## 🛠️ Development Notes

### Base URL Configuration

**File:** `APIService.swift`

```swift
// For iOS Simulator (Mac)
private let baseURL = "http://localhost:8000"

// For Real Device on same network
private let baseURL = "http://192.168.1.XXX:8000"
```

### Preview Mode

The app automatically skips API calls in Xcode Previews:

```swift
private var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
```

### Debug Mode Fallback

In DEBUG builds, the app automatically loads mock data when API is unavailable:

```swift
#if DEBUG
self.loadMockDataForDevelopment()
#endif
```

---

## ✅ Migration Checklist

- [x] Updated `APIService.swift` with new endpoint functions
- [x] Added proper request/response types
- [x] Updated `AuthViewModel` to use new auth endpoints
- [x] Converted to async/await pattern
- [x] Added preview mode detection
- [x] Added development mock data fallback
- [x] Documented all endpoints
- [x] Added request/response examples

---

## 🚀 Testing

### Start Laravel Backend

```bash
cd /path/to/laravel/project
php artisan serve
```

### Test Endpoints

```bash
# Register
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'

# Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Get User (replace TOKEN)
curl -X GET http://localhost:8000/api/user \
  -H "Authorization: Bearer TOKEN"

# Get Workout Plan (replace TOKEN)
curl -X GET http://localhost:8000/api/workout-plan \
  -H "Authorization: Bearer TOKEN"
```

---

## 📱 iOS App Usage

All API calls are now available through `APIService.shared`:

```swift
// Authentication (no token required)
try await APIService.shared.register(name:email:password:passwordConfirmation:)
try await APIService.shared.login(email:password:)
try await APIService.shared.forgotPassword(email:)
try await APIService.shared.socialLogin(provider:token:)

// User & Profile (requires token)
try await APIService.shared.getUser()
try await APIService.shared.updateUserProfile(_:)
try await APIService.shared.logout()

// Dashboard
try await APIService.shared.getDashboardMetrics()

// Nutrition
try await APIService.shared.getNutritionPlan()

// Workouts
try await APIService.shared.generateWorkoutPlan()
try await APIService.shared.getWorkoutPlan()
try await APIService.shared.logProgress(_:)
try await APIService.shared.getProgress()

// Kine/Recovery
try await APIService.shared.getKineData()
try await APIService.shared.getKineFavorites()
try await APIService.shared.toggleKineFavorite(exerciseID:)

// Settings
try await APIService.shared.getReminderSettings()
try await APIService.shared.updateReminderSettings(_:)
```

---

**Last Updated:** December 13, 2024  
**iOS Version:** Swift 5.9+  
**Laravel Version:** 10.x  
**API Version:** 1.0
