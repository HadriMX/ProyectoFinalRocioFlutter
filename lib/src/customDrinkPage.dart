import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'models/bebida.dart';
import 'models/tamanoBebida.dart';

class CustomDrinkPage extends StatefulWidget {
  static const routeName = '/customDrink';
  final int idSaborSeleccionado;
  final int idTamanoSeleccionado;

  CustomDrinkPage(
      {Key key, this.idSaborSeleccionado, this.idTamanoSeleccionado})
      : super(key: key);

  @override
  _CustomDrinkPageState createState() => _CustomDrinkPageState(
      selectedIdSabor: idSaborSeleccionado,
      selectedIdTamano: idTamanoSeleccionado);
}

class _CustomDrinkPageState extends State<CustomDrinkPage> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  bool waiting = false;

  @override
  void initState() {
    super.initState();
    this.getBebidas();
    this.getTamanos();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    _deviceState = 0; // neutral

    // If the bluetooth of the device is not enabled,
    // then request permission to turn on bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  // Method to connect to bluetooth
  Future _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      print('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen((Uint8List data) {
            var incoming = ascii.decode(data);
            print('Data incoming: $incoming');

            if (incoming.contains('.')) {
              print('Exito');

              waiting = false;
            } else if (incoming.contains('-')) {
              print('Error');

              waiting = false;
            }
          }).onDone(() {
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
        print('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    print('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  Future _sendOnMessageToBluetooth(int idBebida, int idTamano) async {
    var bebidaVal = idBebida - 1; // restar 1 para que esté en el rango 0-9
    var tamanoVal = 'c';
    if (idTamano == 1) {
      tamanoVal = 'c';
    } else if (idTamano == 2) {
      tamanoVal = 'm';
    } else if (idTamano == 3) {
      tamanoVal = 'g';
    }

    var baits = utf8.encode(bebidaVal.toString() + tamanoVal.toString());
    connection.output.add(baits);
    await connection.output.allSent;
    print('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  var selectedIdSabor = 1;
  var selectedIdTamano = 1;
  List<Bebida> _bebidas = [];
  List<TamanoBebida> _tamanos = [];
  List<DropdownMenuItem> bebidasItems = [];
  List<DropdownMenuItem> tamanosItems = [];

  _CustomDrinkPageState({this.selectedIdSabor, this.selectedIdTamano});

  Future getBebidas() async {
    final response = await http.get('https://192.168.0.10:5001/api/bebidas');

    if (response.statusCode == 200) {
      Iterable res = json.decode(response.body);
      var resBebidas =
          List<Bebida>.from(res.map((model) => Bebida.fromJson(model)));
      setState(() {
        _bebidas = resBebidas;
        bebidasItems = _bebidas
            .map((item) => DropdownMenuItem(
                  child: Text(item.nombre),
                  value: item.idBebida,
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load resource');
    }
  }

  Future getTamanos() async {
    final response = await http.get('https://192.168.0.10:5001/api/tamanos');

    if (response.statusCode == 200) {
      Iterable res = json.decode(response.body);
      var resTamanos = List<TamanoBebida>.from(
          res.map((model) => TamanoBebida.fromJson(model)));
      setState(() {
        _tamanos = resTamanos;
        tamanosItems = _tamanos
            .map((item) => DropdownMenuItem(
                  child: Text(item.tamanoBebida),
                  value: item.idTamano,
                ))
            .toList();
      });
    } else {
      throw Exception('Failed to load resource');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Nuevo pedido'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              top: 0.0,
              right: 8.0,
              bottom: 0.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButtonFormField(
                  value: selectedIdSabor,
                  decoration: InputDecoration(
                    labelText: 'Sabor',
                  ),
                  items: bebidasItems,
                  onChanged: (selected) {
                    setState(() {
                      selectedIdSabor = selected;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                DropdownButtonFormField(
                  value: selectedIdTamano,
                  decoration: InputDecoration(
                    labelText: 'Tamaño',
                  ),
                  items: tamanosItems,
                  onChanged: (selected) {
                    setState(() {
                      selectedIdTamano = selected;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text('Aceptar'),
                  onPressed: botonPresionado,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void botonPresionado() async {
    print(selectedIdSabor);
    print(selectedIdTamano);

    _device = _devicesList.firstWhere((x) => x.address == '14:41:13:05:89:F3');

    await _connect();

    await _sendOnMessageToBluetooth(selectedIdSabor, selectedIdTamano);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Espere, por favor...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                CircularProgressIndicator(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (!waiting) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
