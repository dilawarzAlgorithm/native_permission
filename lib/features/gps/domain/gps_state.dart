import 'package:geolocator/geolocator.dart';

class CustomGpsState {
  final LocationPermission permissionStatus;
  final bool isLocationServiceEnabled;
  final Position? currentPosition;
  final bool isTracking;

  CustomGpsState({
    this.permissionStatus = LocationPermission.unableToDetermine,
    this.isLocationServiceEnabled = false,
    this.currentPosition,
    this.isTracking = false,
  });

  CustomGpsState copyWith({
    LocationPermission? permissionStatus,
    bool? isLocationServiceEnabled,
    Position? currentPosition,
    bool? isTracking,
  }) {
    return CustomGpsState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLocationServiceEnabled:
          isLocationServiceEnabled ?? this.isLocationServiceEnabled,
      currentPosition: currentPosition ?? this.currentPosition,
      isTracking: isTracking ?? this.isTracking,
    );
  }
}
