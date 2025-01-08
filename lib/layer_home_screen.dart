import 'package:flutter/material.dart';
import 'dart:ui';
import 'geometry_screen.dart';
import 'measurement_screen.dart';
import 'tomogram_screen.dart';
import 'project_screen.dart';
import 'local_storage_service.dart';
import 'project_model.dart';
import 'home_screen.dart';

class LayerHome extends StatefulWidget {
  final String layerName;
  final String selectedSpecies;
  final String projectName;

  const LayerHome({
    super.key,
    required this.layerName,
    required this.selectedSpecies,
    required this.projectName,
  });

  @override
  _LayerHomeState createState() => _LayerHomeState();
}

class _LayerHomeState extends State<LayerHome> {
  bool isGeometrySaved = false;
  bool isAllSensorsSaved = false;
  bool isDataSaved = false;
  Map<String, String> savedGeometryData = {};
  Map<String, List<Map<String, String>>> _savedSensorData = {};
  Map<String, Color> _sensorColors = {};

  final LocalStorageService _localStorageService = LocalStorageService();
  ProjectModel? _project;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    final project = await _localStorageService.loadProject(widget.projectName);
    if (project != null) {
      setState(() {
        _project = project;
        final layer = project.layers.firstWhere(
          (l) => l.layerName == widget.layerName,
          orElse: () => LayerModel(
            layerName: widget.layerName,
            geometryData: {},
            sensorDataList: [],
          ),
        );
        savedGeometryData = layer.geometryData;
        isGeometrySaved = savedGeometryData.isNotEmpty;
        _savedSensorData = Map.fromEntries(
          layer.sensorDataList.map((sensor) => MapEntry(
                'Sensor ${sensor.sensorNumber}',
                [sensor.sensorValues],
              )),
        );
        isAllSensorsSaved = layer.sensorDataList.isNotEmpty;
        _sensorColors = {
          for (var sensor in layer.sensorDataList)
            'Sensor ${sensor.sensorNumber}': Colors.green
        };
      });
    }
  }

  Future<void> _saveLayerData() async {
    if (_project != null) {
      final updatedLayer = LayerModel(
        layerName: widget.layerName,
        geometryData: savedGeometryData,
        sensorDataList: _savedSensorData.entries
            .map((entry) => SensorDataModel(
                  sensorNumber: int.parse(entry.key.split(' ')[1]),
                  sensorValues: entry.value.first,
                ))
            .toList(),
      );

      final updatedLayers = (_project!.layers ?? [])
        ..removeWhere((layer) => layer.layerName == widget.layerName)
        ..add(updatedLayer);

      final updatedProject = ProjectModel(
        projectName: _project!.projectName,
        selectedSpecies: widget.selectedSpecies,
        layers: updatedLayers,
      );

      await _localStorageService.saveProject(updatedProject);
      setState(() {
        isDataSaved = true;
      });
    }
  }

  void _showSensorDistances(BuildContext context) {
    double circumference =
        double.tryParse(savedGeometryData['circumference'] ?? '0') ?? 0;
    int sensorCount =
        int.tryParse(savedGeometryData['sensorCount'] ?? '1') ?? 1;
    List<double> distances = [];
    double distancePerSensor = circumference / sensorCount;

    for (int i = 0; i < sensorCount; i++) {
      distances.add(i * distancePerSensor);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // Blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                color: Colors.black.withOpacity(0.3), // Optional darker overlay
              ),
            ),
            // Dialog content
            AlertDialog(
              backgroundColor: const Color(0xFFF4F4F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Center(
                child: Text(
                  'Jarak Sensor',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: const Color(0xFF006400),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: distances.asMap().entries.map((entry) {
                  int sensorNumber = entry.key + 1;
                  double distance = entry.value;
                  String formattedDistance = (distance % 1 == 0)
                      ? distance
                          .toStringAsFixed(0) // No decimal for whole numbers
                      : distance
                          .toStringAsFixed(1); // One decimal place if needed

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0), // Spacing between each row
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              sensorNumber.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$formattedDistance cm',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Tutup',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _onAllSensorsSaved(bool allSaved) {
    setState(() {
      isAllSensorsSaved = allSaved;
    });
  }

  Map<String, List<Map<String, String>>> _getInitialSensorData() {
    int sensorCount =
        int.tryParse(savedGeometryData['sensorCount'] ?? '1') ?? 1;
    return {
      for (int i = 1; i <= sensorCount; i++)
        'Sensor $i': List.generate(sensorCount, (_) => {'vms': ''})
    };
  }

  void _saveSensorData(
      Map<String, List<Map<String, String>>> data, Map<String, Color> colors) {
    setState(() {
      _savedSensorData = data;
      _sensorColors = colors;
      isAllSensorsSaved = _savedSensorData.values.every((sensorList) =>
          sensorList.every((sensorMap) =>
              sensorMap['vms'] != '' && sensorMap['vms'] != null));
    });
  }

  Future<bool> _onWillPop() async {
    if (!isDataSaved) {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFFF4F4F4),
              title: Text(
                'Apakah anda yakin untuk keluar?',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: const Color(0xFF006400),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              content:
                  const Text('Semua data yang belum tersimpan akan hilang.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "Tidak, saya belum selesai",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.green, 
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), 
                    ),
                  ),
                  child: Text(
                    "Ya, saya yakin",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
              ],
            ),
          ) ??
          false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Layer: ${widget.layerName}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeometryScreen(
                        layerName: widget.layerName,
                        savedData: savedGeometryData,
                        onSave: (data) {
                          setState(() {
                            isGeometrySaved = true;
                            savedGeometryData = data;
                          });
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Atur Geometri Pengukuran',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: isGeometrySaved
                    ? () => _showSensorDistances(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isGeometrySaved ? Colors.brown : Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.layers,
                        color: isGeometrySaved ? Colors.white : Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lihat Jarak Antar Sensor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isGeometrySaved
                                  ? Colors.white
                                  : Colors.grey, // Conditional color
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: isGeometrySaved
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MeasurementScreen(
                              sensorCount: int.tryParse(
                                      savedGeometryData['sensorCount'] ??
                                          '1') ??
                                  1,
                              initialSensorData: _savedSensorData.isNotEmpty
                                  ? _savedSensorData
                                  : _getInitialSensorData(),
                              savedGeometryData: savedGeometryData,
                              onSave: _saveSensorData,
                              onAllSensorsSaved: _onAllSensorsSaved,
                              savedSensorColors: _sensorColors,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isGeometrySaved ? Colors.brown : Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.bluetooth,
                        color: isGeometrySaved ? Colors.white : Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Atur Koneksi dan Mulai Pengukuran',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isGeometrySaved
                                  ? Colors.white
                                  : Colors.grey, // Conditional color
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: isAllSensorsSaved
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TomogramScreen()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAllSensorsSaved ? Colors.brown : Colors.grey.shade300,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.show_chart,
                        color: isAllSensorsSaved ? Colors.white : Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lihat Tomogram',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isGeometrySaved
                                  ? Colors.white
                                  : Colors.grey, // Conditional color
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isAllSensorsSaved
                    ? () async {
                        await _saveLayerData();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectScreen(
                              projectName:
                                  _project?.projectName ?? 'Unnamed Project',
                              selectedSpecies: widget.selectedSpecies,
                              newLayer: widget.layerName,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isAllSensorsSaved ? Colors.brown : Colors.grey.shade300,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Simpan Data Pengukuran',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white, // Override color to white
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
