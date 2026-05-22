import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/bluetooth_state.dart';

class BluetoothControllerNotifier extends AsyncNotifier<CustomBluetoothState> {
  final _ble = FlutterReactiveBle();

  StreamSubscription<BleStatus>? _statusSubscription;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  @override
  FutureOr<CustomBluetoothState> build() async {
    ref.onDispose(() {
      _statusSubscription?.cancel();
      _scanSubscription?.cancel();
      _connectionSubscription?.cancel();
    });

    _statusSubscription = _ble.statusStream.listen((status) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(bleStatus: status));
      }
    });

    // Proactively check permission status on initialization
    final hasPermissions = await _checkCurrentPermissions();
    if (hasPermissions) {
      return CustomBluetoothState(bleStatus: _ble.status);
    }

    return CustomBluetoothState(bleStatus: BleStatus.unauthorized);
  }

  Future<bool> _checkCurrentPermissions() async {
    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    final location = await Permission.location.status;

    return scan.isGranted && connect.isGranted && location.isGranted;
  }

  Future<void> requestPermissionsAndStartScan() async {
    // Request structural OS permissions matching your architecture
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    if (statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true) {
      startScan();
    } else {
      throw Exception("Bluetooth permissions denied.");
    }
  }

  void startScan() {
    final currentState = state.value;
    if (currentState == null || currentState.isScanning) return;

    state = AsyncValue.data(
      currentState.copyWith(isScanning: true, discoveredDevices: []),
    );
    _scanSubscription?.cancel();

    _scanSubscription = _ble
        .scanForDevices(
          withServices: [], // Add targeted service UUIDs here if needed
          scanMode: ScanMode.lowLatency,
        )
        .listen(
          (device) {
            final currentVal = state.value;
            if (currentVal == null) return;

            // Prevent duplicate rendering items in UI array lists
            final exists = currentVal.discoveredDevices.any(
              (d) => d.id == device.id,
            );
            if (!exists && device.name.isNotEmpty) {
              state = AsyncValue.data(
                currentVal.copyWith(
                  discoveredDevices: [...currentVal.discoveredDevices, device],
                ),
              );
            }
          },
          onError: (err) {
            stopScan();
          },
        );
  }

  void stopScan() {
    _scanSubscription?.cancel();
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(currentState.copyWith(isScanning: false));
    }
  }

  void connect(String deviceId) {
    stopScan();
    _connectionSubscription?.cancel();

    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        connectionState: DeviceConnectionState.connecting,
        connectedDeviceId: deviceId,
      ),
    );

    _connectionSubscription = _ble
        .connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 10),
        )
        .listen(
          (update) {
            final currentVal = state.value;
            if (currentVal == null) return;

            state = AsyncValue.data(
              currentVal.copyWith(
                connectionState: update.connectionState,
                connectedDeviceId:
                    update.connectionState == DeviceConnectionState.disconnected
                    ? null
                    : deviceId,
              ),
            );
          },
          onError: (err) {
            disconnect();
          },
        );
  }

  void disconnect() {
    _connectionSubscription?.cancel();
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          connectionState: DeviceConnectionState.disconnected,
          connectedDeviceId: null,
          lastReadValue: null,
        ),
      );
    }
  }

  // Interactivity Actions Example
  Future<void> readValue(String serviceUuid, String characteristicUuid) async {
    final currentState = state.value;
    if (currentState == null || currentState.connectedDeviceId == null) return;

    final characteristic = QualifiedCharacteristic(
      characteristicId: Uuid.parse(characteristicUuid),
      serviceId: Uuid.parse(serviceUuid),
      deviceId: currentState.connectedDeviceId!,
    );

    final response = await _ble.readCharacteristic(characteristic);
    state = AsyncValue.data(currentState.copyWith(lastReadValue: response));
  }
}

final bluetoothProvider =
    AsyncNotifierProvider.autoDispose<
      BluetoothControllerNotifier,
      CustomBluetoothState
    >(BluetoothControllerNotifier.new);
