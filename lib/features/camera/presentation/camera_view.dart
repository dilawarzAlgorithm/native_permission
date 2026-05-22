import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:native_permission/features/camera/controller/camera_controller_notifier.dart';

class Camera extends ConsumerWidget {
  const Camera({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraAsync = ref.watch(cameraProvider);

    return cameraAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hardware Error: ${error.toString()}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (cameraState) {
        if (!cameraState.isPermissionGranted ||
            cameraState.controller == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Camera permission is required to use this feature.',
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(cameraProvider.notifier)
                        .requestPermissionOrOpenSettings();
                  },
                  child: const Text('Grant Permission'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(cameraState.controller!)),
            Positioned(
              bottom: 45,
              left: 30,
              child: GestureDetector(
                onTap: () {
                  ref.read(cameraProvider.notifier).openSystemGallery();
                },
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                    image: cameraState.lastCapturedPath != null
                        ? DecorationImage(
                            image: FileImage(
                              File(cameraState.lastCapturedPath!),
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: cameraState.lastCapturedPath == null
                      ? const Icon(Icons.photo, color: Colors.white70)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 45,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  heroTag: 'mainCaptureBtn',
                  backgroundColor: cameraState.isRecording
                      ? Colors.red
                      : Colors.white,
                  foregroundColor: cameraState.isRecording
                      ? Colors.white
                      : Colors.black,
                  onPressed: () async {
                    final notifier = ref.read(cameraProvider.notifier);
                    try {
                      if (cameraState.isVideoMode) {
                        if (cameraState.isRecording) {
                          await notifier.stopVideoRecording();
                        } else {
                          await notifier.startVideoRecording();
                        }
                      } else {
                        await notifier.capturePhoto();
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Error: ${error.toString()}'),
                          ),
                        );
                      }
                    }
                  },
                  child: Icon(
                    cameraState.isVideoMode
                        ? (cameraState.isRecording
                              ? Icons.stop
                              : Icons.videocam)
                        : Icons.camera_alt,
                  ),
                ),
              ),
            ),
            if (!cameraState.isRecording)
              Positioned(
                bottom: 45,
                right: 30,
                child: FloatingActionButton(
                  heroTag: 'toggleBtn',
                  backgroundColor: Colors.black38,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    ref.read(cameraProvider.notifier).toggleCamera();
                  },
                  child: const Icon(Icons.flip_camera_android),
                ),
              ),
            if (!cameraState.isRecording)
              Positioned(
                bottom: 115,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('PHOTO'),
                      selected: !cameraState.isVideoMode,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(cameraProvider.notifier).switchMode(false);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('VIDEO'),
                      selected: cameraState.isVideoMode,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(cameraProvider.notifier).switchMode(true);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
