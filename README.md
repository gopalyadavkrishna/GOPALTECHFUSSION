# Power Alert 2.0

Enterprise-grade electricity outage management platform.

> Stay Informed. Stay Powered.

This repository is a production-oriented foundation for:

- A Flutter Android application using Riverpod and Material 3
- Consumer, provider staff, technician, and super-admin experiences
- A Node.js/Express TypeScript API for privileged workflows
- Firebase Authentication, Firestore, Storage, FCM, Analytics, and Crashlytics
- Google Cloud Run deployment and GitHub Actions CI

## Repository layout

```text
apps/mobile/          Flutter application
services/api/         Express API for privileged operations
docs/                 Architecture, schema, and operational guidance
openapi/              Versioned REST API contract
firestore.rules       Firestore authorization policy
storage.rules         Attachment authorization policy
firestore.indexes.json
```

## Quick start

### Mobile

The checked-in source is intentionally free of generated Firebase secrets.

```powershell
cd apps/mobile
flutter create . --platforms=android
flutter pub get
flutterfire configure
flutter run --dart-define=APP_ENV=development --dart-define=USE_DEMO_DATA=false
```

Demo data is disabled by default. Use `USE_DEMO_DATA=true` only for local UI
preview builds that should not contact Firebase or the API.

### API

```powershell
cd services/api
Copy-Item .env.example .env
npm install
npm run dev
```

The API uses Application Default Credentials locally and the Cloud Run service
account in production. Never distribute a Firebase service-account key with the
mobile app or commit one to source control.

## Required cloud configuration

1. Create separate Firebase projects for development, staging, and production.
2. Enable Firebase Auth providers: Phone, Google, and Email/Password.
3. Enable Firestore, Storage, FCM, Analytics, App Check, and Crashlytics.
4. Configure Android SHA-256 fingerprints and a restricted Google Maps key.
5. Deploy rules and indexes with `firebase deploy`.
6. Set custom claims (`role`, `providerId`, `regionIds`) only from the API.
7. Deploy the API using the least-privilege service account described in
   [docs/SECURITY.md](docs/SECURITY.md).

Google Maps also requires an Android manifest API-key entry after
`flutter create` generates the platform folder. Restrict that key by Android
application ID and SHA-256 signing certificate.

## Quality gates

```powershell
cd apps/mobile
flutter analyze
flutter test

cd ../../services/api
npm run lint
npm test
npm run build
```

## Scope

This foundation includes the core user journeys, domain contracts, optional demo data,
authorization rules, validation, idempotency support, audit logging hooks,
localization scaffolding for seven languages, and CI/CD. Production rollout
still requires project-specific Firebase configuration, branding assets,
provider integrations, observability destinations, and an independent security
review.

The role selector and demo navigation are available only when explicitly
compiled with `USE_DEMO_DATA=true`. Normal builds use Firebase Auth and the
Firebase/API-backed repositories.
