# jibgwan

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Testing

### Prerequisites

- Flutter SDK installed (`flutter --version`)
- Dart SDK available through Flutter (`dart --version`)
- Node.js 18 for Firebase Functions

### Flutter app checks

```bash
flutter pub get
flutter analyze
flutter test
```

### Firebase Functions checks

```bash
npm ci --prefix functions
npm run lint --prefix functions
npm run build --prefix functions
```
