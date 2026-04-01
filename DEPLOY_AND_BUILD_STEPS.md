# Deploy Guide for Render + Vercel and App Build

This guide matches your hosting choice:
1. Render for backend API with persistent data
2. Vercel for frontend/admin web
3. Flutter app build and release

--------------------------------------------------

## 1) Recommended Architecture

Use this split in production:

1. Render hosts API routes and database access (persistent writes)
2. Vercel hosts frontend pages (fast global CDN)
3. Flutter app points to Render API URL

Why this is important:

- Your current project uses file-based storage in admin-panel/data/database.json
- File writes are not reliable for serverless production
- Render or external DB solves persistence

--------------------------------------------------

## 2) Prerequisites

Install/update:

- Git
- Node.js 20.x
- npm
- Flutter SDK
- Android Studio + SDK + Java 17
- Render account
- Vercel account
- GitHub account

Verify:

node -v
npm -v
flutter --version

--------------------------------------------------

## 3) Push Project to GitHub

From repository root:

git init
git add .
git commit -m "Deploy setup"
git branch -M main
git remote add origin YOUR_GITHUB_REPO_URL
git push -u origin main

--------------------------------------------------

## 4) Deploy Backend on Render

Note:
- If you keep Next.js API routes, Render must run as a Web Service.
- Better long-term: move DB from JSON file to PostgreSQL.

Step-by-step:

1. Open Render dashboard
2. Click New + and choose Web Service
3. Connect your GitHub repo
4. Configure service:
   - Name: elcv2-api (example)
   - Root Directory: admin-panel
   - Environment: Node
   - Build Command: npm install and npm run build
   - Start Command: npm run start
5. Add environment variables if needed
6. Deploy

After deploy, copy your API base URL, for example:

https://your-render-service.onrender.com

Test endpoints:

- https://your-render-service.onrender.com/api/requests
- https://your-render-service.onrender.com/api/offers
- https://your-render-service.onrender.com/api/messages

--------------------------------------------------

## 5) Deploy Frontend on Vercel

Step-by-step:

1. Open Vercel dashboard
2. Add New Project
3. Import same GitHub repository
4. Configure:
   - Framework: Next.js
   - Root Directory: admin-panel
   - Build Command: npm run build
5. Add env variable for frontend API target:
   - NEXT_PUBLIC_API_BASE_URL = your Render URL + /api
6. Deploy

Example:

NEXT_PUBLIC_API_BASE_URL=https://your-render-service.onrender.com/api

Important:
- Update frontend/API client code to use NEXT_PUBLIC_API_BASE_URL instead of localhost.

--------------------------------------------------

## 6) Configure Flutter App for Production API

Current app supports API override through compile-time variable.

For release builds, pass Render API base URL:

flutter build apk --release --dart-define=API_BASE_URL=https://your-render-service.onrender.com/api

flutter build appbundle --release --dart-define=API_BASE_URL=https://your-render-service.onrender.com/api

--------------------------------------------------

## 7) Build Flutter App (APK + AAB)

From elec_app folder:

flutter clean
flutter pub get

Build APK (manual install/testing):

flutter build apk --release --dart-define=API_BASE_URL=https://your-render-service.onrender.com/api

Output:

elec_app/build/app/outputs/flutter-apk/app-release.apk

Build AAB (Play Store):

flutter build appbundle --release --dart-define=API_BASE_URL=https://your-render-service.onrender.com/api

Output:

elec_app/build/app/outputs/bundle/release/app-release.aab

--------------------------------------------------

## 8) Android Signing (Play Store)

If keystore is not prepared yet:

keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

Create file elec_app/android/key.properties:

storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../upload-keystore.jks

Then rebuild AAB.

--------------------------------------------------

## 9) Release Checklist

Before going live:

1. Render API works for create/update/delete operations
2. Vercel frontend reads and writes through Render URL
3. Flutter app built with --dart-define API_BASE_URL pointing to Render
4. Login, requests, offers, messages tested on production URLs
5. Keep secrets only in Render/Vercel env vars, never in repo

--------------------------------------------------

## 10) Common Problems

Problem: npm run dev or npm run build fails with engine warnings
Fix: Use Node 20

nvm install 20
nvm use 20

Problem: Data resets after deploy
Fix: Do not depend on local JSON file in production. Move to managed database.

Problem: Flutter app still calls localhost
Fix: Rebuild with --dart-define=API_BASE_URL=https://your-render-service.onrender.com/api

--------------------------------------------------

If you want, next I can generate a second Markdown file with exact migration steps from JSON file storage to PostgreSQL (schema + API update order + rollout plan).
