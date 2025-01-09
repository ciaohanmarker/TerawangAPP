import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class InputDialog extends StatefulWidget {
  final Widget title; // Ubah dari String ke Widget
  final Function(String) onProjectNameSaved;

  const InputDialog({
    super.key,
    required this.title,
    required this.onProjectNameSaved,
  });

  @override
  _InputDialogState createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isTextFilled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_checkText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkText() {
    setState(() {
      _isTextFilled = _controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: const Color(0xFFF4F4F4),
        title: widget.title,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Masukkan nama file',
              hintStyle: GoogleFonts.manrope(color: Colors.black54),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.green),
              ),
            ),
            cursorColor: Colors.green,
            style: GoogleFonts.manrope(color: Colors.black),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Batalkan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: _isTextFilled
                ? () {
                    widget.onProjectNameSaved(_controller.text);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            ),
            child: Text(
              'Simpan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
