# EasyRecipe

EasyRecipe is a modern, cross-platform recipe management app built with Flutter.  
It features local and cloud storage, multi-language support, and real-time weather-based cooking suggestions.

## Features

- Multi-language UI (English & Traditional Chinese)
- Geolocation-based weather & cooking suggestion card
- Motivational cooking quote of the day
- Recipe list, search, add, edit, delete (with images)
- Secure Google Sign-In
- Cloud backup and restore (Firebase Firestore)
- Encrypted local storage (Hive)
- Responsive UI (dark/light mode)

## Technical Highlights

- **Flutter & Dart** for cross-platform development
- **Hive** for fast, encrypted local storage
- **Firebase Firestore** for cloud sync & backup
- **Google Auth** for secure login
- **Open-Meteo API & Geolocator** for live, location-based weather
- **Instant language and theme switch**
- **Comprehensive form validation and user feedback**

## Getting Started

1. Clone this repo:  
   `git clone https://github.com/yourusername/easyrecipe.git`
2. Install packages:  
   `flutter pub get`
3. Set up Firebase:  
   - Add your `google-services.json` (Android) and/or `GoogleService-Info.plist` (iOS)
   - Enable Authentication and Firestore in your Firebase project
4. Run the app:  
   `flutter run`

## API Keys & Permissions

- Open-Meteo (no key needed)
- Firebase configuration required
- Location permission for weather card


