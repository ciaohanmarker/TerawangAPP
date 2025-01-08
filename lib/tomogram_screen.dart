import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TomogramScreen extends StatefulWidget {
  const TomogramScreen({super.key});

  @override
  _TomogramScreenState createState() => _TomogramScreenState();
}

class _TomogramScreenState extends State<TomogramScreen> {
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
              Text(
                'Silahkan membuat tomogram di aplikasi visualisasi.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            ],
          ),
        ),
      ),
    );
  }
}
