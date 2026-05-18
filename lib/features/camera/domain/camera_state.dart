import 'package:camera/camera.dart';

class CustomCameraState {
  final List<CameraDescription> availableCameras;
  final CameraController? controller;
  final bool isPermissionGranted;

  CustomCameraState({
    this.availableCameras = const [],
    this.controller,
    this.isPermissionGranted = false,
  });

  CustomCameraState copyWith({
    List<CameraDescription>? availableCameras,
    CameraController? controller,
    bool? isPermissionGranted,
  }) {
    return CustomCameraState(
      availableCameras: availableCameras ?? this.availableCameras,
      controller: controller ?? this.controller,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
    );
  }
}
