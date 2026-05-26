import 'dart:async';

import 'package:app_controller/features/gamepad/data/gamepad_connection.dart';
import 'package:bluetooth_serial_android/bluetooth_serial_android.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
part 'connect_state.dart';

class ConnectCubit extends Cubit<ConnectState> {
  ConnectCubit() : super(ConnectState());

  static const _serialUuid = '00001101-0000-1000-8000-00805F9B34FB';

  void handleIPChange(String ip) {
    emit(
      state.copyWith(
        status: ConnectStatus.init,
        ipConnect: ip.trim(),
        errorMessage: '',
      ),
    );
  }

  void setMode(ConnectMode mode) {
    emit(
      state.copyWith(status: ConnectStatus.init, mode: mode, errorMessage: ''),
    );
  }

  void selectBluetoothDevice(BluetoothDeviceInfo device) {
    emit(
      state.copyWith(
        status: ConnectStatus.init,
        selectedBluetoothDevice: device,
        errorMessage: '',
      ),
    );
  }

  Future<void> loadBluetoothDevices() async {
    emit(state.copyWith(isBluetoothLoading: true, errorMessage: ''));

    try {
      await FlutterBluetoothSerial.ensurePermissions();
      final pairedDevices = await FlutterBluetoothSerial.getPairedDevices();
      final devices = pairedDevices
          .map(
            (device) => BluetoothDeviceInfo(
              name: device['name']?.trim().isNotEmpty == true
                  ? device['name']!.trim()
                  : 'Unknown device',
              address: device['address']?.trim() ?? '',
            ),
          )
          .where((device) => device.address.isNotEmpty)
          .toList();

      emit(
        state.copyWith(
          bluetoothDevices: devices,
          selectedBluetoothDevice: devices.isNotEmpty
              ? devices.first
              : state.selectedBluetoothDevice,
          isBluetoothLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('Bluetooth device loading failed: $e');
      emit(
        state.copyWith(
          status: ConnectStatus.error,
          isBluetoothLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> connect() async {
    emit(state.copyWith(status: ConnectStatus.connecting, errorMessage: ''));

    if (state.mode.isBluetooth) {
      await _connectBluetooth();
      return;
    }

    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    WebSocketChannel? channel;
    try {
      final uri = _buildUri(state.ipConnect);
      channel = WebSocketChannel.connect(uri);
      await channel.ready.timeout(
        const Duration(seconds: 6),
        onTimeout: () {
          throw TimeoutException('Timed out connecting to $uri');
        },
      );
      emit(
        state.copyWith(
          status: ConnectStatus.success,
          connection: WebSocketGamepadConnection(channel),
        ),
      );
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      await channel?.sink.close();
      emit(
        state.copyWith(status: ConnectStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _connectBluetooth() async {
    try {
      final device = state.selectedBluetoothDevice;
      if (device == null) {
        throw const FormatException('Select a paired Bluetooth device first');
      }

      await FlutterBluetoothSerial.ensurePermissions();
      final connected = await FlutterBluetoothSerial.connect(
        device.address,
        uuid: _serialUuid,
        timeoutMs: 8000,
      );

      if (!connected) {
        throw Exception('Bluetooth connection failed');
      }

      emit(
        state.copyWith(
          status: ConnectStatus.success,
          connection: BluetoothGamepadConnection(),
        ),
      );
    } catch (e) {
      debugPrint('Bluetooth connection failed: $e');
      await FlutterBluetoothSerial.disconnect();
      emit(
        state.copyWith(status: ConnectStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Uri _buildUri(String input) {
    final address = input
        .trim()
        .replaceFirst(RegExp(r'^wss?://'), '')
        .split('/')
        .first;

    if (address.isEmpty) {
      throw const FormatException('Enter your PC IP address');
    }

    final hasPort = address.contains(':');
    return Uri.parse('ws://$address${hasPort ? '' : ':8765'}');
  }
}
