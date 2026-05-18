import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/camera_state.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraControllerNotifier extends AsyncNotifier<CustomCameraState> {
  static const _cameraIndexKey = 'selected_camera_index';
  int _selectedCameraIndex = 0;
  CameraController? _currentController;

  @override
  FutureOr<CustomCameraState> build() async {
    final status = await Permission.camera.status;

    ref.onDispose(() {
      _currentController?.dispose();
    });

    if (status.isGranted) {
      final prefs = await SharedPreferences.getInstance();
      _selectedCameraIndex = prefs.getInt(_cameraIndexKey) ?? 0;
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

  Future<void> toggleCamera() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isPermissionGranted ||
        currentState.availableCameras.isEmpty) {
      return;
    }

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % currentState.availableCameras.length;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cameraIndexKey, _selectedCameraIndex);

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _initializeHardware();
    });
  }

  Future<CustomCameraState> _initializeHardware() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No camera hardware found on this device.');
    }

    await _currentController?.dispose();

    if (_selectedCameraIndex >= cameras.length) {
      _selectedCameraIndex = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_cameraIndexKey, 0);
    }

    final targetCamera = cameras[_selectedCameraIndex];

    final controller = CameraController(
      targetCamera,
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
    try {
      final XFile file = await currentState.controller!.takePicture();

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        await Gal.requestAccess(toAlbum: true);
      }

      await Gal.putImage(file.path);
      return file;
    } catch (e) {
      rethrow;
    }
  }
}

final cameraProvider =
    AsyncNotifierProvider.autoDispose<
      CameraControllerNotifier,
      CustomCameraState
    >(CameraControllerNotifier.new);
