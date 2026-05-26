part of 'connect_cubit.dart';

enum ConnectStatus { init, connecting, success, error }

extension ConnectStatusX on ConnectStatus {
  bool get isInit => this == ConnectStatus.init;
  bool get isConnecting => this == ConnectStatus.connecting;
  bool get isSuccess => this == ConnectStatus.success;
  bool get isError => this == ConnectStatus.error;
}

enum ConnectMode { wifi, bluetooth }

extension ConnectModeX on ConnectMode {
  bool get isWifi => this == ConnectMode.wifi;
  bool get isBluetooth => this == ConnectMode.bluetooth;
}

class BluetoothDeviceInfo extends Equatable {
  final String name;
  final String address;

  const BluetoothDeviceInfo({required this.name, required this.address});

  @override
  List<Object?> get props => [name, address];
}

class ConnectState extends Equatable {
  final String ipConnect;
  final GamepadConnection? connection;
  final ConnectStatus status;
  final ConnectMode mode;
  final List<BluetoothDeviceInfo> bluetoothDevices;
  final BluetoothDeviceInfo? selectedBluetoothDevice;
  final bool isBluetoothLoading;
  final String errorMessage;

  const ConnectState({
    this.ipConnect = '',
    this.connection,
    this.status = ConnectStatus.init,
    this.mode = ConnectMode.wifi,
    this.bluetoothDevices = const [],
    this.selectedBluetoothDevice,
    this.isBluetoothLoading = false,
    this.errorMessage = '',
  });

  ConnectState copyWith({
    String? ipConnect,
    GamepadConnection? connection,
    ConnectStatus? status,
    ConnectMode? mode,
    List<BluetoothDeviceInfo>? bluetoothDevices,
    BluetoothDeviceInfo? selectedBluetoothDevice,
    bool? isBluetoothLoading,
    String? errorMessage,
  }) => ConnectState(
    ipConnect: ipConnect ?? this.ipConnect,
    connection: connection ?? this.connection,
    status: status ?? this.status,
    mode: mode ?? this.mode,
    bluetoothDevices: bluetoothDevices ?? this.bluetoothDevices,
    selectedBluetoothDevice:
        selectedBluetoothDevice ?? this.selectedBluetoothDevice,
    isBluetoothLoading: isBluetoothLoading ?? this.isBluetoothLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    ipConnect,
    connection,
    status,
    mode,
    bluetoothDevices,
    selectedBluetoothDevice,
    isBluetoothLoading,
    errorMessage,
  ];
}
