# EasyRecipe Flutter App

**Phase 1** - Project initialized with folder structure, pubspec.yaml, and basic main.dart.

## Features

- Flutter app setup
- Initial folder structure
- Placeholder welcome screen
- Prepared for Hive, image picker, localization



## This app uses the following mechanisms to protect user data:

    All recipe data is stored locally using Hive (AES encryption supported via encryptionKey).

    After Google login, your data is synced to a personal Firestore folder (UID-isolated, accessible only by you).

    All cloud data transfers are secured by Google Authentication; no third party can access your data.

    You can sign out anytime, and your local data remains private.
