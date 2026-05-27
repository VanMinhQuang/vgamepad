# Controller Pad

Controller Pad turns an Android phone into a wireless gamepad for a Windows PC.
The mobile app is built with Flutter, and the PC service is written in Python.
The phone sends controller input over Wi-Fi WebSocket or Bluetooth serial, then
the Python service forwards that input to a virtual DualShock 4 controller using
ViGEmBus and `vgamepad`.

## What It Does

- Uses your phone as a touch gamepad for PC games.
- Supports Wi-Fi and Bluetooth serial connection modes.
- Sends D-pad, ABXY, shoulders, triggers, L3/R3, Start/Select, and joystick input.
- Provides a configurable controller layout.
- Saves custom button positions and sizes locally with SQLite.
- Includes a Python desktop service with a simple Tkinter status window.

## Project Structure

```text

    app_controller/
      lib/
      android/
      pubspec.yaml
      README.md
```



## Requirements

### PC

- Windows 10 or Windows 11.
- ViGEmBus installed.
- Python 3.10 or newer if running the backend from source.
- Windows Firewall access for the Python service or packaged exe.
- Same Wi-Fi network as the phone for Wi-Fi mode.
- Bluetooth pairing and an incoming COM port for Bluetooth mode.

### Android Phone

- Android device with Wi-Fi.
- Bluetooth support if using Bluetooth mode.
- USB debugging enabled if you want to run the Flutter app directly from source.

### Development Tools

- Flutter SDK.
- Android Studio or Android SDK command-line tools.
- Python and pip for backend development.
- PyInstaller if rebuilding the Windows executable.

## Backend Setup

The backend receives input from the phone and creates the virtual controller on
Windows.

### Option 1: Run The Packaged EXE

From the `BE/` folder:

```powershell
.\dist\ControllerPadService.exe
```

Then click **Start Service** in the desktop window.

### Option 2: Run From Source

```powershell
cd "D:\projects\New folder\gamepad\BE"

py -m venv .venv
.\.venv\Scripts\Activate.ps1

python -m pip install --upgrade pip
pip install websockets vgamepad pyserial pyinstaller

python service.py
```

Click **Start Service** after the window opens.

## Mobile App Setup

From this folder:

```powershell
flutter pub get
flutter run
```

To build an APK:

```powershell
flutter build apk
```

The APK will be created under:

```text
build/app/outputs/flutter-apk/
```

## Connecting Over Wi-Fi

1. Connect the phone and PC to the same Wi-Fi network.
2. Start the Python service or `ControllerPadService.exe`.
3. Click **Start Service** in the PC window.
4. Find the PC IPv4 address in the service window or with:

   ```powershell
   ipconfig
   ```

5. Open the mobile app.
6. Select **Wi-Fi**.
7. Enter the PC IP address, for example:

   ```text
   192.168.1.149
   ```

8. Tap **Connect Wi-Fi**.

The app connects to port `8765` automatically. You can also enter a full
WebSocket URL:

```text
ws://192.168.1.149:8765
```

## Connecting Over Bluetooth

1. Pair the Android phone with the Windows PC.
2. In Windows Bluetooth settings, create or identify an incoming Bluetooth COM
   port.
3. Open the Python service or packaged exe.
4. Select the Bluetooth COM port in the service window.
5. Click **Start Service**.
6. Open the mobile app.
7. Select **Bluetooth**.
8. Refresh paired devices.
9. Select the PC and tap **Connect Bluetooth**.

Bluetooth serial uses `115200` baud.

## Configuring The Gamepad Layout

The app includes a layout editor.

1. Open the app.
2. Tap **Layout** on the connect screen, or **Edit** from the gamepad screen.
3. Drag a control to move it.
4. Pinch in or out on a control to resize it.
5. Tap **Save**.

The layout is saved locally in SQLite and reused the next time the gamepad opens.

## Supported Controls

- Left joystick and right joystick.
- D-pad: up, down, left, right.
- ABXY buttons.
- LB, RB, LT, RT.
- L3 and R3.
- Select and Start.

The app sends these backend actions:

```text
button_a
button_b
button_x
button_y
button_lb
button_rb
button_lt
button_rt
button_l3
button_r3
button_select
button_start
dpad_up
dpad_down
dpad_left
dpad_right
joystick_left
joystick_right
```

## Rebuilding The Windows EXE

From the `BE/` folder:

```powershell
cd "D:\projects\New folder\gamepad\BE"
.\.venv\Scripts\Activate.ps1

python -m PyInstaller --onefile --windowed --name ControllerPadService --collect-all vgamepad --hidden-import serial.tools.list_ports service.py
```

The exe will be created at:

```text
BE\dist\ControllerPadService.exe
```

For debugging, build with a console:

```powershell
python -m PyInstaller --onefile --name ControllerPadService --collect-all vgamepad --hidden-import serial.tools.list_ports service.py
```

Clean rebuild:

```powershell
Remove-Item -Recurse -Force build, dist, ControllerPadService.spec
python -m PyInstaller --onefile --windowed --name ControllerPadService --collect-all vgamepad --hidden-import serial.tools.list_ports service.py
```

## Useful Commands

Analyze the Flutter app:

```powershell
flutter analyze
```

Run tests:

```powershell
flutter test
```

Check whether the PC is listening on port `8765`:

```powershell
netstat -ano | Select-String ":8765"
```

## Troubleshooting

- If the phone cannot connect, confirm the PC and phone are on the same Wi-Fi.
- Allow Python or `ControllerPadService.exe` through Windows Firewall.
- Make sure the service window says **Running**.
- Make sure no other process is using port `8765`.
- If the virtual controller does not appear, install or restart ViGEmBus.
- If Bluetooth devices do not appear, pair the phone with the PC first.
- If no Bluetooth COM ports appear, install `pyserial` and check Windows
  Bluetooth COM port settings.
- If the packaged exe closes silently, rebuild without `--windowed` and run it
  from PowerShell to see the error.
- If layout changes do not appear, save the layout and reopen the gamepad screen.

## Notes

- The backend service currently targets Windows because it depends on ViGEmBus
  and `vgamepad`.
- Public or guest Wi-Fi networks may block device-to-device traffic.
- A full app restart is safer than hot reload after changing SQLite schema,
  platform plugins, or dependency setup.
