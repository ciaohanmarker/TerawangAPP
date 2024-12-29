import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import for delay functionality
import 'dart:async';

class TomogramScreen extends StatefulWidget {
  const TomogramScreen({super.key});

  @override
  _TomogramScreenState createState() => _TomogramScreenState();
}

class _TomogramScreenState extends State<TomogramScreen> {
  bool isLoading = false;
  bool showImage = false;

  void _generateTomogram() {
    setState(() {
      isLoading = true; // Show loading animation
    });

    // Three secons of loading animation before showing the image
    Timer(const Duration(seconds: 3), () {
      setState(() {
        isLoading = false; // Hide loading animation
        showImage = true; // Show the tomogram image
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tomogram',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isLoading &&
                  !showImage) // Show text if loading and image are false
                Text(
                  'Generate grafik tomogram dari\ndata yang didapat.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontSize: 16),
                ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              if (showImage) // Show the image after loading
                Column(
                  children: [
                    Image.asset(
                      'assets/images/tomogram.png',
                      width: MediaQuery.of(context).size.width *
                          0.9, // Image width 90% of screen
                      height: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Saving tomogram action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.download, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'Simpan Tomogram',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ), // Bold text
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              if (!showImage) // Only show button if image is not displayed
                ElevatedButton(
                  onPressed: _generateTomogram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Buat Tomogram',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ), // Bold text
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
