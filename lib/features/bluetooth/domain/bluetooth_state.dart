import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class CustomBluetoothState {
  final BleStatus bleStatus;
  final List<DiscoveredDevice> discoveredDevices;
  final bool isScanning;
  final DeviceConnectionState connectionState;
  final String? connectedDeviceId;
  final List<int>? lastReadValue;

  CustomBluetoothState({
    this.bleStatus = BleStatus.unknown,
    this.discoveredDevices = const [],
    this.isScanning = false,
    this.connectionState = DeviceConnectionState.disconnected,
    this.connectedDeviceId,
    this.lastReadValue,
  });

  CustomBluetoothState copyWith({
    BleStatus? bleStatus,
    List<DiscoveredDevice>? discoveredDevices,
    bool? isScanning,
    DeviceConnectionState? connectionState,
    String? connectedDeviceId,
    List<int>? lastReadValue,
  }) {
    return CustomBluetoothState(
      bleStatus: bleStatus ?? this.bleStatus,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
      isScanning: isScanning ?? this.isScanning,
      connectionState: connectionState ?? this.connectionState,
      connectedDeviceId: connectedDeviceId ?? this.connectedDeviceId,
      lastReadValue: lastReadValue ?? this.lastReadValue,
    );
  }
}
