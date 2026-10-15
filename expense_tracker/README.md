# Expense Tracker (Flutter)

Track money expenses: add, delete (swipe), monthly total and per-category totals. Data is stored locally.

## Build APK
```
flutter create --platforms=android .
flutter pub get
flutter build apk --release
```
The GitHub Actions workflow `Build APK` does this and uploads the APK as an artifact.
