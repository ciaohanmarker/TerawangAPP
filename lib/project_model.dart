class ProjectModel {
  final String projectName;
  final String selectedSpecies;
  final List<LayerModel> layers;
  final double? latitude;
  final double? longitude;
  final String? address;

  ProjectModel({
    required this.projectName,
    required this.selectedSpecies,
    required this.layers,
    this.latitude,
    this.longitude,
    this.address,
  });
}

class LayerModel {
  final String layerName;
  final Map<String, String> geometryData; // Geometry data for the layer
  final List<SensorDataModel> sensorDataList; // List of sensor data

  LayerModel({
    required this.layerName,
    required this.geometryData,
    required this.sensorDataList,
  });
}

class SensorDataModel {
  final int sensorNumber;
  final Map<String, String> sensorValues; // Sensor values mapped by type (e.g., 'vms', etc.)

  SensorDataModel({
    required this.sensorNumber,
    required this.sensorValues,
  });
}
