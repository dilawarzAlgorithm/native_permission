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
        return Stack(
          children: [
            Positioned.fill(child: CameraPreview(cameraState.controller!)),
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  onPressed: () async {
                    final file = await ref
                        .read(cameraProvider.notifier)
                        .capturePhoto();
                    if (file != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved to: ${file.path}')),
                      );
                    }
                  },
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 30,
              child: FloatingActionButton(
                heroTag: 'toggleBtn',
                onPressed: () {
                  ref.read(cameraProvider.notifier).toggleCamera();
                },
                child: const Icon(Icons.loop),
              ),
            ),
          ],
        );
      },
    );
  }
}
