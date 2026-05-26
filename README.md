# Controller Pad

Controller Pad turns an Android phone into a wireless gamepad for a Windows PC.
The Flutter app sends controller input over WebSocket, and the Windows service
receives it and forwards it to a virtual DualShock 4 controller through
ViGEmBus/vgamepad.

## Project Layout

```text
gamepad/
  BE/
    service.py
    dist/ControllerPadService.exe
  Mobile/
    app_controller/
      lib/
      android/
      pubspec.yaml
```

## Requirements

- Windows PC and Android phone on the same Wi-Fi network.
- Flutter SDK for mobile app development.
- ViGEmBus installed on the Windows PC.
- Windows Firewall must allow the service on private networks.

## Run The Windows Service

Use the packaged executable:

```powershell
..\..\BE\dist\ControllerPadService.exe
```

Then click **Start Service** in the desktop window. The service listens on:

```text
ws://<your-pc-ip>:8765
```

The app usually shows the endpoint in the service window. You can also find the
PC IP with:

```powershell
ipconfig
```

Look for the IPv4 address under the active Wi-Fi adapter.

### Bluetooth Mode

Bluetooth mode uses Bluetooth Classic Serial/RFCOMM.

1. Pair the Android phone with the Windows PC in Windows Bluetooth settings.
2. In Windows, create or identify an incoming Bluetooth COM port.
3. Open `ControllerPadService.exe`.
4. Select the Bluetooth COM port in the service window.
5. Click **Start Service**.
6. In the phone app, choose **Bluetooth**, refresh paired devices, select the PC,
   then connect.

Wi-Fi mode can stay enabled at the same time. The service accepts controller
input from WebSocket and Bluetooth serial.

## Run The Flutter App

From this folder:

```powershell
flutter pub get
flutter run
```

On the connect screen, enter the PC Wi-Fi IP address, for example:

```text
192.168.1.149
```

The app connects to port `8765` automatically. You can also paste a full address
such as:

```text
ws://192.168.1.149:8765
```

## Rebuild The Windows EXE

If `service.py` changes, rebuild the executable from the `BE` folder:

```powershell
cd ..\..\BE
python -m PyInstaller --noconfirm --clean --onefile --windowed --name ControllerPadService --hidden-import websockets --hidden-import vgamepad --hidden-import serial --hidden-import serial.tools.list_ports --collect-binaries vgamepad service.py
```

The rebuilt file will be created at:

```text
BE\dist\ControllerPadService.exe
```

## Troubleshooting

- If the phone cannot connect, make sure both devices are on the same Wi-Fi.
- Allow `ControllerPadService.exe` through Windows Firewall for private networks.
- Make sure the service window says `Running`.
- Make sure no other app is using port `8765`.
- For Bluetooth, make sure the selected COM port is the incoming Bluetooth
  serial port and that the phone is paired with the PC.
- If Android shows a WebSocket error, check the exact error message on the
  connect screen.
- Public Wi-Fi or guest Wi-Fi may block devices from talking to each other.

## Useful Commands

Analyze the Flutter project:

```powershell
flutter analyze
```

Build an Android APK:

```powershell
flutter build apk
```

Check whether the PC is listening on port `8765`:

```powershell
netstat -ano | Select-String ":8765"
```
