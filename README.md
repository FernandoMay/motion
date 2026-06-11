# Motion Mail

A Flutter email client app built with Material 3 design and Provider state management.

## Stack

- **Flutter** — Cross-platform mobile app (SDK >=3.1.0)
- **Material 3** — Modern design system with dynamic color theming
- **Provider** — State management
- **flutter_gallery_assets** — Shared email demo assets

## Features

- Email inbox with multiple folders (Inbox, Starred, Sent, Trash, Spam, Drafts)
- Email compose with subject, sender, and recipient fields
- Email search page with history
- Dark mode support
- Animated bottom drawer navigation
- Swipe-to-delete and swipe-to-star gestures

## Getting Started

```bash
flutter pub get
flutter run
```

## Running Tests

```bash
flutter test
```

## CI/CD

This project uses GitHub Actions for continuous integration. The workflow runs on every push and pull request to the main branch:
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
