import 'dart:convert';
import 'dart:io';
import 'project_model.dart';


class LocalStorageService {
  Future<void> saveProject(ProjectModel project,) async {
    final directory = Directory('/storage/emulated/0/Documents/${project.projectName}');
    
    // Pastikan direktori ada
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Konversi project ke JSON string
    final projectString = jsonEncode(projectToJson(project));
    
    // Buat file di dalam direktori proyek
    final file = File('${directory.path}/${project.projectName}.json');
    
    // Tulis JSON string ke file
    await file.writeAsString(projectString);
  }

  Future<ProjectModel?> loadProject(String projectName) async {
    final directory = Directory('/storage/emulated/0/Documents/$projectName');
    final file = File('${directory.path}/$projectName.json');
    
    // Cek apakah file ada
    if (await file.exists()) {
      // Baca konten file
      final projectString = await file.readAsString();
      return projectFromJson(projectString);
    }
    
    return null;
  }

  Map<String, dynamic> projectToJson(ProjectModel project) {
    return {
      'projectName': project.projectName,
      'selectedSpecies': project.selectedSpecies,
      'layers': project.layers.map((layer) => layerToJson(layer)).toList(),
      'latitude': project.latitude,
      'longitude': project.longitude,
      'imagePath': '/storage/emulated/0/Documents/${project.projectName}_image.jpg',
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
      latitude: jsonData['latitude'],
      longitude: jsonData['longitude'],
      imagePath: jsonData['imagePath'],
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

class ImageStorageService {
  Future<String> saveImage(File imageFile, String projectName) async {
    final directory = Directory('/storage/emulated/0/Documents/$projectName');
    
    // Pastikan direktori ada
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    // Tentukan path untuk menyimpan gambar
    final imagePath = '${directory.path}/${projectName}_image.jpg';
    
    // Simpan gambar sebagai JPEG
    await imageFile.copy(imagePath);
    
    return imagePath;
  }
}
