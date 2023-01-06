

//
// }
//
// DropdownButton(
//   isExpanded : true,
//   items: _getDeviceItems(),
//   onChanged: (dynamic value) =>
//             setState(() => _device = value),
//   value: _devicesList.isNotEmpty ? _device : null,
// ))},


//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: BluetoothApp(),
//     );
//   }
// }
//
// class BluetoothApp extends StatefulWidget {
//   const BluetoothApp({Key? key}) : super(key: key);
//
//   @override
//   _BluetoothAppState createState() => _BluetoothAppState();
// }
//
// class _BluetoothAppState extends State<BluetoothApp> {
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//
//   FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
//
//   BluetoothConnection? connection;
//
//   bool get isConnected => connection != null && connection!.isConnected;
//
//   late int _deviceState;
//
//   bool isDisconnecting = false;
//
//   List<BluetoothDevice> _devicesList = [];
//   BluetoothDevice? _device;
//   bool _connected = false;
//
//   Future<void> getPairedDevices() async {
//     List<BluetoothDevice> devices = [];
//
//     // To get the list of paired devices
//     try {
//       devices = await _bluetooth.getBondedDevices();
//     } on PlatformException {
//       print("Error");
//     }
//
//     // It is an error to call [setState] unless [mounted] is true.
//     if (!mounted) {
//       return;
//     }
//
//     // Store the [devices] list in the [_devicesList] for accessing
//     // the list outside this class
//     setState(() {
//       _devicesList = devices;
//     });
//   }
//
//   bool _isButtonUnavailable = false;
//   @override
//   void initState() {
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });
//
//     FlutterBluetoothSerial.instance
//         .onStateChanged()
//         .listen((BluetoothState state) {
//       setState(() {
//         _bluetoothState = state;
//         if (_bluetoothState == BluetoothState.STATE_OFF) {
//           _isButtonUnavailable = true;
//         }
//         getPairedDevices();
//       });
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     if (isConnected) {
//       isDisconnecting = true;
//       connection!.dispose();
//       connection = null;
//
//       super.dispose();
//     }
//   }
//
//   List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
//     List<DropdownMenuItem<BluetoothDevice>> items = [];
//     if (_devicesList.isEmpty) {
//       items.add(DropdownMenuItem(
//         child: Text('NONE'),
//       ));
//     } else {
//       _devicesList.forEach((device) {
//         items.add(DropdownMenuItem(
//           child: Text(device.name.toString()),
//           value: device,
//         ));
//       });
//     }
//     return items;
//   }
//
//   void _connect() async {
//     setState(() {
//       _isButtonUnavailable = true;
//     });
//     if (_device == null) {
//       Text('No device selected');
//     } else {
//       if (!isConnected) {
//         await BluetoothConnection.toAddress(_device!.address)
//             .then((_connection) {
//           print('Connected to the device');
//           connection = _connection;
//           setState(() {
//             _connected = true;
//           });
//
//           connection!.input!.listen(null).onDone(() {
//             if (isDisconnecting) {
//               print('Disconnecting locally!');
//             } else {
//               print('Disconnected remotely!');
//             }
//             if (this.mounted) {
//               setState(() {});
//             }
//           });
//         }).catchError((error) {
//           print('Cannot connect, exception occurred');
//           print(error);
//         });
//         Text('Device connected');
//
//         setState(() => _isButtonUnavailable = false);
//       }
//     }
//   }
//
//   void _disconnect() async {
//     setState(() {
//       _isButtonUnavailable = true;
//       _deviceState = 0;
//     });
//
//     await connection!.close();
//     Text('Device disconnected');
//     if (!connection!.isConnected) {
//       setState(() {
//         _connected = false;
//         _isButtonUnavailable = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         title: Text(
//           'Home Automation',
//           style: TextStyle(
//               fontSize: 20.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.yellow),
//         ),
//       ),
//       backgroundColor: Colors.white54,
//       drawer: Drawer(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 60.0,
//             ),
//             IconButton(
//               onPressed: () async {
//                 await getPairedDevices().then((_) {
//                   Text('Device list refreshed');
//                 });
//               },
//               icon: Icon(
//                 Icons.replay_sharp,
//                 color: Colors.black,
//                 size: 20.0,
//               ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 DropdownButton(
//                   items: _getDeviceItems(),
//                   onChanged: (dynamic value) => setState(() => _device = value),
//                   value: _devicesList.isNotEmpty ? _device : null,
//                 ),
//               ],
//             ),
//             TextButton(
//               onPressed: _isButtonUnavailable
//                   ? null
//                   : _connected
//                   ? _disconnect
//                   : _connect,
//               child: Text(_connected ? 'Disconnect' : 'Connect'),
//             )
//           ],
//         ),
//       ),
//       body: ListView(
//         children: [
//           ListTileSwitch(
//               title: Text(
//                 'Enable Bluetooth',
//                 style: TextStyle(
//                   fontSize: 25.0,
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               value: _bluetoothState.isEnabled,
//               onChanged: (bool value) {
//                 future() async {
//                   // async lambda seems to not working
//                   if (value) {
//                     await FlutterBluetoothSerial.instance.requestEnable();
//                   } else {
//                     await FlutterBluetoothSerial.instance.requestDisable();
//                   }
//                 }
//
//                 future().then((_) {
//                   setState(() {});
//                 });
//               }),
//         ],
//       ),
//     );
//   }
// }