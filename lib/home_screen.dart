import 'package:flutter/material.dart';
import 'project_screen.dart';
import 'input_dialog.dart';

import 'local_storage_service.dart';
import 'project_model.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  // Initialize local storage service
  final LocalStorageService _localStorageService = LocalStorageService();

  HomeScreen({super.key});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE8DC),

      resizeToAvoidBottomInset:
          true, // Enable screen resizing when keyboard appears
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'assets/images/terawang-logo.png',
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Monitoring kondisi internal batang pohon.',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            const Text(
              'Ketahui kesehatan pohon Anda dengan akurat menggunakan teknologi acoustic tomography. '
              'Lindungi dan pelihara pepohonan dengan Terawang.',
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Shows input dialog to input project name for the new project
                showDialog(
                  context: context,
                  builder: (context) => InputDialog(
                    title: Text(
                      "Masukkan nama proyek!",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: const Color(0xFF006400),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    onProjectNameSaved: (name) async {
                      // Initialize an empty project with no layers
                      final project = ProjectModel(
                        projectName: name,
                        selectedSpecies: '',
                        layers: [],
                      );

                      // Save the project locally using local storage service
                      await _localStorageService.saveProject(project);

                      // Navigate to ProjectScreen with the project name
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProjectScreen(projectName: name),
                        ),
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 71, 60),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Mulai Proyek Baru',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Menampilkan dialog input untuk memasukkan nama proyek
                showDialog(
                  context: context,
                  builder: (context) => InputDialog(
                    title: Text(
                      "Masukkan nama proyek untuk memuat!",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: const Color(0xFF006400),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    onProjectNameSaved: (name) async {
                      // Memuat proyek yang sudah ada berdasarkan nama yang dimasukkan
                      final project = await _localStorageService.loadProject(name); //yg masih perlu koreksi

                      // Jika proyek ditemukan, navigasikan ke layar proyek
                      if (project != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectScreen(projectName: name),
                          ),
                        );
                      } else {
                        // Tampilkan pesan jika proyek tidak ditemukan
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Proyek tidak ditemukan: $name'),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 101, 71, 60),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Memuat Proyek',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
              ),
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  color: const Color.fromARGB(255, 101, 71, 60),
                  iconSize: 30,
                ),
                // const SizedBox(width: 20),
                // IconButton(
                //   onPressed: () {
                //     // Navigate to Manual page or perform Manual action
                //   },
                //   icon: const Icon(Icons.book),
                //   color: const Color.fromARGB(255, 101, 71, 60),
                //   iconSize: 30,
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
