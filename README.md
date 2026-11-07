# Campus Incident Reporter

A Flutter app for reporting campus issues at ALU, like broken projectors, dead sockets, water outages or safety concerns, and following them until they are fixed.

Students submit reports and can see what others have reported. If someone has already reported the same problem, they tap "I noticed this too" instead of filing a duplicate. Campus staff see every report, can sort by how many people are affected, and update the status as work progresses.

Demo video: https://youtu.be/oqXp9AMMfYU

## Features

- Sign up and log in with an ALU email only (@alustudent.com or @alueducation.com), with email verification
- Submit a report with a category, description, location and an optional photo
- Report anonymously (hidden from other students, still visible to staff)
- Campus feed and "My Reports", with search and filters by status and category
- Report details with a status timeline and activity history
- Edit or delete your own report while it is still Submitted
- "I noticed this too" to show how many people are affected
- Staff dashboard to update a report's status with a note, sorted by newest or most affected

## Built with

- Flutter and Dart
- Provider for state management
- Firebase Authentication and Cloud Firestore
- Cloudinary for photo uploads (used instead of Firebase Storage)

## Running the app

You need Flutter installed and an Android device or emulator.

```
git clone https://github.com/Bangnyfe/formative-2-Mobile-App-Dev.git
cd formative-2-Mobile-App-Dev
flutter pub get
flutter run
```

The Firebase config files are already included, so the app connects to the project's Firebase backend.

To run the tests:

```
flutter test
```

## Roles

Every new account is a student. A staff account is created by changing the `role` field in the user's Firestore document from `student` to `staff` in the Firebase Console. Users cannot change their own role from the app.

Test account details are in the technical report.

## Firestore security rules

The rules are in `firestore.rules`. To deploy them with the Firebase CLI:

```
firebase deploy --only firestore:rules
```

## Demo data

`tools/seed` has a script that creates demo accounts and sample reports using the Firebase Admin SDK. It needs a service account key from the Firebase Console. Keep that file outside the project folder and never commit it.

```
cd tools/seed
npm install
node seed_demo_data.js path/to/service-account.json
node seed_demo_data.js path/to/service-account.json --clean
```

The `--clean` option removes the demo accounts and reports again.

## Project structure

```
lib/
  core/       theme, constants, validators, formatters
  models/     Incident, AppUser, status and category enums
  services/   Firebase and Cloudinary calls
  providers/  app state (auth, reports, staff tools, report form)
  screens/    app screens
  widgets/    reusable widgets
```

## Author

Ahmad Musa Daib
