import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'project_model.dart';

class LocalStorageService {
  Future<void> saveProject(ProjectModel project) async {
    final prefs = await SharedPreferences.getInstance();
    final projectString = jsonEncode(projectToJson(project));
    await prefs.setString(project.projectName, projectString);
  }

  Future<ProjectModel?> loadProject(String projectName) async {
    final prefs = await SharedPreferences.getInstance();
    final projectString = prefs.getString(projectName);
    if (projectString != null) {
      return projectFromJson(projectString);
    }
    return null;
  }

  Map<String, dynamic> projectToJson(ProjectModel project) {
    return {
      'projectName': project.projectName,
      'selectedSpecies': project.selectedSpecies,
      'layers': project.layers.map((layer) => layerToJson(layer)).toList(),
    };
  }

  ProjectModel projectFromJson(String jsonString) {
    final jsonData = jsonDecode(jsonString);
    return ProjectModel(
      projectName: jsonData['projectName'],
      selectedSpecies: jsonData['selectedSpecies'],
      layers: (jsonData['layers'] as List<dynamic>)
          .map((layerJson) => layerFromJson(layerJson))
          .toList(),
    );
  }

  Map<String, dynamic> layerToJson(LayerModel layer) {
    return {
      'layerName': layer.layerName,
      'geometryData': layer.geometryData,
      'sensorDataList': layer.sensorDataList.map((sensor) => sensorToJson(sensor)).toList(),
    };
  }

  LayerModel layerFromJson(Map<String, dynamic> jsonData) {
    return LayerModel(
      layerName: jsonData['layerName'],
      geometryData: Map<String, String>.from(jsonData['geometryData']),
      sensorDataList: (jsonData['sensorDataList'] as List<dynamic>)
          .map((sensorJson) => sensorFromJson(sensorJson))
          .toList(),
    );
  }

  Map<String, dynamic> sensorToJson(SensorDataModel sensor) {
    return {
      'sensorNumber': sensor.sensorNumber,
      'sensorValues': sensor.sensorValues,
    };
  }

  SensorDataModel sensorFromJson(Map<String, dynamic> jsonData) {
    return SensorDataModel(
      sensorNumber: jsonData['sensorNumber'],
      sensorValues: Map<String, String>.from(jsonData['sensorValues']),
    );
  }
}
