import 'dart:convert';

import 'package:bluetooth_serial_android/bluetooth_serial_android.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class GamepadConnection {
  void send(Map<String, dynamic> data);

  Future<void> close();
}

class WebSocketGamepadConnection implements GamepadConnection {
  final WebSocketChannel channel;

  WebSocketGamepadConnection(this.channel);

  @override
  void send(Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }

  @override
  Future<void> close() async {
    await channel.sink.close();
  }
}

class BluetoothGamepadConnection implements GamepadConnection {
  @override
  void send(Map<String, dynamic> data) {
    FlutterBluetoothSerial.write('${jsonEncode(data)}\n');
  }

  @override
  Future<void> close() {
    return FlutterBluetoothSerial.disconnect();
  }
}
