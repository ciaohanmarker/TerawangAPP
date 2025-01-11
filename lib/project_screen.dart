import 'package:flutter/material.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'input_dialog.dart';
import 'layer_home_screen.dart';
import 'home_screen.dart';
import 'package:path/path.dart' as path;

class ProjectScreen extends StatefulWidget {
  final String projectName;
  final String? selectedSpecies;
  final String? newLayer;

  const ProjectScreen(
      {super.key,
      required this.projectName,
      this.selectedSpecies,
      this.newLayer});

  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final List<String> treeSpecies = [
    "Acret",
    "Caringin",
    "Cemara",
    "Damar",
    "Mahoni",
    "Palm",
    "Pinus",
    "Salam",
  ];

  List<String> layers = [];
  String selectedSpecies = '';
  String? selectedLayer;
  bool isSpeciesSelected = false;
  bool isLayerDropdownEnabled = false;
  bool isSpeciesFieldTapped = false;
  File? _image;

  final TextEditingController _controller = TextEditingController();
  double? latitude;
  double? longitude;
  bool isLocationTaken = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedSpecies != null) {
      selectedSpecies = widget.selectedSpecies!;
      _controller.text = selectedSpecies;
      isSpeciesSelected = true;
      isLayerDropdownEnabled = layers.isNotEmpty;
    }

    if (widget.newLayer != null) {
      setState(() {
        layers.add(widget.newLayer!);
        isLayerDropdownEnabled = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Prompt the user to enable location services
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFFF4F4F4),
            title: Text(
              'GPS Tidak Aktif',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF006400),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            content: Text(
              'Aktifkan GPS untuk mengambil lokasi.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openLocationSettings();
                },
                child: Text(
                  'Buka Pengaturan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  foregroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Batal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

// check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      isLocationTaken = true;
    });
  }

  Future<void> _navigateToCameraScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
    if (result != null && result is File) {
      setState(() async {
        _image = result;

        // Tentukan direktori penyimpanan proyek
        final directory = Directory('/storage/emulated/0/Documents/$widget.projectName');

        // Pastikan direktori ada
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Tentukan path tujuan untuk menyimpan gambar dengan nama file yang diinginkan
        final newPath = path.join(directory.path, '${widget.projectName}_image.jpeg');

        // Pindahkan atau salin file gambar ke lokasi tujuan
        File(result.path).copy(newPath);
      });
    }
  }


  Future<void> _openGoogleMaps() async {
    if (latitude != null && longitude != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lokasi belum tersedia")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'Proyek: ${widget.projectName}',
          style: GoogleFonts.manrope(),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _image != null
                        ? Image.file(
                            _image!,
                            fit: BoxFit.contain,
                          )
                        : Image.asset(
                            'assets/images/tree_placeholder.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _navigateToCameraScreen,
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Ambil Foto',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF556B2F),
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.manrope(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Spesies Pohon',
                    labelStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                    hintText: 'Masukkan spesies pohon!',
                    prefixIcon: Icon(
                      isSpeciesSelected ? Icons.nature : Icons.search,
                    ),
                  ),
                  controller: _controller,
                  onTap: () {
                    setState(() {
                      isSpeciesFieldTapped = true;
                    });
                  },
                  onChanged: (text) {
                    setState(() {
                      isSpeciesSelected = false;
                      isLayerDropdownEnabled = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          textStyle: GoogleFonts.manrope(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: isLocationTaken
                            ? const Icon(
                                Icons.edit_location,
                                color: Colors.white,
                              )
                            : const Icon(
                                Icons.add_location,
                                color: Colors.white,
                              ),
                        label: Text(
                          isLocationTaken ? 'Update Lokasi' : 'Ambil Lokasi',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (isLocationTaken)
                        IconButton(
                          onPressed: _openGoogleMaps,
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFEFE8DC),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          icon: SizedBox(
                            //width: 24.0, // Default icon size width
                            height: 24.0, // Default icon size height
                            child: Image.asset(
                              'assets/images/gmaps.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          tooltip: 'Open Google Maps',
                        )
                      else
                        Text(
                          'No location.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          Text(
                            'Latitude',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          Text(
                            isLocationTaken
                                ? latitude!.toStringAsFixed(7)
                                : 'No data',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.location_on),
                          Text(
                            'Longitude',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          Text(
                            isLocationTaken
                                ? longitude!.toStringAsFixed(7)
                                : 'No data',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: isSpeciesSelected
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => InputDialog(
                              title: Text(
                                "Masukkan nama layer!",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      color: const Color(0xFF006400),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              onProjectNameSaved: (layerName) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LayerHome(
                                      layerName: layerName,
                                      selectedSpecies: selectedSpecies,
                                      projectName: widget.projectName,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Tambah Layer Baru',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSpeciesSelected ? Colors.brown : Colors.grey,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.manrope(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedLayer,
                  hint: const Text('Pilih Layer'),
                  items: layers.map((layer) {
                    return DropdownMenuItem<String>(
                      value: layer,
                      child: Text(
                        layer,
                        style: GoogleFonts.manrope(),
                      ),
                    );
                  }).toList(),
                  onChanged: isLayerDropdownEnabled
                      ? (value) {
                          setState(() {
                            selectedLayer = value;
                          });
                        }
                      : null,
                  decoration: InputDecoration(
                    labelText: 'Pilih Layer',
                    labelStyle: GoogleFonts.manrope(),
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: isLayerDropdownEnabled
                        ? Colors.white
                        : Colors.grey.shade300,
                  ),
                  disabledHint: const Text('Pilih Layer'),
                  isExpanded: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Implement save action here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Simpan',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (isSpeciesFieldTapped)
            Positioned(
              top: 70,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                child: Container(
                  height: 150,
                  color: Colors.white,
                  child: ListView(
                    children: treeSpecies
                        .where((species) => species
                            .toLowerCase()
                            .contains(_controller.text.toLowerCase()))
                        .map((species) => ListTile(
                              title: Text(
                                species,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.black,
                                    ),
                              ),
                              onTap: () {
                                setState(() {
                                  selectedSpecies = species;
                                  _controller.text = species;
                                  isSpeciesSelected = true;
                                  isLayerDropdownEnabled = layers.isNotEmpty;
                                  isSpeciesFieldTapped = false;
                                });
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Initialize camera on screen load
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.max,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    setState(() async {
      _isCameraInitialized = true;
    });
  }

  // Function to capture a picture
  Future<void> _takePicture() async {
    if (!_cameraController!.value.isInitialized) {
      return; // Check if camera is initialized
    }

    final image = await _cameraController!.takePicture(); // Capture image

    Navigator.pop(
        context, File(image.path)); // Return image file to the previous screen
  }

  @override
  void dispose() {
    _cameraController?.dispose(); // Dispose camera controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isCameraInitialized
          ? Column(
              children: [
                // Display camera preview
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: CameraPreview(
                        _cameraController!), // Show the camera preview
                  ),
                ),
                // Bottom bar with black background and snap button
                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(20.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: _takePicture, // Trigger picture capture on tap
                      child: Container(
                        width: 80.0, // Circle size
                        height: 80.0, // Circle size
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle, // Make the container a circle
                          color: Colors.white, // White color for the circle
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child:
                  CircularProgressIndicator()), // Show loading indicator while initializing
    );
  }
}
