import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'project_screen.dart';
import 'local_storage_service.dart';
import 'project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedProjectsScreen extends StatefulWidget {
  const SavedProjectsScreen({super.key});

  @override
  _SavedProjectsScreenState createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<ProjectModel> savedProjects = [];

  @override
  void initState() {
    super.initState();
    _loadSavedProjects();
  }

  Future<void> _loadSavedProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().toList(); // Get all keys (project names)
    List<ProjectModel> projects = [];
    for (var key in keys) {
      final project = await _localStorageService.loadProject(key);
      if (project != null) {
        projects.add(project);
      }
    }

    setState(() {
      savedProjects = projects;
    });
  }

  Future<void> _deleteProject(String projectName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(projectName);
    _loadSavedProjects(); // Refresh the project list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Projects',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: savedProjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'You currently have no saved project.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectScreen(
                            projectName: 'New Project',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.post_add,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Buat Proyek Baru',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: savedProjects.length,
              itemBuilder: (context, index) {
                final project = savedProjects[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      project.projectName,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'Species: ${project.selectedSpecies.isNotEmpty ? project.selectedSpecies : 'N/A'}',
                      style: GoogleFonts.manrope(fontSize: 14),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProject(project.projectName);
                      },
                    ),
                    onTap: () {
                      // Show project details or allow navigation to edit
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Project: ${project.projectName}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Tree Species: ${project.selectedSpecies}'),
                                const SizedBox(height: 10),
                                Text('Layers: ${project.layers.length}'),
                                const SizedBox(height: 10),
                                ...project.layers.map((layer) {
                                  return ListTile(
                                    title: Text('Layer: ${layer.layerName}'),
                                    subtitle: Text(
                                        'Geometry: ${layer.geometryData.toString()}\nSensors: ${layer.sensorDataList.length}'),
                                  );
                                }),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
