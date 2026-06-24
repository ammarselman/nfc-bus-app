# NFC Bus App

NFC Bus is a Flutter mobile application for school bus attendance and live bus tracking.
The app helps drivers scan student NFC cards or wristbands, send attendance events to the backend, track bus location, report incidents, and allows parents to monitor their children’s bus status, attendance history, notifications, and live bus location.

## Features

### Authentication

* Login using email and password
* Role-based navigation

  * Driver dashboard
  * Parent dashboard
* Session saving using local storage
* Token-based API requests

### Driver Features

* Driver home dashboard
* View current trip status
* View number of students currently onboard
* NFC scan for student attendance

  * Scan NFC card or wristband
  * Send check-in/check-out event to backend
  * Handle NFC unavailable cases
* Offline scan queue

  * Save pending scans locally when network fails
  * Sync pending scans later
* View onboard students list
* Live bus location tracking

  * Send current driver/bus location to backend
  * Update location periodically
  * Display location on map
* Incident reporting

  * Delay
  * Breakdown
  * Accident
  * Other
* Offline incident queue

  * Save incident reports locally when network fails
  * Sync pending incidents later

### Parent Features

* Parent home dashboard
* View linked children
* View child current bus status
* View live bus location on map
* View attendance history
* Filter attendance records by date range
* View notifications
* Infinite scroll notifications list
* Local notifications for bus updates

### Notifications

* Local notification support
* Bus update notification channel
* Notification polling from backend API
* Parent notification list with pagination

### Maps and Location

* Bus location display using OpenStreetMap tiles
* Map implementation using `flutter_map`
* Location access using `geolocator`
* Live location updates for driver and parent views

### Offline Support

* Pending NFC scans are saved locally
* Pending driver incidents are saved locally
* Local storage is handled using `SharedPreferences`
* Local notifications database support using `sqflite`

## Tech Stack

* Flutter
* Dart
* GetX for state management, routing, and dependency injection
* HTTP package for API communication
* Shared Preferences for local session and queue storage
* Flutter NFC Kit for NFC scanning
* Geolocator for location services
* Flutter Map with OpenStreetMap tiles
* LatLong2 for map coordinates
* Flutter Local Notifications
* Sqflite for local notification storage
* Intl for date and time formatting

## Project Structure

```text
lib/
├── assets/
│   └── bus.png
│
├── core/
│   ├── config.dart
│   └── http/
│       ├── api_client.dart
│       └── api_paths.dart
│
├── data/
│   ├── local/
│   │   └── notifications_db.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── driver_repository.dart
│       └── parent_repository.dart
│
├── modules/
│   ├── auth/
│   ├── driver/
│   │   ├── incident/
│   │   ├── map/
│   │   ├── scan/
│   │   └── students/
│   └── parent/
│       ├── history/
│       ├── map/
│       └── notifications/
│
├── routes/
│   ├── app_pages.dart
│   └── app_routes.dart
│
├── services/
│   ├── incident_queue_service.dart
│   ├── location_service.dart
│   ├── nfc_service.dart
│   ├── notification_service.dart
│   ├── notifications_api_poller.dart
│   ├── offline_queue_service.dart
│   └── session_service.dart
│
└── main.dart
```

## API Configuration

The API base URL is configured in:

```text
lib/core/config.dart
```

Current example:

```dart
class AppConfig {
  static const String baseUrl = 'http://192.168.1.102:8000/api/';
}
```

Before running the app with a real backend, update the `baseUrl` to your backend server URL.

## API Endpoints

API paths are managed in:

```text
lib/core/http/api_paths.dart
```

Main endpoint groups:

### Auth

```text
auth/login
auth/register
```

### Driver

```text
driver/attendance/scan
driver/onboard
driver/trip/current
driver/location
driver/incident
```

### Parent

```text
parent/child
parent/location
parent/attendance
parent/notifications
```

## Main Screens

### Driver

* Driver Home
* NFC Scan
* Onboard Students
* Driver Live Map
* Incident Report

### Parent

* Parent Home
* Parent Live Bus Map
* Attendance History
* Notifications

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/nfc-bus-app.git
```

### 2. Open the project

```bash
cd nfc-bus-app
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

## Android Permissions

The app may require the following Android permissions depending on your final configuration:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

Make sure these permissions are configured correctly in:

```text
android/app/src/main/AndroidManifest.xml
```

## Important Notes

* Update the backend API URL before testing with a real server.
* Local IP addresses such as `192.168.x.x` only work on the same local network.
* Do not upload secret files, keystore files, or environment files to GitHub.
* NFC scanning works only on devices that support NFC.
* Location services must be enabled on the device for live tracking.
* The project uses GetX bindings to inject controllers and repositories.

## Author

Developed by Ammar Sleman.
