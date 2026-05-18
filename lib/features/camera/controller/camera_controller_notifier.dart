import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/camera_state.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraControllerNotifier extends AsyncNotifier<CustomCameraState> {
  @override
  FutureOr<CustomCameraState> build() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return _initializeHardware();
    }

    return CustomCameraState(
      availableCameras: [],
      controller: null,
      isPermissionGranted: false,
    );
  }

  Future<void> requestPermissionOrOpenSettings() async {
    final status = await Permission.camera.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        ref.invalidateSelf();
      }
    }
  }

  Future<CustomCameraState> _initializeHardware() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No camera hardware found on this device.');
    }

    final primaryCamera = cameras.first;

    final controller = CameraController(
      primaryCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize();

    ref.onDispose(() {
      controller.dispose();
    });

    return CustomCameraState(
      availableCameras: cameras,
      controller: controller,
      isPermissionGranted: true,
    );
  }

  Future<XFile?> capturePhoto() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.controller == null ||
        !currentState.controller!.value.isInitialized) {
      return null;
    }
    return await currentState.controller!.takePicture();
  }
}

final cameraProvider =
    AsyncNotifierProvider.autoDispose<
      CameraControllerNotifier,
      CustomCameraState
    >(CameraControllerNotifier.new);
