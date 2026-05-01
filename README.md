# iOSAssignment

A native iOS application built with **SwiftUI** that integrates with a **Moodle-based LMS** (Learning Management System) via REST APIs. The app demonstrates clean **MVVM architecture**, proper state management, modern **Swift concurrency (async/await)**, and uses **zero third-party dependencies**.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Setup Instructions](#setup-instructions)
- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [App Flow](#app-flow)
- [API Integration](#api-integration)
- [Implementation Decisions](#implementation-decisions)
- [Performance Optimizations](#performance-optimizations)
- [Logging & Debugging](#logging--debugging)
- [Testing](#testing)
- [Known Limitations](#known-limitations)
- [Tech Stack](#tech-stack)

---

## Features

### Authentication

- **Username/Password Login** — Authenticates via the LMS `/login/token.php` endpoint
- **Pre-generated Token Login** — One-tap instant access using a pre-configured token
- **Demo Credentials** — Pre-filled for quick testing (`student1` / `Demo@12345`)
- **Secure Logout** — Clears all session data and returns to login

### Courses

- **Enrolled Courses List** — Displays all courses the user is enrolled in
- **Custom Course Banners** — Dynamically generated gradient backgrounds with course initials and context-aware SF Symbol icons (e.g., brain for AI, globe for Web)
- **Progress Tracking** — Visual progress bar with color coding (green >= 75%, orange >= 40%, teal < 40%)
- **Pull-to-Refresh** — Force-refreshes course data from the server

### Course Detail

- **Sections & Modules** — Displays course content organized by sections
- **Module Type Icons** — Context-specific SF Symbols for 15+ module types (assignment, quiz, forum, resource, page, book, etc.)
- **Empty Section Filtering** — Sections with no modules are automatically hidden

### Grades

- **Per-Course Grade Items** — Fetches and displays grades for each enrolled course
- **Course Name Headers** — Injects actual course names from the enrolled courses data
- **Course Total Highlighting** — Course total rows are visually distinct with teal styling and light background
- **Smart Filtering** — Courses with no meaningful grade data (only an empty course total) are filtered out
- **Alphabetical Sorting** — Courses sorted A-Z, items sorted with course total always last

### Profile

- **User Information** — Displays authenticated user details
- **Sign Out** — Secure logout with session cleanup

### General

- **Animated Splash Screen** — Branded launch animation with scaling and fade effects
- **Native Launch Screen** — Teal background configured via `UILaunchScreen` in Info.plist
- **Loading States** — Consistent spinner with contextual messages on every screen
- **Error States** — User-friendly error messages with retry buttons
- **Light/Dark Mode** — Full support via system appearance
- **Pull-to-Refresh** — Available on Courses and Grades screens

---

## Screenshots

| Splash          | Login                  | Courses                 | Course Detail      | Grades            | Profile            |
| --------------- | ---------------------- | ----------------------- | ------------------ | ----------------- | ------------------ |
| Animated launch | Pre-filled credentials | Card-based with banners | Sections & modules | Grouped by course | User info & logout |

---

## Setup Instructions

### Prerequisites

- **Xcode 26.4+** (tested with Xcode 26.4)
- **iOS 26.0+** deployment target
- **macOS Sonoma** or later
- No CocoaPods, SPM, or Carthage needed

### Running the App

```bash
# 1. Clone the repository
git clone <repository-url>
cd iOSAssignment

# 2. Open in Xcode
open iOSAssignment.xcodeproj

# 3. Select a simulator (iPhone 15 Pro recommended)
# 4. Press Cmd + R to build and run
```

### Login Options

| Method                | Credentials               | Notes                                  |
| --------------------- | ------------------------- | -------------------------------------- |
| **Username/Password** | `student1` / `Demo@12345` | Pre-filled on login screen             |
| **Demo Token**        | One-tap button            | Uses pre-generated token `c269d73b...` |

> **Zero dependencies** — The project uses only Apple frameworks (`SwiftUI`, `Foundation`, `os`). No package resolution step is needed.

---

## Architecture Overview

### MVVM (Model-View-ViewModel)

```
┌───────────────────────────────────────────────────────┐
│                       Views                           │
│  SwiftUI declarative UI layer                         │
│  SplashView → LoginView → MainTabView                 │
│  CoursesView / CourseDetailView / GradesView          │
├───────────────────────────────────────────────────────┤
│                    ViewModels                         │
│  @Observable classes with ViewState<T>                │
│  LoginViewModel / CoursesViewModel                    │
│  CourseDetailViewModel / GradesViewModel              │
├───────────────────────────────────────────────────────┤
│                     Services                          │
│  APIService  — URLSession + async/await networking    │
│  AuthManager — Authentication state singleton         │
│  AppLogger   — Debug logging via os.Logger + print    │
├───────────────────────────────────────────────────────┤
│                      Models                           │
│  Decodable structs mapping to JSON responses          │
│  AuthToken / Course / CourseSection / GradeItem       │
└───────────────────────────────────────────────────────┘
```

### State Management

All screens use a generic `ViewState<T>` enum for consistent state handling:

```swift
enum ViewState<T> {
    case idle       // Initial state
    case loading    // Fetching data
    case loaded(T)  // Data available
    case error(String) // Error with message
}
```

### Key Patterns

- **@Observable** (Swift 5.9+) — Modern observation macro replacing `ObservableObject` + `@Published`
- **async/await** — Native Swift concurrency for all API calls
- **Singleton Services** — `APIService.shared` and `AuthManager.shared` for shared state
- **Task.detached** — Used in Grades to prevent SwiftUI's `.refreshable` from cancelling network calls

---

## Project Structure

```
iOSAssignment/
├── iOSAssignmentApp.swift              # App entry point with @main
├── Info.plist                          # Launch screen & app configuration
│
├── Models/
│   ├── AuthToken.swift                 # AuthTokenResponse for login
│   ├── Course.swift                    # Course model with progress helpers
│   ├── CourseSection.swift             # CourseSection & CourseModule
│   └── GradeItem.swift                # GradeResponse, UserGrade, GradeItem
│
├── Services/
│   ├── APIService.swift               # Centralized networking (URLSession)
│   ├── AuthManager.swift              # Auth state management (token, userId)
│   └── KeychainService.swift          # Secure token storage in Keychain
│
├── ViewModels/
│   ├── LoginViewModel.swift           # Login form state & validation
│   ├── CoursesViewModel.swift         # Courses list + ViewState enum
│   ├── CourseDetailViewModel.swift     # Course sections loading
│   └── GradesViewModel.swift          # Grade fetching with Task.detached
│
├── Views/
│   ├── SplashView.swift               # Animated splash with scale + opacity
│   ├── RootView.swift                 # Auth-based navigation (login vs main)
│   ├── MainTabView.swift              # Tab bar (Courses, Grades, Profile)
│   │
│   ├── Login/
│   │   └── LoginView.swift            # Username/password + token login
│   │
│   ├── Courses/
│   │   ├── CoursesView.swift          # Scrollable course cards
│   │   └── CourseCardView.swift       # Card with gradient banner + progress
│   │
│   ├── CourseDetail/
│   │   └── CourseDetailView.swift     # Sections list with module icons
│   │
│   ├── Grades/
│   │   └── GradesView.swift           # Grouped grades with sorting
│   │
│   ├── Profile/
│   │   └── ProfileView.swift          # User info + logout
│   │
│   └── Components/
│       ├── LoadingView.swift          # Reusable spinner + message
│       └── ErrorView.swift            # Reusable error + retry button
│
└── Utilities/
    ├── Constants.swift                # Base URL, endpoints, credentials
    └── Logger.swift                   # AppLogger (os.Logger + print)
```

**Total: 24 Swift files** — Clean separation with no unused or dead files.

---

## App Flow

```
App Launch
  └── SplashView (animated, ~2 seconds)
        └── RootView
              ├── Not Authenticated → LoginView
              │     ├── Sign In (username/password) → MainTabView
              │     └── Use Demo Token → MainTabView
              │
              └── Authenticated → MainTabView
                    ├── Tab 1: Courses
                    │     ├── CoursesView (card list)
                    │     └── → CourseDetailView (sections/modules)
                    │
                    ├── Tab 2: Grades
                    │     └── GradesView (grouped by course)
                    │
                    └── Tab 3: Profile
                          └── ProfileView (info + logout → LoginView)
```

---

## API Integration

### Base Configuration

| Setting             | Value                                   |
| ------------------- | --------------------------------------- |
| **Base URL**        | `https://moodle.itcorner.qzz.io`        |
| **API Endpoint**    | `/webservice/rest/server.php`           |
| **Login Endpoint**  | `/login/token.php`                      |
| **Response Format** | `json` (via `moodlewsrestformat` param) |
| **Timeout**         | 30 seconds                              |

### Endpoints

| Screen            | Web Service Function               | Method | Key Parameters                    |
| ----------------- | ---------------------------------- | ------ | --------------------------------- |
| **Login**         | `/login/token.php`                 | GET    | `username`, `password`, `service` |
| **Courses**       | `core_enrol_get_users_courses`     | GET    | `wstoken`, `userid`               |
| **Course Detail** | `core_course_get_contents`         | GET    | `wstoken`, `courseid`             |
| **Grades**        | `gradereport_user_get_grade_items` | GET    | `wstoken`, `userid`, `courseid`   |

### Request Flow

```
1. Login → Receives auth token
2. Courses → GET enrolled courses (cached in-memory for reuse)
3. Course Detail → GET sections + modules for selected course
4. Grades → GET enrolled courses (from cache) → GET grades per course (sequential)
```

### Error Handling

All API errors are mapped to a typed `APIError` enum:

- `invalidURL` — Malformed URL construction
- `networkError(Error)` — Connection/timeout failures
- `decodingError(Error)` — JSON parsing failures
- `serverError(String)` — Server-returned error messages
- `unauthorized` — Authentication failures

---

## Implementation Decisions

| Decision                      | Rationale                                                                                                                                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Pure Apple Frameworks**     | No Alamofire, Kingfisher, etc. `URLSession` + `async/await` handles REST calls cleanly. Demonstrates native proficiency.                                                                          |
| **@Observable (Swift 5.9+)**  | Modern observation macro — cleaner than `ObservableObject` + `@Published`. Automatic dependency tracking with no manual `objectWillChange`.                                                       |
| **async/await**               | Native Swift concurrency for all API calls. No completion handlers or Combine needed. Cleaner error propagation with `try/catch`.                                                                 |
| **ViewState\<T\> enum**       | Generic enum (`.idle`, `.loading`, `.loaded(T)`, `.error(String)`) ensures consistent state handling across all 4 screens.                                                                        |
| **Singleton Services**        | `APIService.shared` and `AuthManager.shared` — simple and sufficient for this app's scope. In production, prefer dependency injection via protocols.                                              |
| **Custom Course Banners**     | LMS API returns SVG image URLs which `AsyncImage` cannot render. Replaced with dynamically generated gradient banners using course initials and context-aware SF Symbols.                         |
| **Task.detached for Grades**  | SwiftUI's `.refreshable` cancels its cooperative task when the gesture ends. `Task.detached` isolates network calls from this cancellation context.                                               |
| **In-Memory Courses Cache**   | Enrolled courses are fetched once and cached in `APIService`. The Grades tab reuses this cache to avoid a redundant API call. Pull-to-refresh bypasses the cache.                                 |
| **Sequential Grade Fetching** | Grades are fetched per-course sequentially (not concurrently) to avoid race conditions with `Task.detached` and provide reliable results.                                                         |
| **Smart Grade Filtering**     | Courses with only an empty course-total item (no actual grades) are filtered out to keep the UI clean and informative.                                                                            |
| **os.Logger + print()**       | `os.Logger` for structured debug messages (visible in Console.app with subsystem filtering). `print()` for full API response bodies to avoid the ~1024 character truncation limit of `os.Logger`. |

---

## Performance Optimizations

1. **Courses Caching** — `APIService` caches the enrolled courses list in memory. When the Grades tab loads, it reuses the cached data instead of making a duplicate network call.

2. **Empty Section Filtering** — Course Detail view filters out sections with no modules, reducing unnecessary UI rendering.

3. **Grade Data Filtering** — Courses with only an ungraded course-total item are excluded from the Grades list, preventing empty sections.

4. **Lazy Loading** — `LazyVStack` is used for course card lists to defer view creation until needed.

5. **Pull-to-Refresh Cache Bypass** — `forceRefresh: true` on pull-to-refresh clears the cache and fetches fresh data.

---

## Logging & Debugging

The app includes a comprehensive logging system via `AppLogger` (in `Logger.swift`):

### Log Categories

| Category     | Method                 | Output      | Example                                 |
| ------------ | ---------------------- | ----------- | --------------------------------------- |
| **Request**  | `logRequest(_:)`       | `os.Logger` | `➡️ REQUEST: GET https://...`           |
| **Response** | `logResponse(_:data:)` | `print()`   | `✅ RESPONSE: 200` + full JSON body     |
| **Debug**    | `debug(_:)`            | `os.Logger` | `🔹 Using cached courses (7 courses)`   |
| **Error**    | `error(_:)`            | `os.Logger` | `🔴 Failed to load grades for course 8` |

### Key Design Choices

- All logging is wrapped in `#if DEBUG` — **zero overhead in Release builds**
- Response bodies use `print()` instead of `os.Logger` to avoid truncation of large JSON payloads
- Pretty-printed JSON output for easy readability
- Subsystem: `com.tecorb.iOSAssignment`, Category: `Network`

---

## Testing

The project includes **34 unit tests** and **7 UI tests** (5 flow tests + 2 launch screenshots), covering Models, ViewModels, API errors, state management, and end-to-end user flows.

### Unit Tests

Unit tests are written using Apple's modern [Swift Testing](https://developer.apple.com/documentation/testing) framework (`import Testing`).

### Test Coverage

| Suite                        | Count | Coverage                                                                   |
| ---------------------------- | ----- | -------------------------------------------------------------------------- |
| `AuthTokenResponseTests`     | 2     | Token and error response property validation                               |
| `CourseTests`                | 7     | Decoding, `displayImage`, `progressPercentage`, equality                   |
| `CourseSectionTests`         | 2     | Section/module property validation                                         |
| `GradeItemTests`             | 8     | Grade response decoding, `displayName`, `displayGrade`, `courseTotalGrade` |
| `APIErrorTests`              | 1     | `errorDescription` for all `APIError` cases                                |
| `ViewStateTests`             | 1     | `ViewState<T>` enum case handling                                          |
| `AuthManagerTests`           | 3     | `loginWithToken`, `logout`, state transitions                              |
| `LoginViewModelTests`        | 2     | Default initialization, token login delegation                             |
| `CoursesViewModelTests`      | 2     | Idle state, loading state transitions                                      |
| `GradesViewModelTests`       | 5     | `hasMeaningfulGrades` filtering logic                                      |
| `CourseDetailViewModelTests` | 1     | Initialization with `Course`                                               |

### UI Tests

UI tests use **XCTest** (`XCUITest`) and exercise the app on a live simulator, verifying navigation and view hierarchy correctness.

| Test                             | Coverage                                                     |
| -------------------------------- | ------------------------------------------------------------ |
| `testDemoTokenLoginShowsCourses` | Demo token login → **My Courses** screen appears             |
| `testTabSwitching`               | Grades tab → Profile tab navigation and title verification   |
| `testLogoutFlow`                 | Profile → **Sign Out** → login view reappears                |
| `testNavigateToCourseDetail`     | Tap first course card → back button (**My Courses**) visible |
| `testLaunchPerformance`          | Measures average app launch duration (baseline ~2.9s)        |
| `testLaunch` (Light & Dark)      | Captures launch screenshots in both appearance modes         |

### Running Tests

```bash
# Run all tests (unit + UI)
xcodebuild test -project iOSAssignment.xcodeproj -scheme iOSAssignment -destination 'platform=iOS Simulator,name=iPhone 16'

# Run only unit tests
xcodebuild test -project iOSAssignment.xcodeproj -scheme iOSAssignment -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing iOSAssignmentTests

# Run only UI tests
xcodebuild test -project iOSAssignment.xcodeproj -scheme iOSAssignment -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing iOSAssignmentUITests
```

Or in **Xcode**:

- Press **⌘U** to run all tests
- Press **⌘6** to open the Test Navigator, then click the ▶ next to **iOSAssignmentTests** or **iOSAssignmentUITests**
- Press **⌃⌥⌘U** to run the test under the cursor

### Testing Decisions

| Decision                                       | Rationale                                                                                                                              |
| ---------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| **Swift Testing (`import Testing`)**           | Modern replacement for XCTest with `#expect()` macros, better async support, and cleaner syntax                                        |
| **Direct initializations over `JSONDecoder`**  | Avoids Swift 6 strict concurrency issues with `Decodable` conformances being inferred as `@MainActor`-isolated                         |
| **`@testable import`**                         | Gives tests `internal` access to app code without adding source files to the test target (which would cause duplicate symbol errors)   |
| **`await MainActor.run {}` for `AuthManager`** | `@Observable` properties are main-actor-isolated; all mutations and assertions must execute on `MainActor`                             |
| **Mock `APIServiceProtocol`**                  | Protocol-based mocking ready for future expansion; current tests focus on state logic without live network calls                       |
| **Shared singleton cleanup**                   | Every `AuthManager` test calls `logout()` before and after to prevent state leakage between tests                                      |
| **UI Tests: label-based queries**              | Relies on visible SwiftUI text (e.g., `"Use Demo Token"`, `"Sign Out"`) rather than hardcoded accessibility identifiers                |
| **UI Tests: `XCTSkip` for empty data**         | `testNavigateToCourseDetail` skips gracefully if the demo account has no enrolled courses, avoiding brittle network-dependent failures |

---

## Known Limitations

1. **SVG Images Not Supported** — The LMS returns SVG course images which `AsyncImage` cannot render. Mitigated with custom gradient banners.

2. **Moodle Grade API Requires courseId** — The `gradereport_user_get_grade_items` API requires a `courseid` parameter, necessitating one API call per course (N+1 pattern). There is no bulk endpoint available.

3. **UserId Hardcoded for Demo** — After username/password login, the `userId` is set to the pre-generated value (`1003`) since the token endpoint doesn't return it. A production app would call `core_webservice_get_site_info` to retrieve the actual user ID.

4. **No Offline Support** — The app requires an active network connection. No local persistence (Core Data/SwiftData) is implemented.

5. **No Deep Linking** — Navigation is purely in-app; no URL scheme or Universal Links support.

---

## Tech Stack

| Component            | Technology                     |
| -------------------- | ------------------------------ |
| **Language**         | Swift 5.9+                     |
| **UI Framework**     | SwiftUI                        |
| **Minimum iOS**      | 26.0                           |
| **Architecture**     | MVVM                           |
| **Networking**       | URLSession + async/await       |
| **State Management** | @Observable + ViewState\<T\>   |
| **Logging**          | os.Logger + print (Debug only) |
| **Dependencies**     | None (pure Apple frameworks)   |
| **Build System**     | Xcode 26.4+ / xcodebuild       |

---

## Author

**Nakul Sharma**

---

_Built with SwiftUI and zero third-party dependencies._
