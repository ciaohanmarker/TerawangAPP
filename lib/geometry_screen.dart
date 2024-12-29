import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class GeometryScreen extends StatefulWidget {
  final String layerName;
  final Function(Map<String, String>) onSave;
  final Map<String, String>? savedData;

  const GeometryScreen({
    super.key,
    required this.layerName,
    required this.onSave,
    this.savedData,
  });

  @override
  _GeometryScreenState createState() => _GeometryScreenState();
}

class _GeometryScreenState extends State<GeometryScreen> {
  final TextEditingController _circumferenceController =
      TextEditingController();
  final TextEditingController _sensorCountController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  final String fixedDepth = "3";
  final String fixedThickness = "1";

  bool isAllFieldsFilled = false;

  @override
  void initState() {
    super.initState();
    // Load saved data if available
    if (widget.savedData != null) {
      _circumferenceController.text = widget.savedData!['circumference'] ?? '';
      _sensorCountController.text = widget.savedData!['sensorCount'] ?? '';
      _heightController.text = widget.savedData!['height'] ?? '';
    }

    // Check if all fields are filled
    _checkFields();
  }

  void _checkFields() {
    setState(() {
      isAllFieldsFilled = _circumferenceController.text.isNotEmpty &&
          _sensorCountController.text.isNotEmpty &&
          _heightController.text.isNotEmpty;
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Layer: ${widget.layerName}",
          style: GoogleFonts.manrope(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildNumericTextField(
                controller: _circumferenceController,
                label: 'Lingkar Keliling Pohon (cm)',
                hintText: 'Masukkan keliling batang pohon!',
              ),
              const SizedBox(height: 20),
              _buildFixedValueTextField(
                label: 'Kedalaman Penetrasi (cm)',
                value: fixedDepth,
              ),
              const SizedBox(height: 20),
              _buildFixedValueTextField(
                label: 'Ketebalan Kulit Batang (cm)',
                value: fixedThickness,
              ),
              const SizedBox(height: 20),
              _buildNumericTextField(
                controller: _sensorCountController,
                label: 'Jumlah Sensor',
                hintText: 'Masukkan jumlah sensor',
                isInteger: true,
              ),
              const SizedBox(height: 20),
              _buildNumericTextField(
                controller: _heightController,
                label: 'Ketinggian Pengukuran (cm)',
                hintText: 'Masukkan ketinggian pengukuran',
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: isAllFieldsFilled
                    ? () {
                        // Save the data locally
                        widget.onSave({
                          'circumference': _circumferenceController.text,
                          'depth': fixedDepth,
                          'thickness': fixedThickness,
                          'sensorCount': _sensorCountController.text,
                          'height': _heightController.text,
                        });
                        Navigator.pop(context);
                      }
                    : null, // Disable the button if fields are not all filled
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(
                  Icons.save, // Replace with your preferred icon
                  color: Colors.white,
                ),
                label: Text(
                  "Simpan",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    bool isInteger = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isInteger
          ? TextInputType.number
          : const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          isInteger ? RegExp(r'[0-9]') : RegExp(r'[0-9.]'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.brown.shade700,
            ),
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.brown.shade400,
            ),
        filled: true,
        fillColor: Colors.brown.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.brown.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.brown,
            width: 2.0,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.brown.shade800,
          ),
      onChanged: (value) {
        _checkFields();
      },
    );
  }

  Widget _buildFixedValueTextField({
    required String label,
    required String value,
  }) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true, // Make the field uneditable
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: GoogleFonts.manrope(
          fontSize: 18,
          color: Colors.brown.shade700,
        ),
        filled: true,
        fillColor: Colors.brown.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.brown.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.brown,
            width: 2.0,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
      style: GoogleFonts.manrope(
        fontSize: 16,
        color: Colors.grey,
      ),
    );
  }
}
