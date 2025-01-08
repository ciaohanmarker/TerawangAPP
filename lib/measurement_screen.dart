import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'dart:convert';

class MeasurementScreen extends StatefulWidget {
  final int sensorCount;
  final Map<String, List<Map<String, String>>> initialSensorData;
  final Map<String, String> savedGeometryData;
  final Function(Map<String, List<Map<String, String>>>, Map<String, Color>)
      onSave;
  final Function(bool) onAllSensorsSaved;
  final Map<String, Color>? savedSensorColors;

  const MeasurementScreen({
    super.key,
    required this.sensorCount,
    required this.initialSensorData,
    required this.savedGeometryData,
    required this.onSave,
    required this.onAllSensorsSaved,
    this.savedSensorColors,
  });

  @override
  _MeasurementScreenState createState() => _MeasurementScreenState();
}

class _MeasurementScreenState extends State<MeasurementScreen> {
  bool isMeasuring = false;
  String? selectedSensor;
  String? previousSensor;
  Map<String, List<Map<String, String>>> sensorData = {};
  Map<String, bool> isRowEditable = {};
  Map<String, bool> isSensorSaved = {};
  Map<String, Color> sensorColors = {};
  double circumference = 0.0;
  double depth = 0.0;
  List<double> chordDistances = [];

  // Bluetooth-related variables
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _connection;
  String _statusText = "Tidak Tersambung";
  Color _statusColor = const Color.fromARGB(255, 183, 30, 20);
  bool _isConnected = false;
  bool _dataSent = false;
  bool _hitungAverageClicked = false;

  // Data-related variables
  List<double> sumData = [];
  int countedData = 0;
  List<double> averageData = [];
  String validationMessage = "Menunggu data...";
  Color validationMessageColor = Colors.black;
  int selectedSensorIndex = 0;

  // Tracks whether the sensor mode is ON or OFF
  bool isMeasurementModeOn = false;
  String _sensorModeText = "Mode Idle";
  String bluetoothSensorIndex = "";

  @override
  void initState() {
    super.initState();

    sensorData = Map.from(widget.initialSensorData);
    // Set circumference from geometry data
    circumference = double.parse(widget.savedGeometryData['circumference']!);
    depth = double.parse(widget.savedGeometryData['depth']!);

    _calculateChordDistances();

    for (int i = 1; i <= widget.sensorCount; i++) {
      isRowEditable['$i'] = true;
      isSensorSaved['$i'] = false;
      sensorColors['Sensor $i'] =
          widget.savedSensorColors?['Sensor $i'] ?? Colors.white;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAllSensorsSaved(isSensorSaved.values.every((saved) => saved));
    });

    // Request Bluetooth permissions and get initial Bluetooth state
    _requestBluetoothPermissions();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  void _calculateChordDistances() {
    int sensorCount = int.parse(widget.savedGeometryData['sensorCount']!);
    // in-out in cm
    double radius = (circumference / (2 * pi) - depth).toDouble();
    double angleBetweenSensors = (2 * pi / sensorCount).toDouble();

    chordDistances.clear();
    for (int i = 0; i < sensorCount; i++) {
      int steps = (i - selectedSensorIndex).abs();
      double angle = steps * angleBetweenSensors;
      double distance = 2 * radius * sin(angle / 2);
      chordDistances.add(distance);
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted) {
      print("Bluetooth permissions granted.");
    } else {
      print("Bluetooth permissions not granted.");
    }
  }

  void _connectToBluetooth() async {
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PairedDeviceScreen(
            onSelected: (device) {
              _connectToDevice(device);
            },
          );
        },
      ),
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _isConnected = true;
        _statusText = "Tersambung"; // Update status text when connected
        _statusColor = Colors.green; // Update status color when connected
      });

      StringBuffer buffer =
          StringBuffer(); // Buffer to accumulate incoming data

      connection.input!.listen((data) {
        String received = String.fromCharCodes(data);
        buffer.write(received);

        if (received.contains("\n")) {
          String completeMessage = buffer.toString().trim();
          print("Data received: $completeMessage");
          _processReceivedData(completeMessage);
          buffer.clear();
        }
      }).onDone(() {
        setState(() {
          _statusText =
              "Tidak Tersambung"; // Update status text when disconnected
          _statusColor = Colors.red; // Update status color when disconnected
          _isConnected = false;
        });
      });
    } catch (e) {
      print('Error connecting: $e');
    }
  }

  void _processReceivedData(String data) {
    const double tofNail = 20.24; //v = 5930 m/s, l = 12 cm

    List<String> dataList = data.split(',');

    bool isValid = dataList.every((e) {
      if (e == "#") return true;
      double? value = double.tryParse(e);
      return (value != null && value > 0);
    });

    if (isValid) {
      List<double> tofData =
          dataList.map((e) => e == "#" ? 1.0 : double.parse(e)).toList();

      if (sumData.isEmpty) {
        sumData = List<double>.filled(widget.sensorCount, 0.0);
      }

      List<double> speedData = [];
      for (int i = 0; i < tofData.length; i++) {
        double adjustedTof = tofData[i] - tofNail;
        if (adjustedTof <= 0) {
          adjustedTof = 1.0; // Avoid division by zero or negative values
        }
        double speed = chordDistances[i] / adjustedTof * 10000;
        speedData.add(speed);
        sumData[i] += speed;
      }

      countedData++;
      validationMessage = "Data valid.";
      validationMessageColor = Colors.green;
      _dataSent = true;

      // Update sensorData to show calculated speedData
      if (selectedSensor != null) {
        for (int i = 0; i < speedData.length; i++) {
          sensorData[selectedSensor]![i]['vms'] =
              speedData[i].toStringAsFixed(0);
        }
      }
    } else {
      validationMessage = "Data tidak valid, ambil data lain.";
      validationMessageColor = Colors.red;
      _dataSent = false;
    }

    setState(() {});
  }

  void _showAverageData() {
    if (_isConnected && countedData > 0) {
      setState(() {
        averageData = sumData.map((sum) => sum / countedData).toList();
        sumData = List<double>.filled(sumData.length, 0);
        countedData = 0;
        _hitungAverageClicked = true;

        // Update the sensorData for the selected sensor only
        if (selectedSensor != null) {
          for (int i = 0; i < averageData.length; i++) {
            sensorData[selectedSensor]![i]['vms'] =
                averageData[i].toStringAsFixed(0);
          }
        }
      });
    }
  }

  void _updateRowEditability(String? selectedSensor) {
    setState(() {
      if (selectedSensor != null) {
        for (var i = 1; i <= widget.sensorCount; i++) {
          isRowEditable[i.toString()] =
              i.toString() != selectedSensor.substring(7);
        }
        sensorData[selectedSensor]![int.parse(selectedSensor.substring(7)) - 1]
            ['vms'] = '0';
      }
    });
  }

  void _saveData() {
    setState(() {
      if (selectedSensor != null) {
        isSensorSaved[selectedSensor!.substring(7)] = true;
        sensorColors[selectedSensor!] = Colors.green;
        widget.onAllSensorsSaved(isSensorSaved.values.every((saved) => saved));
      }
      widget.onSave(sensorData, sensorColors);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil tersimpan!')),
    );
  }

  void _deleteData() {
    setState(() {
      if (selectedSensor != null) {
        isSensorSaved[selectedSensor!.substring(7)] = false;
        sensorColors[selectedSensor!] = Colors.white;

        // Reset countedData, sumData, and validationMessage
        countedData = 0;
        sumData = [];
        validationMessage = "Awaiting data...";
        validationMessageColor = Colors.black;
        _dataSent = false;
        _hitungAverageClicked = false;

        // Clear selected sensor data
        for (int i = 0; i < sensorData[selectedSensor]!.length; i++) {
          sensorData[selectedSensor]![i]['vms'] = '';
        }
        widget.onAllSensorsSaved(isSensorSaved.values.every((saved) => saved));
      }
      widget.onSave(sensorData, sensorColors);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil terhapus!')),
    );
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  void _sendSelectedSensor(String sensorIndex) {
    setState(() {
      // Check if the previous sensor exists, is not the same as the current, and hasn't been saved
      if (previousSensor != null &&
          previousSensor != 'Sensor $sensorIndex' &&
          sensorColors[previousSensor!] != Colors.green) {
        // Clear unsaved data for the previous sensor
        for (int i = 0; i < sensorData[previousSensor]!.length; i++) {
          sensorData[previousSensor]![i]['vms'] = '';
        }
      }

      countedData = 0;
      sumData = [];
      validationMessage = "Awaiting data...";
      validationMessageColor = Colors.black;
      _dataSent = false;
      _hitungAverageClicked = false;

      previousSensor = 'Sensor $sensorIndex';
    });

    if (_connection != null && _isConnected) {
      _connection!.output.add(utf8.encode("$sensorIndex\n"));
      _connection!.output.allSent.then((_) {
        print("Sent selected sensor: $sensorIndex to Arduino.");
      });
    }
  }

  void _toggleSensorMode(bool value, String sensorIndex) {
    setState(() {
      isMeasurementModeOn = value;

      if (isMeasurementModeOn) {
        _sensorModeText = "Mode Pengukuran";

        if (_connection != null && _isConnected) {
          _connection!.output.add(utf8.encode("$sensorIndex\n"));
          _connection!.output.allSent.then((_) {
            print("Sent selected sensor: $sensorIndex to Arduino.");
          });
        }
      } else {
        _sensorModeText = "Mode Idle";
        // Send "0" when toggled off
        if (_connection != null && _isConnected) {
          _connection!.output.add(utf8.encode("0\n"));
          _connection!.output.allSent.then((_) {
            print("Sent selected sensor: 0 to Arduino.");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mulai pengukuran!'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _connectToBluetooth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 14,
                          top: 12,
                          bottom: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.bluetooth,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isConnected ? 'Putus Koneksi' : 'Mulai Koneksi',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: _statusColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 13.0,
                        horizontal: 16.0,
                      ),
                      child: Text(
                        _statusText,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: _isConnected
                      ? 'Pilih sensor yang diketuk!'
                      : 'Data sensor yang ingin dilihat',
                  labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.brown,
                      ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.brown),
                  ),
                ),
                items: List.generate(
                  widget.sensorCount,
                  (index) => DropdownMenuItem(
                    value: 'Sensor ${index + 1}',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: sensorColors['Sensor ${index + 1}'],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Sensor ${index + 1}',
                        style: GoogleFonts.manrope(),
                      ),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    // If there's a previously selected sensor and its data is unsaved
                    if (previousSensor != null) {
                      // Reset data fields for the unsaved previous sensor
                      countedData = 0;
                      sumData = [];
                      averageData = [];
                      validationMessage = "Menunggu data...";
                      validationMessageColor = Colors.black;
                      _dataSent = false;
                      _hitungAverageClicked = false;
                    }

                    // Update `previousSensor` to the current selected sensor before switching
                    previousSensor = selectedSensor;
                    selectedSensor = value;
                    selectedSensorIndex = int.parse(value!.split(' ').last) - 1;
                  });

                  _updateRowEditability(value);
                  _calculateChordDistances();

                  // Send selected sensor to the device if measurement mode is on
                  if (isMeasurementModeOn) {
                    _sendSelectedSensor(value!.split(' ').last);
                  }
                },
              ),

              const SizedBox(height: 20),
              // After sensor is chosen...
              if (selectedSensor != null)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Center(
                            child: Text(
                          _sensorModeText,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                        )),
                        //Spacer(),
                        Switch(
                          value: isMeasurementModeOn,
                          onChanged: (bool value) {
                            _toggleSensorMode(
                                value, (selectedSensorIndex + 1).toString());
                          },
                          activeColor: Colors.green,
                          inactiveThumbColor:
                              const Color.fromARGB(255, 88, 95, 88),
                          //inactiveTrackColor: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Table(
                      border: TableBorder.all(
                          color: const Color.fromARGB(255, 187, 173, 173)),
                      columnWidths: const <int, TableColumnWidth>{
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(2),
                      },
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 221, 211, 211),
                          ),
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'Sensor',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                'V (m/s)',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        for (int index = 0; index < widget.sensorCount; index++)
                          TableRow(
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? Colors.white
                                  : const Color.fromARGB(255, 241, 231, 231),
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sensor #${index + 1}',
                                    style: GoogleFonts.manrope(
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  sensorData[selectedSensor]![index]['vms'] ??
                                      '0',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Text(
                      validationMessage,
                      style: TextStyle(
                        color: validationMessageColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Jumlah Data: $countedData",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _dataSent ? _showAverageData : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dataSent
                            ? const Color.fromARGB(255, 18, 108, 21)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        "Hitung Rata-rata Kecepatan",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Aksi:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hitungAverageClicked ? _saveData : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hitungAverageClicked
                              ? Colors.brown
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Simpan",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _hitungAverageClicked ? _deleteData : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hitungAverageClicked
                              ? const Color.fromARGB(255, 211, 61, 51)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          "Hapus Data",
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PairedDeviceScreen extends StatelessWidget {
  final Function(BluetoothDevice) onSelected;

  const PairedDeviceScreen({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Device")),
      body: FutureBuilder<List<BluetoothDevice>>(
        future: FlutterBluetoothSerial.instance.getBondedDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          List<BluetoothDevice>? devices = snapshot.data;
          if (devices == null || devices.isEmpty) {
            return const Center(child: Text("No devices found"));
          }

          return ListView(
            children: devices.map((device) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  color: const Color.fromARGB(255, 241, 231, 231),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: const BorderSide(
                        color: Color.fromARGB(255, 221, 211, 211), width: 1),
                  ),
                  child: ListTile(
                    title: Text(
                      device.name ?? "Unknown Device",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown.shade900,
                          ),
                    ),
                    subtitle: Text(
                      device.address,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.brown.shade700,
                          ),
                    ),
                    onTap: () {
                      onSelected(device);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
