import 'package:app_controller/app/app_size.dart';
import 'package:app_controller/app/route.dart';
import 'package:app_controller/app/styles.dart';
import 'package:app_controller/features/connect/bloc/connect_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConnectCubit(),
      child: const ConnectView(),
    );
  }
}

class ConnectView extends StatelessWidget {
  const ConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return BlocListener<ConnectCubit, ConnectState>(
      listener: (context, state) {
        if (state.status.isSuccess && state.connection != null) {
          context.pushNamed(
            routeName: Routes.GAMEPAD,
            arguments: state.connection,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        resizeToAvoidBottomInset: true,
        extendBody: true,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    width: width * 0.4,

                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 32.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sports_esports,
                          size: 60.r,
                          color: context.primary,
                        ),
                        const SizedBox(height: 16),
                        Text('PC Gamepad', style: context.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          'Choose how your phone connects to the PC',
                          style: context.bodySmall.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ConnectCubit, ConnectState>(
                          builder: (context, state) {
                            return SegmentedButton<ConnectMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ConnectMode.wifi,
                                  icon: Icon(Icons.wifi_rounded),
                                  label: Text('Wi-Fi'),
                                ),
                                ButtonSegment(
                                  value: ConnectMode.bluetooth,
                                  icon: Icon(Icons.bluetooth_rounded),
                                  label: Text('Bluetooth'),
                                ),
                              ],
                              selected: {state.mode},
                              onSelectionChanged: (selection) {
                                final mode = selection.first;
                                final cubit = context.read<ConnectCubit>();
                                cubit.setMode(mode);
                                if (mode.isBluetooth) {
                                  cubit.loadBluetoothDevices();
                                }
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        BlocBuilder<ConnectCubit, ConnectState>(
                          builder: (context, state) {
                            if (state.mode.isBluetooth) {
                              final selectedBluetoothDevice =
                                  state.bluetoothDevices.contains(
                                    state.selectedBluetoothDevice,
                                  )
                                  ? state.selectedBluetoothDevice
                                  : null;

                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            DropdownButtonFormField<
                                              BluetoothDeviceInfo
                                            >(
                                              key: ValueKey(
                                                selectedBluetoothDevice
                                                        ?.address ??
                                                    'no-bluetooth-device',
                                              ),
                                              initialValue:
                                                  selectedBluetoothDevice,
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                labelText: 'Paired PC',
                                                labelStyle: context.hint,
                                                prefixIcon: Icon(
                                                  Icons.devices_rounded,
                                                  size: 16.sp,
                                                ),
                                              ),
                                              hint: Text(
                                                'Select paired PC',
                                                style: context.hint,
                                              ),
                                              items: state.bluetoothDevices
                                                  .map(
                                                    (
                                                      device,
                                                    ) => DropdownMenuItem(
                                                      value: device,
                                                      child: Text(
                                                        '${device.name} (${device.address})',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            context.bodySmall,
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (device) {
                                                if (device == null) return;
                                                context
                                                    .read<ConnectCubit>()
                                                    .selectBluetoothDevice(
                                                      device,
                                                    );
                                              },
                                            ),
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton.filledTonal(
                                        onPressed: state.isBluetoothLoading
                                            ? null
                                            : () => context
                                                  .read<ConnectCubit>()
                                                  .loadBluetoothDevices(),
                                        icon: state.isBluetoothLoading
                                            ? SizedBox(
                                                width: 16.r,
                                                height: 16.r,
                                                child:
                                                    const CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(Icons.refresh_rounded),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Pair your phone with the PC first, then select the PC here.',
                                    textAlign: TextAlign.center,
                                    style: context.bodySmall.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            }

                            return TextField(
                              keyboardType: TextInputType.url,
                              decoration: InputDecoration(
                                labelText: 'PC IP Address',
                                labelStyle: context.hint,
                                hintText: '192.168.1.x',
                                hintStyle: context.hint,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 4.h,
                                ),
                                prefixIcon: Icon(Icons.computer, size: 16.sp),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              style: context.body.copyWith(fontSize: 12.sp),
                              onChanged: (value) {
                                context.read<ConnectCubit>().handleIPChange(
                                  value,
                                );
                              },
                            );
                          },
                        ),
                        BlocBuilder<ConnectCubit, ConnectState>(
                          builder: (context, state) {
                            if (state.status.isError) {
                              return Column(
                                children: [
                                  const SizedBox(height: 12),
                                  Text(
                                    'Could not connect. Check IP and server.',
                                    style: context.titleMedium.copyWith(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                  if (state.errorMessage.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      state.errorMessage,
                                      textAlign: TextAlign.center,
                                      style: context.titleMedium.copyWith(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<ConnectCubit, ConnectState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.status.isConnecting
                                    ? null
                                    : () {
                                        context.read<ConnectCubit>().connect();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state.status.isConnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        state.mode.isBluetooth
                                            ? 'Connect Bluetooth'
                                            : 'Connect Wi-Fi',
                                        style: context.titleMedium.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Run server.py on your PC first\nFind IP with: ipconfig',
                          textAlign: TextAlign.center,
                          style: context.bodySmall.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
