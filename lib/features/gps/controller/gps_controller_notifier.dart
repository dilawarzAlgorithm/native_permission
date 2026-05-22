import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../domain/gps_state.dart';

class GpsControllerNotifier extends AsyncNotifier<CustomGpsState> {
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;

  @override
  FutureOr<CustomGpsState> build() async {
    ref.onDispose(() {
      _positionStreamSubscription?.cancel();
      _serviceStatusSubscription?.cancel();
    });

    // Listen to device hardware location toggle switches
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen((
      status,
    ) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(
          currentState.copyWith(
            isLocationServiceEnabled: status == ServiceStatus.enabled,
          ),
        );
      }
    });

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (isServiceEnabled) {
        // Automatically fetch initial coordinate position if permissions exist
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        return CustomGpsState(
          permissionStatus: permission,
          isLocationServiceEnabled: isServiceEnabled,
          currentPosition: position,
        );
      }
    }

    return CustomGpsState(
      permissionStatus: permission,
      isLocationServiceEnabled: isServiceEnabled,
    );
  }

  Future<void> requestPermissionsAndInitialize() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      await ph.openAppSettings();
      return;
    }

    final isServiceEnabled = await Geolocator.isLocationServiceEnabled();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        Position? position;
        if (isServiceEnabled) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );
        }
        return CustomGpsState(
          permissionStatus: permission,
          isLocationServiceEnabled: isServiceEnabled,
          currentPosition: position,
        );
      });
    } else {
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(permissionStatus: permission));
      }
    }
  }

  Future<void> fetchCurrentLocation() async {
    final current = state.value;
    if (current == null || !current.isLocationServiceEnabled) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return current.copyWith(currentPosition: position);
    });
  }

  void toggleLiveTracking() {
    final current = state.value;
    if (current == null) return;

    if (current.isTracking) {
      _positionStreamSubscription?.cancel();
      state = AsyncValue.data(current.copyWith(isTracking: false));
    } else {
      state = AsyncValue.data(current.copyWith(isTracking: true));
      _positionStreamSubscription?.cancel();

      _positionStreamSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter:
                  5, // Triggers notification update when user moves 5 meters
            ),
          ).listen(
            (position) {
              final val = state.value;
              if (val != null) {
                state = AsyncValue.data(
                  val.copyWith(currentPosition: position),
                );
              }
            },
            onError: (err) {
              final val = state.value;
              if (val != null) {
                state = AsyncValue.data(val.copyWith(isTracking: false));
              }
            },
          );
    }
  }
}

final gpsProvider =
    AsyncNotifierProvider.autoDispose<GpsControllerNotifier, CustomGpsState>(
      GpsControllerNotifier.new,
    );
