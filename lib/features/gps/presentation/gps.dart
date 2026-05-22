// lib/features/gps/presentation/gps.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../controller/gps_controller_notifier.dart';

class Gps extends ConsumerWidget {
  const Gps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsAsync = ref.watch(gpsProvider);

    return gpsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error initializing GPS Hardware: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (gpsState) {
        // Handle Unauthorized Permissions
        if (gpsState.permissionStatus == LocationPermission.denied ||
            gpsState.permissionStatus == LocationPermission.deniedForever ||
            gpsState.permissionStatus == LocationPermission.unableToDetermine) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GPS Location permissions are required to display geographic telemetry coordinates.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(gpsProvider.notifier)
                          .requestPermissionsAndInitialize();
                    },
                    child: const Text('Grant Permissions'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle System OS Location Toggle off
        if (!gpsState.isLocationServiceEnabled) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Please enable your device location services/GPS radio via the system tray panel switch.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Active Functional Panel View Template
        final position = gpsState.currentPosition;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        gpsState.isTracking ? Icons.explore : Icons.location_on,
                        size: 56,
                        color: gpsState.isTracking
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        position != null
                            ? 'Latitude: ${position.latitude.toStringAsFixed(6)}\nLongitude: ${position.longitude.toStringAsFixed(6)}'
                            : 'No Telemetry Packet Read Yet',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (position != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Accuracy: ±${position.accuracy.toStringAsFixed(1)}m | Altitude: ${position.altitude.toStringAsFixed(1)}m',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(gpsProvider.notifier).fetchCurrentLocation(),
                icon: const Icon(Icons.my_location),
                label: const Text('Fetch Single Fix'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(gpsProvider.notifier).toggleLiveTracking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gpsState.isTracking
                      ? Colors.amber.shade800
                      : Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  gpsState.isTracking ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  gpsState.isTracking
                      ? 'Stop Live Tracking'
                      : 'Start Live Tracking Stream',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
