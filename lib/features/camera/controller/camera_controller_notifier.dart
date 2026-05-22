import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/camera_state.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraControllerNotifier extends AsyncNotifier<CustomCameraState> {
  static const _cameraIndexKey = 'selected_camera_index';
  static const _isVideoModeKey = 'is_video_mode_key';
  static const _lastPathKey = 'last_captured_file_path';

  int _selectedCameraIndex = 0;
  bool _isVideoMode = false;
  String? _lastCapturedPath;
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
      _isVideoMode = prefs.getBool(_isVideoModeKey) ?? false;
      _lastCapturedPath = prefs.getString(_lastPathKey);

      return _initializeHardware(
        enableAudio: _isVideoMode,
        isVideoMode: _isVideoMode,
      );
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

  Future<CustomCameraState> _initializeHardware({
    required bool enableAudio,
    required bool isVideoMode,
  }) async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No camera hardware found on this device.');
    }

    await _currentController?.dispose();
    _currentController = null;

    if (_selectedCameraIndex >= cameras.length) {
      _selectedCameraIndex = 0;
    }

    final targetCamera = cameras[_selectedCameraIndex];
    final controller = CameraController(
      targetCamera,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    await controller.initialize();
    _currentController = controller;

    return CustomCameraState(
      availableCameras: cameras,
      controller: controller,
      isPermissionGranted: true,
      enableAudio: enableAudio,
      isVideoMode: isVideoMode,
      isRecording: false,
      lastCapturedPath: _lastCapturedPath,
    );
  }

  Future<void> toggleCamera() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isPermissionGranted ||
        currentState.isRecording) {
      return;
    }

    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % currentState.availableCameras.length;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_cameraIndexKey, _selectedCameraIndex);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _initializeHardware(
        enableAudio: _isVideoMode,
        isVideoMode: _isVideoMode,
      );
    });
  }

  Future<void> switchMode(bool toVideo) async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.isPermissionGranted ||
        currentState.isRecording) {
      return;
    }

    _isVideoMode = toVideo;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isVideoModeKey, _isVideoMode);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return _initializeHardware(
        enableAudio: _isVideoMode,
        isVideoMode: _isVideoMode,
      );
    });
  }

  Future<void> capturePhoto() async {
    final currentState = state.value;
    if (currentState == null || currentState.controller == null) return;

    try {
      final XFile file = await currentState.controller!.takePicture();

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);

      await Gal.putImage(file.path);

      // Update our thumbnail cache
      _lastCapturedPath = file.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastPathKey, file.path);

      state = AsyncValue.data(
        currentState.copyWith(lastCapturedPath: file.path),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startVideoRecording() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.controller == null ||
        currentState.isRecording) {
      return;
    }
    try {
      if (currentState.enableAudio) {
        final micStatus = await Permission.microphone.request();
        if (!micStatus.isGranted) {
          throw Exception("Microphone permission required.");
        }
      }
      await currentState.controller!.startVideoRecording();
      state = AsyncValue.data(currentState.copyWith(isRecording: true));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> stopVideoRecording() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.controller == null ||
        !currentState.isRecording) {
      return;
    }
    try {
      final XFile videoFile = await currentState.controller!
          .stopVideoRecording();

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) await Gal.requestAccess(toAlbum: true);

      await Gal.putVideo(videoFile.path);

      // Update our thumbnail cache
      _lastCapturedPath = videoFile.path;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastPathKey, videoFile.path);

      state = AsyncValue.data(
        currentState.copyWith(
          isRecording: false,
          lastCapturedPath: videoFile.path,
        ),
      );
    } catch (e) {
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isRecording: false));
      }
      rethrow;
    }
  }

  Future<void> openSystemGallery() async {
    await Gal.open();
  }
}

final cameraProvider =
    AsyncNotifierProvider.autoDispose<
      CameraControllerNotifier,
      CustomCameraState
    >(CameraControllerNotifier.new);
