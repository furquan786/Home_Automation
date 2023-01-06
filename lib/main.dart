import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'list_devices.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({Key? key}) : super(key: key);

  final bool start = true;
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
  List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  late BluetoothConnection connection;

  bool get isConnected => connection != null && connection.isConnected;

  late int _bluetoothstate;
  String _address = "...";
  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  String _name = "...";
  @override
  void initState() {
    super.initState();
    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
    // _restartDiscovery();

    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _bluetoothstate = 0;
    //calling here enable button

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        //calling the funtion of devicelist
        // getPairedDevices();
      });
    });
  }

  void _startDiscovery() async {
//     BluetoothConnection connection = await BluetoothConnection.toAddress('38:E6:0A:1D:ED:B2');
// print(connection);
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            final existingIndex = results.indexWhere(
                    (element) => element.device.address == r.device.address);
            if (existingIndex >= 0)
              results[existingIndex] = r;
            else
              results.add(r);
          });
        });
    // _streamSubscription!.onDone(() {
    //   setState(() {
    //     isDiscovering = false;
    //   });
    // });
  }

  // Future<bool> enableBluetooth() async {
  //   _bluetoothState = await FlutterBluetoothSerial.instance.state;
  //
  //   if (_bluetoothState == BluetoothState.STATE_OFF) {
  //     await FlutterBluetoothSerial.instance.requestEnable();
  //     await getPairedDevices();
  //     return true;
  //   } else {
  //     await getPairedDevices();
  //   }
  //   return false;
  // }

  bool _connected = false;
  bool _isButtonUnavailable = false;

  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      Text('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device!.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input!.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        Text('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Future<void> getPairedDevices() async {
  //   List<BluetoothDevice> devices = [];
  //   try {
  //     devices = await _bluetooth.getBondedDevices();
  //   } on PlatformException {
  //     print("Error");
  //   }
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _devicesList = devices;
  //   });
  // }

  bool isDisconnecting = false;

   void _restartDiscovery() async{
     setState(() {
       results.clear();
       isDiscovering = true;
     });
     return  _startDiscovery();
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      // connection.dispose();
      connection = 0 as BluetoothConnection;
    }
    // _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Home Automation'),
      ),
      drawer: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                 IconButton(
                  onPressed: () {
                    _restartDiscovery();
                  },
                  icon: Icon(Icons.replay_sharp,
                  color: Colors.black,
                  size: 30.0,),
                ),
              ],
            ),
            SizedBox(
              height: 50.0,
            ),
            _bluetoothState == BluetoothState.STATE_ON
                ? ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (BuildContext context, index) {
                BluetoothDiscoveryResult result = results[index];
                final device = result.device;
                final address = device.address;
                return BluetoothDeviceListEntry(
                  device: device,
                  rssi: result.rssi,
                  onTap: () {
                    Navigator.of(context).pop(result.device);
                  },
                  onLongPress: () async {
                    bool bonded = false;
                    try {
                      if (device.isBonded) {
                        print('Unbonding from ${device.address}...');
                        await FlutterBluetoothSerial.instance
                            .removeDeviceBondWithAddress(address);
                        print(
                            'Unbonding from ${device.address} has succed');
                      } else {
                        print('Bonding with ${device.address}...');
                        bonded = (await FlutterBluetoothSerial.instance
                            .bondDeviceAtAddress(address))!;
                        print(
                            'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                      }
                      setState(() {
                        results[results.indexOf(result)] =
                            BluetoothDiscoveryResult(
                                device: BluetoothDevice(
                                  name: device.name ?? '',
                                  address: address,
                                  type: device.type,
                                  bondState: bonded
                                      ? BluetoothBondState.bonded
                                      : BluetoothBondState.none,
                                ),
                                rssi: result.rssi);
                      });
                    } catch (ex) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                            const Text('Error occured while bonding'),
                            content: Text("${ex.toString()}"),
                            actions: <Widget>[
                              new TextButton(
                                child: new Text("Close"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                );
              },
            )
                : Center(
              child: Text(
                'Please On The Bluetooth',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 25.0),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: ListView(
          children: [
            ListTileSwitch(
                title: Text(
                  'Enable Bluetooth',
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                value: _bluetoothState.isEnabled,
                onChanged: (bool value) {
                  future() async {
                    // async lambda seems to not working
                    if (value) {
                      await FlutterBluetoothSerial.instance.requestEnable();
                    } else {
                      await FlutterBluetoothSerial.instance.requestDisable();
                    }
                  }

                  future().then((_) {
                    setState(() {});
                  });
                })
          ],
        ),
      ),
    );
  }
}

List<BluetoothDevice> _devicesList = [];
BluetoothDevice? _device;

