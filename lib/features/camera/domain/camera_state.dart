import 'package:camera/camera.dart';

class CustomCameraState {
  final List<CameraDescription> availableCameras;
  final CameraController? controller;
  final bool isPermissionGranted;
  final bool enableAudio;
  final bool isRecording;
  final bool isVideoMode;
  final String? lastCapturedPath;

  CustomCameraState({
    this.availableCameras = const [],
    this.controller,
    this.isPermissionGranted = false,
    this.enableAudio = false,
    this.isRecording = false,
    this.isVideoMode = false,
    this.lastCapturedPath,
  });

  CustomCameraState copyWith({
    List<CameraDescription>? availableCameras,
    CameraController? controller,
    bool? isPermissionGranted,
    bool? enableAudio,
    bool? isRecording,
    bool? isVideoMode,
    String? lastCapturedPath,
  }) {
    return CustomCameraState(
      availableCameras: availableCameras ?? this.availableCameras,
      controller: controller ?? this.controller,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      enableAudio: enableAudio ?? this.enableAudio,
      isRecording: isRecording ?? this.isRecording,
      isVideoMode: isVideoMode ?? this.isVideoMode,
      lastCapturedPath: lastCapturedPath ?? this.lastCapturedPath,
    );
  }
}
