import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const ConnectScreen(),
    );
  }
}

// ─── CONNECT SCREEN ───────────────────────────────────────────────────────────
class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});
  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final _ipController = TextEditingController(text: '192.168.1.');
  bool _connecting = false;
  String? _error;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final channel = WebSocketChannel.connect(
        Uri.parse('ws://${_ipController.text}:8765'),
      );
      await channel.ready;
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => GamepadScreen(channel: channel)),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect. Check IP and server.';
      });
    } finally {
      setState(() {
        _connecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_esports,
                size: 60,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'PC Gamepad',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your PC\'s local IP',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'PC IP Address',
                  hintText: '192.168.1.x',
                  prefixIcon: const Icon(Icons.computer),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _connecting ? null : _connect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _connecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Run server.py on your PC first\nFind IP with: ipconfig',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GAMEPAD SCREEN ───────────────────────────────────────────────────────────
class GamepadScreen extends StatefulWidget {
  final WebSocketChannel channel;
  const GamepadScreen({super.key, required this.channel});
  @override
  State<GamepadScreen> createState() => _GamepadScreenState();
}

class _GamepadScreenState extends State<GamepadScreen> {
  void _send(Map<String, dynamic> data) {
    widget.channel.sink.add(jsonEncode(data));
  }

  void _sendButton(String action, bool pressed) {
    _send({'action': action, 'value': pressed ? 1 : 0});
  }

  void _sendJoystick(String side, double x, double y) {
    _send({'action': 'joystick_$side', 'x': x, 'y': -y});
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Stack(
          children: [
            // ── LEFT JOYSTICK ──
            Positioned(
              left: 20,
              bottom: 30,
              child: Joystick(
                mode: JoystickMode.all,
                base: _joystickBase(),
                stick: _joystickStick(),
                listener: (d) => _sendJoystick('left', d.x, d.y),
              ),
            ),

            // ── RIGHT JOYSTICK ──
            Positioned(
              right: 20,
              bottom: 30,
              child: Joystick(
                mode: JoystickMode.all,
                base: _joystickBase(),
                stick: _joystickStick(),
                listener: (d) => _sendJoystick('right', d.x, d.y),
              ),
            ),

            // ── D-PAD ──
            Positioned(left: 60, top: 40, child: _DPad(onPress: _sendButton)),

            // ── ABXY ──
            Positioned(
              right: 50,
              top: 30,
              child: _ABXYButtons(onPress: _sendButton),
            ),

            // ── SHOULDER BUTTONS ──
            Positioned(
              left: 0,
              top: 0,
              child: _ShoulderButtons(side: 'left', onPress: _sendButton),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _ShoulderButtons(side: 'right', onPress: _sendButton),
            ),

            // ── START / SELECT ──
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuButton('SELECT', 'button_select'),
                  const SizedBox(width: 20),
                  _menuButton('START', 'button_start'),
                ],
              ),
            ),

            // ── DISCONNECT ──
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ConnectScreen()),
                  ),
                  child: const Text(
                    '✕ Disconnect',
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _joystickBase() => Container(
    width: 110,
    height: 110,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFF0F3460),
      border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 2),
    ),
  );

  Widget _joystickStick() => Container(
    width: 45,
    height: 45,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.blueAccent,
    ),
  );

  Widget _menuButton(String label, String action) {
    return GestureDetector(
      onTapDown: (_) => _sendButton(action, true),
      onTapUp: (_) => _sendButton(action, false),
      onTapCancel: () => _sendButton(action, false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ),
    );
  }
}

// ─── D-PAD ────────────────────────────────────────────────────────────────────
class _DPad extends StatelessWidget {
  final void Function(String, bool) onPress;
  const _DPad({required this.onPress});

  Widget _btn(String label, String action) {
    return GestureDetector(
      onTapDown: (_) => onPress(action, true),
      onTapUp: (_) => onPress(action, false),
      onTapCancel: () => onPress(action, false),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
        ),
        child: Center(child: Text(label, style: const TextStyle(fontSize: 18))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _btn('▲', 'dpad_up'),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _btn('◀', 'dpad_left'),
            const SizedBox(width: 42, height: 42),
            _btn('▶', 'dpad_right'),
          ],
        ),
        _btn('▼', 'dpad_down'),
      ],
    );
  }
}

// ─── ABXY ─────────────────────────────────────────────────────────────────────
class _ABXYButtons extends StatelessWidget {
  final void Function(String, bool) onPress;
  const _ABXYButtons({required this.onPress});

  Widget _btn(String label, String action, Color color) {
    return GestureDetector(
      onTapDown: (_) => onPress(action, true),
      onTapUp: (_) => onPress(action, false),
      onTapCancel: () => onPress(action, false),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.85),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        children: [
          Positioned(
            left: 41,
            top: 0,
            child: _btn('Y', 'button_y', Colors.yellow),
          ),
          Positioned(
            left: 0,
            top: 41,
            child: _btn('X', 'button_x', Colors.blue),
          ),
          Positioned(
            left: 82,
            top: 41,
            child: _btn('B', 'button_b', Colors.red),
          ),
          Positioned(
            left: 41,
            top: 82,
            child: _btn('A', 'button_a', Colors.green),
          ),
        ],
      ),
    );
  }
}

// ─── SHOULDER BUTTONS ─────────────────────────────────────────────────────────
class _ShoulderButtons extends StatelessWidget {
  final String side;
  final void Function(String, bool) onPress;
  const _ShoulderButtons({required this.side, required this.onPress});

  Widget _btn(
    String label,
    String action,
    void Function(String, bool) onPress,
  ) {
    return GestureDetector(
      onTapDown: (_) => onPress(action, true),
      onTapUp: (_) => onPress(action, false),
      onTapCancel: () => onPress(action, false),
      child: Container(
        width: 80,
        height: 36,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLeft = side == 'left';
    return Column(
      children: [
        _btn(isLeft ? 'LB' : 'RB', isLeft ? 'button_lb' : 'button_rb', onPress),
        _btn(isLeft ? 'LT' : 'RT', isLeft ? 'button_lt' : 'button_rt', onPress),
      ],
    );
  }
}
