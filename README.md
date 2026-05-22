# Native Permission

A native services sandbox app designed to isolate and master low-level platform features in Flutter. Built with a strict separation of user interface and hardware communication, the application implements native camera streams, background worker lifecycles with runtime toggle controls, GPS tracking, and Bluetooth device scanning—all reactively coordinated using Riverpod state management.

## Tech Stack

- **Framework**: Flutter
- **State Management**: Riverpod (flutter_riverpod)
- **Hardware Interfacing**:
  - `camera` & `gal` (Native camera and gallery streams)
  - `geolocator` (GPS & Telemetry)
  - `flutter_reactive_ble` (Bluetooth Low Energy)
  - `workmanager` (Background Tasks / Isolate bridging)
  - `permission_handler` (OS-level security constraints)

## Architecture & Low-Level Design (LLD)

This project strictly enforces a **Feature-First (Domain-Driven)** architecture. The UI is completely decoupled from hardware logic.

**Key Architectural Highlights**:

- **Reactive Hardware States**: Native hardware states (e.g., Bluetooth scanning, GPS signal loss, Camera permission denial) are strictly typed using custom Domain models and reactively pushed to the UI via Riverpod `AsyncNotifier`.

- **Isolate Bridging**: The background sync engine runs on a separate Dart Isolate. Data synchronization between the background thread and the main UI thread is safely bridged using `SharedPreferences` with explicit cache-reloading to prevent stale memory reads.

## Getting Started / Installation

Because this application communicates directly with the iOS and Android hardware kernels, you must configure native permissions before running the app.

1. Clone & Install

```bash
git clone [https://github.com/dilawarzAlgorithm/native_permission.git](https://github.com/dilawarzAlgorithm/native_permission.git)
cd native_permission_sandbox
flutter pub get
```

2. Run the App

Note: Bluetooth and Camera features cannot be tested on a standard iOS Simulator. A physical device is highly recommended.

```bash
flutter run
```

## Known Constraints & Edge Cases Handled

- **Silent Permission Failures**: Handled edge cases where Android/iOS silently refuse to re-prompt for permissions if the user previously selected "Never Ask Again," dynamically routing the user to the OS Settings app.

- **Stream Memory Leaks**: Hardware streams (BLE scanning, GPS continuous tracking) are strictly bound to Riverpod's `onDispose` lifecycle to prevent background battery drain when the UI is unmounted.
