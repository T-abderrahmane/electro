# Electro

Electro is a service platform that connects clients with electricians and gives administrators a full control panel to manage the ecosystem.

The project is split into two applications:

- `admin-panel`: a Next.js dashboard for managing users, requests, subscriptions, payments, and analytics.
- `elec_app`: a Flutter mobile app for clients and electricians to create requests, send offers, follow jobs, and complete services.

## Project Overview

Electro is designed to streamline the whole electrical service workflow:

- Clients create service requests from the mobile app.
- Electricians browse available requests, send offers, and manage their assigned jobs.
- Admins monitor the platform, verify accounts, track activity, and manage the live data.

The app supports Arabic and French UI text, realistic seed data, refresh actions, request completion flow, and a dashboard backed by real data instead of static mock values.

## Main Features

### Client App

- Create new service requests
- Browse request details and received offers
- Accept an offer and follow the request status
- See completed requests marked as finished
- Refresh data from the server

### Electrician App

- Browse open requests by wilaya and commune
- Filter requests by location
- Send offers with price and estimated time
- Mark a job as completed
- View active work and work history
- Manage profile, notifications, support, and subscription status

### Admin Panel

- Manage clients and electricians
- Review requests, offers, and payments
- Activate or suspend accounts
- Approve or reject payments
- View analytics and platform activity
- Work with real persisted JSON data

## Technology Stack

### Admin Panel

- Next.js 14
- React 18
- TypeScript
- Tailwind CSS
- Recharts
- Lucide React

### Mobile App

- Flutter
- Dart
- Provider
- HTTP
- Google Fonts
- Flutter localization

## Repository Structure

```text
.
├── admin-panel/        # Next.js admin dashboard
├── elec_app/           # Flutter mobile app
└── README.md           # Project overview
```

## Admin Panel Structure

```text
admin-panel/
├── data/
│   └── database.json   # Persisted app data
├── src/
│   ├── app/            # Next.js pages and API routes
│   ├── components/     # Shared UI components
│   ├── context/        # App and UI contexts
│   ├── data/           # Seed and mock data models
│   └── lib/            # Database helpers
```

## Mobile App Structure

```text
elec_app/
├── lib/
│   ├── models/         # Data models and enums
│   ├── providers/      # App state and API logic
│   ├── screens/        # Client and electrician screens
│   ├── services/       # API client layer
│   ├── utils/          # Constants, theme, localization
│   └── data/           # Local mock data
├── android/
├── ios/
├── web/
└── windows/
```

## Requirements

- Node.js 18+ for the admin panel
- Flutter 3.7+ for the mobile app
- For Android APK builds, Java 17 is required

## Run the Admin Panel

```bash
cd admin-panel
npm install
npm run dev
```

To create a production build:

```bash
npm run build
npm run start
```

## Run the Flutter App

```bash
cd elec_app
flutter pub get
flutter run -d chrome
```

To build an Android APK:

```bash
flutter build apk
```

## Data and State

- The admin panel uses a JSON-backed local database in `admin-panel/data/database.json`.
- The dashboard loads real data through API routes and context providers.
- The mobile app uses provider-based state management and refresh helpers to keep request data in sync.

## Localization

The interface supports Arabic and French text throughout the main screens, so the platform can be presented to a bilingual audience.

## Notes

- Completed jobs are moved out of the active request lists and shown in the relevant history views.
- The dashboard aggregates real counts for users, requests, offers, subscriptions, and recent activity.
- The project is ready to be presented as a full end-to-end service platform for electricians.

## License

This project is for academic, demo, or internal use unless a separate license is added.