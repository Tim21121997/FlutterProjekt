import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import './widgets/navigation_bar.dart';
import './widgets/expansion_panel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _connectionStatus = "Disconnected";
  String _heartRate = "- bpm";
  BluetoothDevice? device;
  bool _isConnected = false;
  bool earConnectFound = false;
  int _currentPageIndex = 0;
  var scanSubscription;
  var stateSubscription;

  // Callback function that updates the page index
  void onIndexChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  // Function for updating the heart rate displayed
  void updateHeartRate(rawData) {
    if (!rawData.isEmpty) {
      Uint8List bytes = Uint8List.fromList(rawData);
      // based on GATT standard
      var bpm = bytes[1];
      if (!((bytes[0] & 0x01) == 0)) {
        bpm = (((bpm >> 8) & 0xFF) | ((bpm << 8) & 0xFF00));
      }
      var bpmLabel = "- bpm";
      if (bpm != 0) {
        bpmLabel = bpm.toString() + " bpm";
      }
      setState(() {
        _heartRate = bpmLabel;
      });
    }
  }

  // Function that disconnects bluetooth device
  void _disconnect() async {
    await device?.disconnect();
    stateSubscription.cancel();
    /*setState(() {
      earConnectFound = false;
      _connectionStatus = "Disconnected";
    });*/
  }

  // Function that searches for cosinuss device
  void _connect() async {
    // Ask for permissions
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.location.request();
    if (device != null) {
      stateSubscription = device!.state.listen((state) {
        // Listen for connection state changes
        setState(() {
          _isConnected = state == BluetoothDeviceState.connected;
          _connectionStatus = (_isConnected) ? "Connected" : "Disconnected";
        });
        if (_isConnected) {
          _charasteristics();
        }
      });
      // Connecting device to app
      await device?.connect();
    } else {
      FlutterBlue flutterBlue = FlutterBlue.instance;
      // start scanning, it will scan for 4 seconds
      flutterBlue.startScan(timeout: const Duration(seconds: 6));
      // FlutterBluePlus.scanResults is a stream that provides the results of the
      // bluetooth scan like <List <ScanResults>>. Listen - method monitors the
      // values put onto the stream and is supplied with a callback which is
      // executed as soon as new values is available. The list method returns a
      // StreamSubscription object that manages the subscription
      scanSubscription = flutterBlue.scanResults.listen((results) async {
        // Search for the earable in the list returned
        for (ScanResult r in results) {
          if (r.device.name == "kit_acc") {
            device = r.device;
            // Avoid multiple connect attempts to same device
            /*setState(() {
              earConnectFound = true;
            });*/
            // Stop scan when device is found
            await flutterBlue.stopScan();
            if (device != null) {
              stateSubscription = device!.state.listen((state) {
                // Listen for connection state changes
                setState(() {
                  _isConnected = state == BluetoothDeviceState.connected;
                  _connectionStatus =
                      (_isConnected) ? "Connected" : "Disconnected";
                });
                if (_isConnected) {
                  _charasteristics();
                }
              });
              // Connecting device to app
              await device?.connect();
            }
            // Break For Loop if device is connected
            break;
          }
        }
      });
      //scanSubscription.cancel();
    }
  }

  // Function that establishes a connection to get the heart rate
  void _charasteristics() async {
    var services = await device!.discoverServices();
    // iterate over services
    for (var service in services) {
      // iterate over characterstics
      for (var characteristic in service.characteristics) {
        // UUID = Universal Unique Identifier for heart rate measurement
        String uuid = "00002a37-0000-1000-8000-00805f9b34fb";
        //
        if (characteristic.uuid.toString() == uuid) {
          await characteristic.setNotifyValue(true);
          // LastValueStream emits a value any time the characteristics changes
          characteristic.value.listen((rawData) => updateHeartRate(rawData));
          // short delay before next bluetooth operation otherwise BLE crashes
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Center(
          child: Text("FitnessTracker"),
        ),
      ),
      bottomNavigationBar: Navigation(onIndexChanged: onIndexChanged),
      /*floatingActionButton: Visibility(
        //visible: !_isConnected,
        child: FloatingActionButton(
          onPressed: _connect,
          tooltip: 'Increment',
          child: const Icon(Icons.bluetooth_searching_sharp),
        ),
      ),*/
      body: <Widget>[
        // Sarting page
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          // ListView is a scrolling widget that displays its children one
          // after another in scrolling direction
          child: ListView(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ExpansionPan(
                onOf: _disconnect,
                onOn: _connect,
                connectionStatus: _connectionStatus,
                earConnectFound: earConnectFound,
              ),
            ),
          ]),
        ),
        // Fitness page
        Column(
          children: [
            //Text(_connectionStatus),
            Text(_heartRate),
            Text(_connectionStatus)
            //Text(earConnectFound.toString()),
          ],
        ),
      ][_currentPageIndex],
    );
  }
}
