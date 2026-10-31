<div align="center">

# 📦 Vela

**Every parcel, in real time.**

A modern, premium Flutter parcel-tracking application featuring a live courier map, animated shipment timelines, in-app courier chat and a fully dynamic theme studio.

![Flutter](https://img.shields.io/badge/Flutter-3.27-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.6-0175C2?logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-757575?logo=materialdesign&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web-informational)

</div>

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Project Objectives](#-project-objectives)
- [Features](#-features)
- [Technologies Used](#-technologies-used)
- [UI/UX Design](#-uiux-design)
- [Project Architecture](#-project-architecture)
- [Installation](#-installation)
- [Getting Started](#-getting-started)
- [Project Structure](#-project-structure)
- [Configuration](#-configuration)
- [Screenshots & Preview](#-screenshots--preview)
- [Video Presentation](#-video-presentation)
- [Performance & Optimization](#-performance--optimization)
- [Responsive Design](#-responsive-design)
- [Security](#-security)
- [Future Improvements](#-future-improvements)
- [Author](#-author)
- [License](#-license)

---

## 🔭 Overview

**Vela** is a parcel-tracking mobile application built with Flutter and Dart. It lets users follow their shipments from pickup to doorstep through a live, animated map, review each parcel's delivery history, message their courier, and create new shipments — all wrapped in a clean, card-based interface whose accent colour can be changed on the fly.

The app is fully self-contained: it runs entirely offline, uses no third-party packages beyond the Flutter SDK, and ships with realistic sample data so every screen can be explored immediately.

> **Note:** Vela is a front-end showcase. Shipments, chats and notifications are sample data held in memory, and courier movement is simulated. There is no backend, no real GPS, and no data persistence between launches.

---

## 🎯 Project Objectives

- Deliver a **premium, real-time tracking experience** with smooth, purposeful motion.
- Demonstrate **fluid marker animation**: interpolating the courier between location fixes and rotating it to its bearing instead of letting it jump.
- Offer **user-driven personalisation** through an interactive colour selector and dark mode that re-theme the entire app instantly.
- Build every visual — map, illustrations, icons — **without external assets or APIs**, keeping the project lightweight and portable.
- Keep the codebase **clean, idiomatic and dependency-free**, relying only on Flutter's built-in state primitives.

---

## ✨ Features

### 🏠 Home
- Personalised greeting header with notification badge and quick theme access.
- **Track by ID** search bar — enter a tracking number (e.g. `M87952264`) to jump straight to its live view.
- Gradient **LIVE delivery card** with a pulsing indicator, courier info and ETA.
- Quick actions: **Scan**, **Send**, **Rates** (delivery-rate sheet) and **Theme**.
- Animated filter chips (*All · Active · Pending · Delivered*) with staggered list entrance.

### 🗺️ Live Package Tracking
- Custom-painted, pannable and zoomable **city map** (`InteractiveViewer`, up to 3.5×).
- Route rendered with a **gradient travelled segment** and a **dashed remaining segment**.
- Courier marker that **glides between simulated GPS fixes** and **rotates to its heading**, with a floating name label.
- Pulsing destination pin, origin marker, recenter button and a light/dark map toggle.
- **Draggable bottom sheet** containing:
  - Courier card with rating, vehicle, **call** (animated calling dialog) and **chat** actions.
  - Live status line with a **countdown ETA** and completion percentage.
  - Tracking ID, status badge and an **animated progress stepper**.
  - Shipment details: origin, destination, price, customer, weight and item.
  - Vertical **shipment history timeline**.
- Overflow menu: copy tracking ID to clipboard, save/unsave shipment, change colours.

### 📦 Shipments
- Summary stats: total shipments, active deliveries and total spent.
- Tabbed views: **Ongoing**, **Delivered** and **Saved**.
- **Swipe-to-save** gesture on any shipment card.

### ✉️ Send a Parcel
- Validated form for pickup address, delivery address, receiver and item.
- Animated **package-size selector** (S / M / L / XL) and **delivery-speed** options (Standard, Express, Same day).
- Optional parcel insurance toggle.
- **Animated price counter** that updates as options change.
- Success dialog with a generated tracking ID and a direct **Track** shortcut; the new shipment appears instantly across the app.

### 💬 Courier Chat
- Gradient message bubbles with timestamps and auto-scroll.
- Quick-reply chips and simulated, context-aware courier responses.

### 🔔 Inbox
- Read/unread notifications with an unread badge in the navigation bar.
- **Mark all as read**, and tap-through to the related shipment's tracking view.

### 👤 Profile & 🎨 Theme Studio
- Profile card with shipment, delivery and saved counters.
- **Interactive colour selector**:
  - 8 curated gradient presets (*Ember, Violet, Ocean, Emerald, Rose, Gold, Graphite, Lime*).
  - Custom colour via **Hue**, **Saturation** and **Brightness** gradient sliders.
  - Live preview card; secondary accent derived automatically.
- **Dark mode** switch with animated theme transitions.

---

## 🛠️ Technologies Used

| Technology | Version | Purpose |
|---|---|---|
| [Flutter](https://flutter.dev) | 3.27.3 (stable) | Cross-platform UI framework |
| [Dart](https://dart.dev) | 3.6.1 (SDK constraint `^3.6.1`) | Programming language |
| Material 3 | Built-in | Design system, components and theming |
| `cupertino_icons` | ^1.0.8 | iOS-style icon font (default Flutter dependency) |
| `flutter_test` | SDK | Widget testing |
| `flutter_lints` | ^5.0.0 | Recommended static-analysis rules |

**Key Flutter APIs:** `CustomPainter`, `PathMetric`, `AnimationController`, `TweenAnimationBuilder`, `Hero`, `DraggableScrollableSheet`, `InteractiveViewer`, `InheritedNotifier`, `ChangeNotifier`, `ValueNotifier`.

**Target platforms:** Android · iOS · Web.

---

## 🎨 UI/UX Design

Vela follows a soft, premium, card-based aesthetic:

- **Layout language** — generously rounded cards (24–32 px radii), airy spacing and a floating dark navigation bar with a raised gradient action button.
- **Colour** — a single user-selected accent (default *Ember* orange) paired with an auto-derived secondary tone, used for gradients, highlights and the map route. Neutral surfaces adapt to light and dark modes.
- **Typography** — bold, tightly tracked headings for hierarchy, with muted secondary text for metadata.
- **Illustration** — an isometric cardboard box drawn entirely in code, tinted per shipment.
- **Motion** — every interaction is animated with intent:

| Animation | Where |
|---|---|
| Elastic logo drop & progress bar | Splash screen |
| Fade + scale route transition | Splash → Home |
| Fade + slide page transitions | Tab switches, tracking screen |
| `Hero` box flight | Shipment card → tracking details |
| Staggered slide-in lists | Shipment lists, timeline, inbox |
| Interpolated, bearing-rotated marker | Live map |
| Pulsing rings | Destination pin, calling dialog |
| Blinking live dot | LIVE delivery card |
| Animated stepper fill & price counter | Progress tracker, Send screen |
| Animated theme interpolation | Colour and dark-mode changes |

> **Design inspiration:** the tracking-screen concept was inspired by a Flutter live-tracking UI showcase shared on [LinkedIn](https://www.linkedin.com/posts/hitesh-prajapat-29bb7a419_flutter-flutterdevelopment-mobileappdevelopment-ugcPost-7521417239439360000-MsP5/). Vela's name, palette, illustrations and implementation are original.

---

## 🏗️ Project Architecture

Vela uses a lightweight, layered architecture built purely on Flutter's own primitives — no external state-management library.

```
┌──────────────────────────────────────────────┐
│                  VelaApp                     │
│  ThemeScope (InheritedNotifier<ThemeController>)
│   └─ StoreScope (InheritedNotifier<AppStore>)│
│       └─ MaterialApp (light/dark themes)     │
└──────────────────────┬───────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │          Screens            │  UI composed per feature
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴──────────────┐
        │     Reusable Widgets        │  map, cards, stepper, picker…
        └──────────────┬──────────────┘
                       │
        ┌──────────────┴──────────────┐
        │   Data: Models + AppStore   │  in-memory state & logic
        └─────────────────────────────┘
```

| Layer | Responsibility |
|---|---|
| **Theme** (`ThemeController`) | Holds primary/secondary colours and theme mode; builds Material 3 `ThemeData`; notifies the app on change. |
| **Data** (`AppStore`, models) | Shipments, chats and notifications; actions such as `addShipment`, `toggleFavorite`, `send`, `markAllRead`. |
| **Scopes** (`ThemeScope`, `StoreScope`) | `InheritedNotifier` wrappers so any widget can read state and rebuild automatically. |
| **Widgets** | Self-contained, reusable UI pieces (live map, package illustration, colour picker, cards). |
| **Screens** | Feature pages wired together by a bottom-navigation shell (`RootShell`). |

---

## ⚙️ Installation

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) **3.27.x** or newer (Dart **3.6.1+**)
- Android Studio / Android SDK for Android builds
- Xcode (macOS only) for iOS builds
- Google Chrome for running on the web
- Git

Verify your environment:

```bash
flutter doctor
```

### Clone & install

```bash
git clone https://github.com/dhiasaied/Vela-.git
cd Vela-
flutter pub get
```

---

## 🚀 Getting Started

### Run in development

```bash
# List available devices
flutter devices

# Android emulator or connected device
flutter run

# Web (Chrome)
flutter run -d chrome
```

While running: press **`r`** for hot reload, **`R`** for hot restart and **`q`** to quit.

### Quality checks

```bash
flutter analyze
flutter test
```

### Production builds

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS + Xcode required)
flutter build ios --release

# Web
flutter build web --release
```

Build outputs are written to the `build/` directory (e.g. `build/app/outputs/flutter-apk/` and `build/web/`).

### Try it out

1. Wait for the splash animation, then tap the **LIVE** card on Home.
2. Watch the courier move along the route; drag the bottom sheet up for full details.
3. Tap the **palette** icon to open the Theme Studio and pick a new colour.
4. Search for `V20481937` or `K55310728` to open other shipments.
5. Create a parcel from the central **+** button and track it instantly.

---

## 🗂️ Project Structure

```
vela/
├── android/                         # Android platform project
├── ios/                             # iOS platform project
├── web/                             # Web entry point & manifest
├── lib/
│   ├── main.dart                    # App entry, scopes & MaterialApp
│   ├── data/
│   │   ├── models.dart              # Shipment, Courier, TrackingEvent, ChatMessage…
│   │   └── store.dart               # AppStore (in-memory state) + sample data
│   ├── theme/
│   │   └── theme_controller.dart    # Accent presets, ThemeController, ThemeScope
│   ├── screens/
│   │   ├── splash_screen.dart       # Animated launch screen
│   │   ├── root_shell.dart          # Floating bottom navigation shell
│   │   ├── home_screen.dart         # Dashboard, search, live card, filters
│   │   ├── tracking_screen.dart     # Live map + draggable details sheet
│   │   ├── shipments_screen.dart    # Stats & tabbed shipment lists
│   │   ├── send_screen.dart         # Create-shipment form
│   │   ├── chat_screen.dart         # Courier chat
│   │   ├── notifications_screen.dart# Inbox
│   │   └── profile_screen.dart      # Profile, appearance & settings
│   └── widgets/
│       ├── live_map.dart            # Custom-painted map & animated courier
│       ├── color_picker_sheet.dart  # Theme Studio bottom sheet
│       ├── package_box.dart         # Isometric box illustration
│       └── common.dart              # Cards, badges, stepper, list animations
├── test/
│   └── widget_test.dart             # Splash → Home and theme-change test
├── analysis_options.yaml            # Lint configuration
└── pubspec.yaml                     # Package manifest
```

---

## 🔧 Configuration

Vela requires **no API keys, environment variables or external services**. Common customisations are made directly in code:

| What | Where | How |
|---|---|---|
| Colour presets | `lib/theme/theme_controller.dart` | Edit the `accentPresets` list (`AccentPreset(name, primary, secondary)`). The first entry is the default theme. |
| Default theme mode | `lib/theme/theme_controller.dart` | Change the initial `_mode` (`ThemeMode.light` / `ThemeMode.dark`). |
| Sample shipments, couriers & notifications | `lib/data/store.dart` | Edit the `shipments` and `notifications` lists. |
| Simulated GPS update rate | `lib/widgets/live_map.dart` | Adjust `fixInterval` (default `2200 ms`) on `LiveMap`. |
| Map route | `lib/widgets/live_map.dart` | Edit the normalised `_route` points in `_MapPainter`. |
| App name / bundle ID | `pubspec.yaml`, `android/app/build.gradle`, iOS project | Application ID is currently `com.vela.vela`. |

---

## 🖼️ Screenshots & Preview

Screenshots have not been added to the repository yet. To include them, place images in a `docs/screenshots/` folder and reference them here, for example:

```markdown
| Home | Live Tracking | Theme Studio |
|:---:|:---:|:---:|
| <img src="docs/screenshots/home.png" width="240"> | <img src="docs/screenshots/tracking.png" width="240"> | <img src="docs/screenshots/theme.png" width="240"> |
```

To preview the app locally right away, run `flutter run -d chrome` and use Chrome DevTools' device toolbar (**Ctrl + Shift + M**) for a phone-sized viewport.

---

## 🎬 Video Presentation

A video walkthrough has not been published yet. Once recorded, it can be linked here, or a short GIF can be embedded directly:

```markdown
![Vela demo](docs/demo.gif)
```

---

## ⚡ Performance & Optimization

- **Zero third-party runtime packages** — a minimal dependency footprint and fast builds.
- **No image assets** — the map, route and package illustrations are drawn with `CustomPainter`, keeping the bundle small.
- **Targeted repaints** — the map painter listens directly to its progress and pulse animations (`super(repaint: …)`), so only the map canvas repaints each frame instead of rebuilding the widget tree.
- **Throttled location updates** — simulated GPS fixes arrive every ~2.2 s, and the marker is smoothly interpolated in between, avoiding jank from per-frame state updates.
- **Scoped rebuilds** — `ValueListenableBuilder` updates only the live ETA line; `InheritedNotifier` rebuilds only dependent widgets.
- **`const` constructors** used throughout to let Flutter skip unchanged subtrees.
- **Icon tree-shaking** in release builds reduces the Material Icons font to only the glyphs used.
- **Proper lifecycle management** — every `AnimationController`, `Timer` and `TextEditingController` is disposed.

---

## 📱 Responsive Design

Vela is designed **mobile-first for portrait phones**, and adapts gracefully across device sizes:

- `SafeArea` handling for notches, status bars and gesture areas.
- Flexible `Row`/`Expanded` layouts and `LayoutBuilder`-based components (progress stepper, colour sliders) that scale to the available width.
- Chat bubbles constrained relative to screen width via `MediaQuery`.
- The map fills any viewport and supports pinch-to-zoom and panning.
- `DraggableScrollableSheet` with snap points lets details expand or collapse on any screen height.
- Full **light and dark mode** support.

> On wide desktop browsers the interface renders as a stretched phone layout; a dedicated tablet/desktop layout is not yet implemented.

---

## 🔒 Security

- The app makes **no network requests** and connects to no backend or third-party service.
- **No credentials, API keys or secrets** are stored in the codebase.
- No device permissions (location, camera, contacts) are requested; location tracking is simulated.
- All data lives **in memory only** and is discarded when the app closes — nothing is written to disk.
- Form inputs on the *Send* screen are validated before a shipment is created.

When connecting Vela to a real backend, it is recommended to use HTTPS, secure token storage, server-side validation and runtime location-permission handling.

---

## 🧭 Future Improvements

- 🗺️ Integrate a real map provider with live GPS and geocoding.
- ☁️ Connect to a backend API for real shipments, couriers and pricing.
- 💾 Persist preferences (theme colour, dark mode) and data locally.
- 🔐 Add user authentication and account management.
- 🔔 Push notifications for delivery status updates.
- 📷 Real QR/barcode scanning for tracking numbers.
- 🌍 Localisation (e.g. French and Arabic, including RTL support).
- 🖥️ Adaptive layouts for tablets and desktop web.
- 🧪 Broader widget, golden and integration test coverage.

---

## 👤 Author

**Dhia Eddine Saied**

- GitHub: [@dhiasaied](https://github.com/dhiasaied)

Contributions, issues and suggestions are welcome — feel free to open an issue or submit a pull request.

---

## 📄 License

No license has been specified for this project yet, so all rights are reserved by default. To make Vela open source, add a `LICENSE` file (for example, the [MIT License](https://choosealicense.com/licenses/mit/)) to the repository root and update this section accordingly.

---

<div align="center">

Made with 💙 using Flutter

</div>
