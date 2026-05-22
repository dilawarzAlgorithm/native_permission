import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/bluetooth_controller_notifier.dart';

class Bluetooth extends ConsumerWidget {
  const Bluetooth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleAsync = ref.watch(bluetoothProvider);

    return bleAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error initializing BLE: $error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (bleState) {
        // Handle unauthorized status with an interactive action button
        if (bleState.bleStatus == BleStatus.unauthorized) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.bluetooth_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bluetooth and location permissions are required to scan for nearby hardware.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(bluetoothProvider.notifier)
                          .requestPermissionsAndStartScan();
                    },
                    child: const Text('Grant Permissions'),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle physical hardware power off switch cases
        if (bleState.bleStatus != BleStatus.ready) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Please turn on your Bluetooth radio switch hardware state: ${bleState.bleStatus.name.toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Handle Active Connection Interface Layout
        if (bleState.connectionState == DeviceConnectionState.connected ||
            bleState.connectionState == DeviceConnectionState.connecting) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.bluetooth_connected,
                          size: 48,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Target Device: ${bleState.connectedDeviceId}',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${bleState.connectionState.name.toUpperCase()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (bleState.lastReadValue != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Last Packet Read Data: ${bleState.lastReadValue.toString()}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(bluetoothProvider.notifier).disconnect(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Disconnect Call'),
                ),
              ],
            ),
          );
        }

        // Layout containing the scanning item lists with floating actions attached cleanly inside a Stack
        return Stack(
          children: [
            Positioned.fill(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  bottom: 90,
                  top: 8,
                ), // Padding so FAB doesn't clip items
                itemCount: bleState.discoveredDevices.length,
                itemBuilder: (context, index) {
                  final device = bleState.discoveredDevices[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.bluetooth),
                      title: Text(device.name),
                      subtitle: Text(device.id),
                      trailing: Text('${device.rssi} dBm'),
                      onTap: () => ref
                          .read(bluetoothProvider.notifier)
                          .connect(device.id),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: bleState.isScanning
                    ? () => ref.read(bluetoothProvider.notifier).stopScan()
                    : () => ref
                          .read(bluetoothProvider.notifier)
                          .requestPermissionsAndStartScan(),
                backgroundColor: bleState.isScanning
                    ? Colors.amber
                    : Theme.of(context).colorScheme.primary,
                child: Icon(bleState.isScanning ? Icons.stop : Icons.search),
              ),
            ),
          ],
        );
      },
    );
  }
}
